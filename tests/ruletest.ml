open Verb
open Rule

let _ = StaticRouteRule.create "/" [Verb.POST];;
let _ = RegexRouteRule.create "/([])"
