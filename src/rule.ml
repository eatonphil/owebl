module RouteRule = struct
    type m = Match | NoMatch

    type t = < verbMatches: Verb.t -> m; matches: Request.t -> m >

    class virtual rule (uri: string) (verbs: Verb.t list) =
        object
            method verbMatches (verb: Verb.t) : m =
                match List.exists (fun nth_verb -> nth_verb = verb) verbs with
                | true -> Match
                | false -> NoMatch

            method virtual matches : Request.t -> m
        end
end

module StaticRouteRule = struct
    include RouteRule

    class static_rule (uri: string) (verbs: Verb.t list) =
        object
            inherit rule uri verbs as super

            method matches (request: Request.t) : m =
                match (uri = request#getPath) with
                | true -> super#verbMatches request#getVerb
                | false -> NoMatch
        end

    let create (uri: string) (verbs: Verb.t list) = new static_rule uri verbs
end

module RegexRouteRule = struct
    include RouteRule

    class regex_rule (uri: string) (verbs: Verb.t list) =
        object
            inherit rule uri verbs as super

            val re = Str.regexp uri

            method matches (request: Request.t) : m =
                match (Str.string_match re request#getPath 0) with
                | true -> super#verbMatches request#getVerb
                | false -> NoMatch
        end

    let create (uri: string) (verbs: Verb.t list) = new regex_rule uri verbs
end
