module Server = struct    
    open Response
    open Recore.Std


    let readFromSock socket =
        let buffer = Bytes.create 512 in
        let rec read_all request buffer =
            let r = Unix.read socket buffer 0 512 in
            if r < 512 then
                request ^ (String.sub buffer 0 r)
            else read_all (request ^ buffer) buffer in
        read_all "" buffer


    let listenSock =
        let sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
        let _ = Unix.setsockopt sock Unix.SO_REUSEADDR true in
        sock


    let write_to_sock sock str =
        let len = String.len str in
        let _ = Unix.write sock str 0 len in ()


    type r = EmptyRequest | ValidRequest of Request.t


    let getRequest sock : r =
        let sock_contents = readFromSock sock in
        if String.len sock_contents <> 0
        then ValidRequest (Request.createFromLiteral sock_contents)
        else EmptyRequest


    let rec getResponse (request: Request.t) (handlers: Handler.t list) =
        match handlers with
        | [] -> Response.Empty
        | (handler :: rest) -> (match handler#getResponse request with
            | Response.Empty -> getResponse request rest
            | Response.ValidResponse valid_response -> Response.ValidResponse valid_response)


    let validate client_sock response =
        match response with
        | Response.Empty -> ()
        | Response.ValidResponse valid_response -> write_to_sock client_sock valid_response


    let rec doListen listenSock handlers =
        let (client_sock, _) = Unix.accept listenSock in
        match getRequest client_sock with
        | EmptyRequest -> doListenHelper client_sock listenSock handlers
        | ValidRequest request -> begin
            Printf.printf "%s\n%s\n\n" (Time.RFC822.write Time.local) request#toString;
            match Unix.fork () with
            | 0 -> begin
                Unix.close listenSock;
                validate client_sock (getResponse request handlers);
                exit 0
            end
            | _ -> doListenHelper client_sock listenSock handlers
        end;
        ()


    and doListenHelper client_sock listenSock handlers =
        Unix.close client_sock;
        doListen listenSock handlers;
        ()


    class server address port handlers =
        object
            method serve =
                let addr_inet =
                    (Unix.ADDR_INET (Unix.inet_addr_of_string address, port)) in
                Unix.bind listenSock addr_inet;
                Unix.listen listenSock 8;
                doListen listenSock handlers
        end


    let create address port handlers =
        Sys.set_signal Sys.sigchld Sys.Signal_ignore;
        new server address port handlers
end

module SimpleServer = struct
    include Server


    let default_port = 9090
    let default_address = "127.0.0.1"


    let create handlers = Server.create default_address default_port handlers


    let serve handlers =
        let server = create handlers in
        server#serve;
        server
end
