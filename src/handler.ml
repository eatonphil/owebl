open Response
open Rule

type t = < get_response: Request.t -> Response.r >

class handler (rule: RouteRule.t) (response: Response.t) =
    object(self)
        method get_response (request: Request.t) : Response.r =
            match rule#matches request with
            | RouteRule.Match -> response#get_response request
            | RouteRule.NoMatch -> Response.Empty
    end

let create (rule: RouteRule.t) (response: Response.t) = new handler rule response
