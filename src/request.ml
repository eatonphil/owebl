type t = <
    get_uri: string;
    get_verb: Verb.t;
    get_version: string;
    get_headers: string list;
    get_body: string;
    get_path: string;
    get_query: string;
    to_string: string
>

let opt_prepend p s =
    if s = ""
    then ""
    else (p ^ s)

class request (verb: Verb.t) (uri: string) (version: string) (headers: string list) (body: string) =
    object(self)
        method get_uri = uri
        method get_verb = verb
        method get_version = version
        method get_headers = headers
        method get_body = body
        
        val path = Utils.substr_index uri "?" 0
        val query = Utils.substr_index uri "?" 1

        method get_path = path
        method get_query = query

        method to_string =
            Printf.sprintf "%s %s %s%s%s"
            (Verb.to_string verb)
            uri
            version
            (opt_prepend "\n" (String.concat "\n" headers))
            (opt_prepend "\n\n" body)
    end

let create (verb: Verb.t) (uri: string) (version: string) (headers: string list) (body: string) =
    new request verb uri version headers body

let get_verb request =
    Verb.create (Utils.substr_index request " " 0)

let get_uri request =
    Utils.substr_index request " " 1

let get_version request =
    Utils.substr_index request " " 2

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
    Utils.substr_index request "\n\n" 1

let create_from_literal (request: string) =
    let verb = get_verb request in
    let uri = get_uri request in
    let version = get_version request in
    let headers = get_headers request in
    let body = get_body request in
    create verb uri version headers body
