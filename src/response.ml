open Recore.Std

module Response = struct
    type r =
        | Empty
        | ValidResponse of string

    type t = < getResponse: Request.t -> r >

    let http_response (u_response: string) (u_status: string)
    (u_ctype: string) (u_ccharset: string) (u_headers: string list) =
        ValidResponse (Printf.sprintf "HTTP/1.1 %s\nContent-Type: %s;\
        charset=%s\nContent-Length: %d\n%s\n\n%s" u_status u_ctype
        u_ccharset (String.length u_response)
        (String.join "\n" u_headers) u_response)

    class virtual response =
        object
            method virtual getResponse : Request.t -> r
        end
end

module SimpleResponse = struct
    include Response

    let simple_http_response (u_response: string) : Response.r =
        http_response u_response "200 OK" "text/html" "utf-8" []

    class simple_response (u_response: string) =
        object
            method getResponse (request: Request.t) : r =
                simple_http_response u_response
        end

    let create (u_response: string) = new simple_response u_response
end

module FileResponse = struct
    include Response

    class file_response (static_file: string) =
        object
            method getResponse (request: Request.t) : r =
                let file_name =
                    if static_file = "" then "." ^ request#getPath
                    else static_file in

                let last_modified = Unix.gmtime (Unix.stat file_name).Unix.st_mtime in

                if Request.Headers.exists "If-Modified-Since" request#getHeaders &&
                    Time.(<=) last_modified (Time.RFC822.read
                        (Request.Headers.get "If-Modified-Since" request#getHeaders))
                then
                    Response.ValidResponse "HTTP/1.1 304 Not Modified\n\n"
                else
                    let file_string = File.read file_name in

                    let mime_type = Mime.getMimeType file_name in

                    let cache_headers = [
                        "Last-Modified: " ^ (Time.RFC822.write last_modified)
                    ] in

                    Response.http_response file_string "200 OK" mime_type "utf-8" cache_headers
        end

    let create
        ?(static_file: string = "")
        () =
            new file_response static_file 
end

module TemplateResponse = struct
    open Template

    include Response

    class template_response
        (static_file: string)
        (context: Context.c) = 
        object
            inherit FileResponse.file_response static_file as super

            method getResponse (request: Request.t) : r =
                let response = super#getResponse request in
                match response with
                | Response.Empty -> Response.Empty
                | Response.ValidResponse response -> let tmpl_resp =
                    let response_body = Request.createFromLiteral response in
                    Template.templatize response_body#getBody context request in
                SimpleResponse.simple_http_response tmpl_resp
        end

    let create
        ?(static_file: string = "")
        ?(context: Context.c = Context.empty)
        () =
            new template_response static_file context
end
