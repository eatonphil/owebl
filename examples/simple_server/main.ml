open Response
open Rule
open Verb
open Server

let handler =
    Handler.create
        (StaticRouteRule.create "/" [GET])
        (SimpleResponse.create "Hello World!")

let server = SimpleServer.create [handler];;

server#serve
