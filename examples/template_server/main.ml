open Response
open Rule
open Template
open Server

let context = Context.make [
    ("first_name", Context.Var "Phil");
    ("last_name", Context.Var " Eaton");
    ("uri()", Context.Fun (fun (req: Request.t) -> req#get_uri))
]

let handler =
    Handler.create
        (StaticRouteRule.create "/" [Verb.GET])
        (TemplateResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/template_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ~context:context
            ())

let server = SimpleServer.serve [handler]
