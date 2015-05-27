open Response
open Rule
open Server

let first_handler =
    Handler.create
        (RegexRouteRule.create "/[a-zA-Z]*99/" [Verb.GET])
        (FileResponse.create
            ~static_file:(FileResponse.StaticFile "examples/file_server/index.html")
            ())

let second_handler =
    Handler.create
        (StaticRouteRule.create "/img" [Verb.GET])
        (FileResponse.create
            ~static_file:(FileResponse.StaticFile "examples/file_server/test.png")
            ())

let server = SimpleServer.serve [first_handler; second_handler]
