module Verb = struct
    type t = GET | POST

    let create (verb: string) : t =
        match verb with
        | "GET" -> GET
        | _ -> POST
end
