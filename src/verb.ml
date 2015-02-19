type t = GET | POST

let create (verb: string) : t =
    match verb with
    | "GET" -> GET
    | _ -> POST

let to_string (verb: t) : string =
    match verb with
    | GET -> "GET"
    | _ -> "POST"
