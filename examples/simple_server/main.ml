open Response
open Rule
open Template
open Server

let index_handler =
    Handler.create
        (StaticRouteRule.create "/" [Verb.POST; Verb.GET])
        (FileResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/simple_server/templates")
            ~static_file:(FileResponse.StaticFile "/index.html")
            ())

let context = StringMap.empty
let context = StringMap.add "name" (Fulfillment.Variable "Phil") context

let tmpl_handler =
    Handler.create
        (StaticRouteRule.create "/templates/" [Verb.GET])
        (TemplateResponse.create
            ~template_dir:(FileResponse.TemplateDir "examples/simple_server/templates")
            ~static_file:(FileResponse.StaticFile "/template.html")
            ~context:context
            ())

let regex_handler =
    Handler.create
        (RegexRouteRule.create "/[a-zA-Z]*99/" [Verb.GET])
        (SimpleResponse.create "You matched the regex!")

let hello_world_handler =
    Handler.create
        (StaticRouteRule.create "/hello" [Verb.GET])
        (SimpleResponse.create "Hello World!")

let server = SimpleServer.create [
    index_handler;
    hello_world_handler;
    regex_handler;
    tmpl_handler];;

server#serve
