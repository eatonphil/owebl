open Handler
open Verb
open Response
open Request
open Rule

let index_handler = Handler.create (StaticRouteRule.create "/" [Verb.POST;
Verb.GET]) (FileResponse.create ());;

open Server

let server = SimpleServer.create [index_handler];;
server#serve
