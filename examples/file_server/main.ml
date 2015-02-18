open Response
open Rule
open Server

let index_handler =
    Handler.create
        (RegexRouteRule.create "/[a-zA-Z]*99/" [Verb.GET])
        (FileResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/file_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ())

let server = SimpleServer.create [index_handler];;

server#serve
