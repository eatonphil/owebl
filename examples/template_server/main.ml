open Response
open Rule
open Template
open Server

(*
let context = StringMap.empty
let context = StringMap.add "name" (Fulfillment.Variable "Phil") context
let context = StringMap.add "uri()" (Fulfillment.Function (fun req -> req#get_uri)) context
*)

let ctx = Context.make [
    ("name", Fulfillment.Variable "Phil");
    ("uri()", Fulfillment.Function (fun req -> req#get_uri))
]

let handler =
    Handler.create
        (StaticRouteRule.create "/" [Verb.GET])
        (TemplateResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/template_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ~context:ctx
            ())

let server = SimpleServer.create [handler];;

server#serve
