open Recore.Std

module Headers = String.Map

let toStrings delim map =
    let fn key value accum =
        let kv = (Printf.sprintf "%s%s%s" key delim value) in
        (kv :: accum) in
    Headers.fold fn map []


let toString delim kvDelim map =
    let fn first second =
        if first = "" then second
        else Printf.sprintf "%s%s%s" first delim second in
    List.fold_left fn "" (toStrings kvDelim map)

type h = string Headers.t

type t = <
    getUri: string;
    getVerb: Verb.t;
    getVersion: string;
    getHeaders: h;
    getBody: string;
    getPath: string;
    getQuery: string;
    toString: string
>


let optPrepend p s =
    if s = ""
    then ""
    else (p ^ s)


class request (verb: Verb.t) (uri: string) (version: string) (headers: h) (body: string) =
    object(self)
        method getUri = uri
        method getVerb = verb
        method getVersion = version
        method getHeaders = headers
        method getBody = body
        
        val path = String.nthFromSplit "?" uri 0
        val query = String.nthFromSplit "?" uri 1

        method getPath = path
        method getQuery = query

        method toString =
            Printf.sprintf "%s %s %s%s%s"
            (Verb.toString verb)
            uri
            version
            (optPrepend "\n" (toString "\n" ": " headers))
            (optPrepend "\n\n" body)
    end


let getVerb request =
    Verb.create (String.nthFromSplit " " request 0)


let getUri request =
    String.nthFromSplit " " request 1


let getVersion request =
    String.nthFromSplit " " (String.nthFromSplit "\n" request 0) 2


let getHeaders request : h =
    let lines = Array.fromList (String.split "\n" request) in
    if Array.len lines > 1
    then let headers_with_body =
        Array.sub lines 1 ((Array.len lines) - 1) in
        let rec retainHeaders headers remaining =
            match remaining with
            | [] -> headers
            | (header :: rest) -> if header = "" then headers
            else let (key, value) =
                (String.nthFromSplit ": " header 0,
                 String.nthFromSplit ": " header 1) in
            retainHeaders (Headers.add key value headers) rest in
        retainHeaders Headers.empty (Array.toList headers_with_body)
    else Headers.empty


let getBody request =
    let rec getBodyHelper body index =
        let body_section = String.nthFromSplit "\n\n" request index in
        if body_section = "" then body
        else getBodyHelper (body ^ body_section) (index + 1) in
    getBodyHelper "" 1


let create (verb: Verb.t) (uri: string) (version: string) (headers: h) (body: string) =
    new request verb uri version headers body


let createFromLiteral (request: string) =
    let verb = getVerb request in
    let uri = getUri request in
    let version = getVersion request in
    let headers = getHeaders request in
    let body = getBody request in
    create verb uri version headers body
