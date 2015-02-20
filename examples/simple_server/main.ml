open Response
open Rule
open Server

let handler =
    Handler.create
        (StaticRouteRule.create "/" [Verb.GET])
        (SimpleResponse.create "Hello World!")

let server = SimpleServer.serve [handler]
