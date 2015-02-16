open Request
open Verb

let test1 = "GET /foo/bar/ HTTP/1.1"

let test2 = "POST /path/script.cgi HTTP/1.0\n\
From: frog@jmarshall.com\n\
User-Agent: HTTPTool/1.0\n\
Content-Type: application/x-www-form-urlencoded\n\
Content-Length: 32\n\
\n\
home=Cosby&favorite+flavor=flies"

let print_request request =
    let r = Request.create_from_literal request in
    print_string ("uri: " ^ r#get_uri ^ "\n");
    (match r#get_verb with
    | Verb.GET -> print_string "verb: GET\n"
    | _ -> print_string "verb: POST\n");
    let rec p h = 
        (match h with
        | [] -> ()
        | (h :: rs) -> print_string ("header: " ^ h ^ "\n"); p rs) in
    p r#get_headers;
    print_string ("body: " ^ r#get_body ^ "\n");
    ();;

let _ = print_request test1 in ();;
let _ = print_request test2 in ()
