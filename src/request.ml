type t = <
    get_uri: string;
    get_verb: Verb.t;
    get_headers: string list;
    get_body: string;
    get_path: string;
    get_query: string
>

let substr_index s d i =
    let spl = Str.split (Str.regexp d) s in
    let len = Array.length (Array.of_list spl) in
    if i >= len || i < 0 then ""
    else List.nth (Str.split (Str.regexp d) s) i

class request (uri: string) (verb: Verb.t) (headers: string list) (body: string) =
    object(self)
        method get_uri = uri
        method get_verb = verb
        method get_headers = headers
        method get_body = body
        
        val path = substr_index uri "?" 0
        val query = substr_index uri "?" 1

        method get_path = path
        method get_query = query
    end

let create (uri: string) (verb: Verb.t) (headers: string list) (body: string) =
    new request uri verb headers body

let get_verb request =
    Verb.create (substr_index request " " 0)

let get_uri request =
    substr_index request " " 1

let get_headers request =
    let lines = Array.of_list (Str.split (Str.regexp "\n") request) in
    if Array.length lines > 1
    then let headers_with_body = Array.sub lines 1 ((Array.length lines) - 1) in
    let rec retain_headers headers remaining =
        (match remaining with
        | [] -> headers
        | (header :: rest) -> if header = ""
        then headers
        else retain_headers (header :: headers) rest) in
    retain_headers [] (Array.to_list headers_with_body)
    else []

let get_body request =
    substr_index request "\n\n" 1

let create_from_literal (request: string) =
    let uri = get_uri request in
    let verb = get_verb request in
    let headers = get_headers request in
    let body = get_body request in
    create uri verb headers body
