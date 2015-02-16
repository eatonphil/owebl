module RouteRule = struct
    open Verb
    open Request

    type m = Match | NoMatch

    type t = < matches: Request.t -> m >

    class virtual rule (uri: string) (verbs: Verb.t list) =
        object
            method virtual matches : Request.t -> m
        end
end

module StaticRouteRule = struct
    open Verb
    open Request

    include RouteRule

    class static_rule (uri: string) (verbs: Verb.t list) =
        object
            inherit rule uri verbs

            method matches (request: Request.t) = match (uri = request#get_uri) with
            | true -> (match List.exists (fun nth_verb -> nth_verb = request#get_verb) verbs with
                | true -> Match
                | false -> NoMatch)
            | false -> NoMatch
        end

    let create (uri: string) (verbs: Verb.t list) = new static_rule uri verbs
end
