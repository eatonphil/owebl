open Response
open Rule

type t = < getResponse: Request.t -> Response.r >

class handler (rule: RouteRule.t) (response: Response.t) =
    object(self)
        method getResponse (request: Request.t) : Response.r =
            match rule#matches request with
            | RouteRule.Match -> response#getResponse request
            | RouteRule.NoMatch -> Response.Empty
    end

let create (rule: RouteRule.t) (response: Response.t) = new handler rule response
