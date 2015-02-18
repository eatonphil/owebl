open Response
open Rule
open Template
open Server
open Verb

let context = Context.make [
    ("name", Context.Var "Phil");
    ("uri()", Context.Fun (fun (req: Request.t) -> req#get_uri))
]

let handler =
    Handler.create
        (StaticRouteRule.create "/" [GET])
        (TemplateResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/template_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ~context:context
            ())

let server = SimpleServer.create [handler];;

server#serve
