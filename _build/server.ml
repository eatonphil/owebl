open Unix
open Utils
open Handler

let listen_sock = socket PF_INET SOCK_STREAM 0

let read_from_sock socket = 
    let buffer = String.create 512 in
    let rec read_all request buffer =
        let r = Unix.read socket buffer 0 512 in
        if r < 512 then request ^ buffer
        else read_all (request^buffer) buffer in
    read_all "" buffer

let write_to_sock sock str =
    let len = String.length str in
    let _ = Unix.write sock str 0 len in ()

let get_uri request =
    let uri_start = (String.index request ' ') + 1 in
    let uri_length = (String.index (String.sub request uri_start ((String.length request) - uri_start)) ' ') in
    ((String.sub request 0 (uri_start-1)), (String.sub request uri_start uri_length))

let get_request sock =
    get_uri (read_from_sock sock)

let send_header sock =
    write_to_sock sock "HTTP/1.1 200 OK\nContent-type: text/html\n"

let send_content sock str =
    let len = String.length str in
    let content = "Content-Length: " ^ string_of_int len ^ "\n\n" ^ str in
    write_to_sock sock content

let send_response handler client_sock request_uri request_method =
    send_header client_sock;
    send_content client_sock (handler#get_callback request_uri request_method)

let rec select_handler (handlers : handler list) request_uri request_method =
    if List.exists (fun h -> h#matches request_uri request_method) handlers
    then let the_h = List.find (fun h -> h#matches request_uri request_method) handlers in the_h
    else select_handler handlers "404" "GET"

let rec do_listen handlers =
    let (client_sock, _) = accept listen_sock in
    let (request_method, request_uri) = get_request client_sock in
    let handler = select_handler handlers request_uri request_method in
    send_response handler client_sock request_uri request_method;
    close client_sock;
    do_listen handlers

class server ?addr ?port =
    object(self)

        val mutable handlers =
            let _404_error = new handler "404" (fun request_uri -> (fun request_method -> "<h1>404 Error - Page Not Found.")) ["GET"] in [_404_error]

        method get_port = match port with
            | None -> 9090
            | Some p -> p

        method get_addr = match addr with
            | None -> "0.0.0.0"
            | Some a -> a

        method register_handler rule callback methods =
            let new_handler = new handler rule callback methods in
            handlers <- new_handler :: handlers
            
        method start =
            bind listen_sock (ADDR_INET (inet_addr_of_string self#get_addr, self#get_port));
            print_s ("Starting server at " ^ self#get_addr ^ ":" ^ (string_of_int self#get_port) ^ "...");
            listen listen_sock 8;
            let _ = do_listen handlers in ()
    end