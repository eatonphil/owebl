open Response
open Rule
open Verb
open Server

let handler =
    Handler.create
        (RegexRouteRule.create "/[a-zA-Z]*99/" [GET])
        (FileResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/file_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ())

let server = SimpleServer.create [handler];;

server#serve
