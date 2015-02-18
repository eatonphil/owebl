open Response
open Rule
open Server

let hello_world_handler =
    Handler.create
        (StaticRouteRule.create "/hello" [Verb.GET])
        (SimpleResponse.create "Hello World!")

let server = SimpleServer.create [hello_world_handler];;

server#serve
