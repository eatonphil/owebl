module RouteRule = struct
    type m = Match | NoMatch

    type t = < verb_matches: Verb.t -> m; matches: Request.t -> m >

    class virtual rule (uri: string) (verbs: Verb.t list) =
        object
            method verb_matches (verb: Verb.t) : m =
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
                match (uri = request#get_path) with
                | true -> super#verb_matches request#get_verb
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
                match (Str.string_match re request#get_path 0) with
                | true -> super#verb_matches request#get_verb
                | false -> NoMatch
        end

    let create (uri: string) (verbs: Verb.t list) = new regex_rule uri verbs
end
