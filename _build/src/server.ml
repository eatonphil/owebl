module Server = struct
    open Unix
    open Response
    open Request
    open Handler

    let listen_sock = socket PF_INET SOCK_STREAM 0

    let read_from_sock socket =
        let buffer = Bytes.create 512 in
        let rec read_all request buffer =
            let r = Unix.read socket buffer 0 512 in
            if r < 512 then request ^ buffer
            else read_all (request ^ buffer) buffer in
        read_all "" buffer

    let write_to_sock sock str =
        let len = String.length str in
        let _ = Unix.write sock str 0 len in ()

    let get_request sock =
        Request.create_from_literal (read_from_sock sock)

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

    let max_child_procs = 100

    let rec do_listen listen_sock handlers child_procs =
        let (client_sock, _) = accept listen_sock in
        let request = get_request client_sock in
        match fork () with
        | 0 -> validate client_sock (get_response request handlers); exit 0
        | _ -> (if child_procs > max_child_procs
            then let _ = wait () in
            do_listen_helper client_sock listen_sock handlers (child_procs - 1)
            else do_listen_helper client_sock listen_sock handlers (child_procs + 1));
        ()

    and do_listen_helper client_sock listen_sock handlers child_procs =
        close client_sock;
        do_listen listen_sock handlers child_procs;
        ()

    class server address port handlers =
        object
            method serve =
                bind listen_sock (ADDR_INET (inet_addr_of_string address, port));
                listen listen_sock 8;
                do_listen listen_sock handlers 0

            initializer Printf.printf "Starting OWebl server at %s:%d\n" address port;
        end

    let create address port handlers = new server address port handlers
end

module SimpleServer = struct
    include Server

    let default_port = 9090
    let default_address = "127.0.0.1"

    let create handlers = new server default_address default_port handlers
end
