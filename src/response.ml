module Response = struct
    type r =
        | Empty
        | ValidResponse of string

    type t = < get_response: Request.t -> r >

    let http_response (u_response: string) (u_status: string)
    (u_ctype: string) (u_ccharset: string) (u_headers: string list) =
        ValidResponse (Printf.sprintf "HTTP/1.1 %s\nContent-Type: %s;\
        charset=%s\nContent-Length: %d\n\n%s" u_status u_ctype
        u_ccharset (String.length u_response) u_response)

    class virtual response =
        object
            method virtual get_response : Request.t -> r
        end
end

module SimpleResponse = struct
    include Response

    let simple_http_response (u_response: string) : Response.r =
        http_response u_response "200 OK" "text/html" "utf-8" []

    class simple_response (u_response: string) =
        object
            method get_response (request: Request.t) : r =
                simple_http_response u_response
        end

    let create (u_response: string) = new simple_response u_response
end

module FileResponse = struct
    include Response

    type f = NoStaticFile | StaticFile of string
    type d = DefaultTemplateDir | TemplateDir of string

    let default_template_dir = "templates"

    class file_response (template_dir: d) (static_file: f) =
        object
            method get_response (request: Request.t) : r =
                let file_name = (match static_file with
                | NoStaticFile -> request#get_path
                | StaticFile file -> file) in
                let dir =
                    (match template_dir with
                    | DefaultTemplateDir -> default_template_dir
                    | TemplateDir custom_dir -> custom_dir) in
                    let file_string =
                        Utils.read_file_to_string (dir ^ file_name) in
                    SimpleResponse.simple_http_response file_string
        end

    let create
        ?(template_dir: d = DefaultTemplateDir)
        ?(static_file: f = NoStaticFile)
        () =
            new file_response template_dir static_file 
end

module TemplateResponse = struct
    open Template

    include Response

    class template_response
        (template_dir: FileResponse.d)
        (static_file: FileResponse.f)
        (context: Context.t) = 
        object
            inherit FileResponse.file_response template_dir static_file as super

            method get_response (request: Request.t) : r =
                let response = super#get_response request in
                match response with
                | Response.Empty -> Response.Empty
                | Response.ValidResponse response -> let tmpl_resp =
                    let response_body = Request.create_from_literal response in
                    Template.templatize response_body#get_body context request in
                SimpleResponse.simple_http_response tmpl_resp
        end

    let create
        ?(template_dir: FileResponse.d = FileResponse.DefaultTemplateDir)
        ?(static_file: FileResponse.f = FileResponse.NoStaticFile)
        ?(context: Context.t = Context.make [])
        () =
            new template_response template_dir static_file context
end

(*
module ErrorResponse = struct
    include Response

    type e =
        | ERROR_404
        | ERROR_502

    let error_map (u_error: e) = match u_error with
    | ERROR_404 -> "404 Not Found"
    | ERROR_502 -> "502 Internal Server Error"

    let error_http_response (u_error: e) (u_response: string): Response.r =
        http_response u_response u_error "text/html" "utf-8" []

    class error_response (u_error: e) (u_response: string) =
        object
            method get_response (request: Request.t) : r =
                error_http_response u_error u_response
        end

    let create (u_error: e) (u_response: string) =
        new error_response u_error u_response 
end
*)
