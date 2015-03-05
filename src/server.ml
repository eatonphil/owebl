module Server = struct    
    open Response

    let listen_sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0

    let read_from_sock socket =
        let buffer = String.create 512 in
        let rec read_all request buffer =
            let r = Unix.read socket buffer 0 512 in
            if r < 512 then
                (String.sub request 0 r) ^ buffer
            else read_all (request ^ buffer) buffer in
        read_all "" buffer

    let write_to_sock sock str =
        let len = String.length str in
        let _ = Unix.write sock str 0 len in ()

    type r = EmptyRequest | ValidRequest of Request.t

    let get_request sock : r =
        let sock_contents = read_from_sock sock in
        if String.length sock_contents <> 0
        then ValidRequest (Request.create_from_literal sock_contents)
        else EmptyRequest


    let rec get_response (request: Request.t) (handlers: Handler.t list) =
        match handlers with
        | [] -> Response.Empty
        | (handler :: rest) -> (match handler#get_response request with
            | Response.Empty -> get_response request rest
            | Response.ValidResponse valid_response -> Response.ValidResponse valid_response)

    let validate client_sock response =
        match response with
        | Response.Empty -> ()
        | Response.ValidResponse valid_response -> write_to_sock client_sock valid_response

    let rec do_listen listen_sock handlers =
        let (client_sock, _) = Unix.accept listen_sock in
        match get_request client_sock with
        | EmptyRequest -> do_listen_helper client_sock listen_sock handlers
        | ValidRequest request -> begin
            Printf.printf "%s\n%s\n" Utils.timestamp request#to_string;
            match Unix.fork () with
            | 0 -> begin
                Unix.close listen_sock;
                validate client_sock (get_response request handlers);
                exit 0
            end
            | _ -> do_listen_helper client_sock listen_sock handlers
        end;
        ()

    and do_listen_helper client_sock listen_sock handlers =
        Unix.close client_sock;
        do_listen listen_sock handlers;
        ()

    class server address port handlers =
        object
            method serve =
                let addr_inet =
                    (Unix.ADDR_INET (Unix.inet_addr_of_string address, port)) in
                Unix.bind listen_sock addr_inet;
                Unix.listen listen_sock 8;
                do_listen listen_sock handlers
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
