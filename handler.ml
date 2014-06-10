class handler rule (callback : string -> string -> string) (methods : string list) =
    object(self)
        method matches test_string test_method =
            let r = Str.regexp rule in
            match Str.string_match r test_string 0 with
            | false -> false
            | true -> List.exists (fun nth_method -> nth_method = test_method) methods
        method get_callback = callback
    end