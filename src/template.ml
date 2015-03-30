module StringMap = Map.Make(String);;

module Context = struct
    type f = string list -> Request.t -> string
    type t = m StringMap.t
    and m =
        | Var of string
        | Fun of f

    let exists (key: string) (ctx: t) : bool =
        StringMap.exists (fun nth_key ctx -> nth_key = key) ctx

    let get (key: string) (ctx: t) : m =
        StringMap.find key ctx

    let add (key: string) (value: m) (ctx: t) : t =
        StringMap.add key value ctx

    let make (l: (string * m) list) : t =
        let ctx = StringMap.empty in
        let rec make_helper l ctx =
            match l with
            | [] -> ctx
            | (key, value) :: tail -> let ctx =
                StringMap.add key value ctx in
            make_helper tail ctx in
        make_helper l ctx
end


(* Template marker. *)
let tm = '`'
let tm_str = String.make 1 tm

let fulfill_key (key: string) (ctx: Context.t) (req: Request.t): string =
    match Str.split (Str.regexp " ") key with
    | [] -> Printf.printf "Template error: no key specified.\n"; ""
    | (key :: args) ->
    if (Context.exists key ctx) then begin
        match Context.get key ctx with
        | Context.Var v -> v
        | Context.Fun f -> f args req
    end
    else begin
        Printf.printf "Template error: key \"%s\" not found.\n" key;
        ""
    end

let fulfillment_index key value index =
    index - (String.length key + 2) + String.length value

let templatize (tmp: string) (ctx: Context.t) (req: Request.t) : string =
    let rec templatize_rec tmp i (in_tmp_key: bool) (tmp_key: string) =
        if i < (String.length tmp) then begin
            let c = tmp.[i] in match c = tm with
            | true -> if (i > 0 && tmp.[i-1] = '\\')
            then let escaped_tmp =
                Str.replace_first (Str.regexp ("\\\\" ^ tm_str)) tm_str tmp in
            templatize_rec escaped_tmp i in_tmp_key tmp_key
            else begin
                if in_tmp_key
                then begin
                    let key_fulfilled =
                        fulfill_key tmp_key ctx req in
                    let new_index =
                        fulfillment_index tmp_key key_fulfilled i in
                    let tmp_key_fulfilled =
                        let key_start = (i - String.length tmp_key - 1) in
                        let previous = String.sub tmp 0 key_start in
                        let current = String.sub tmp key_start (String.length tmp - key_start) in
                        let key_regexp = Str.regexp (tm_str ^ tmp_key ^ tm_str) in
                        previous ^ (Str.replace_first key_regexp key_fulfilled current) in
                    templatize_rec tmp_key_fulfilled (new_index+1) false ""
                end 
                else templatize_rec tmp (i + 1) true ""
            end
            | false -> match in_tmp_key with
                | true ->
                    templatize_rec tmp (i + 1) true (tmp_key ^ (String.make 1 c))
                | false -> 
                    templatize_rec tmp (i + 1) false ""
        end
        else
            (*if in_tmp_key then Printf.printf
            "Missing template end marker of key for request:\n%s\n"
            req#to_string;*)
            tmp in
    templatize_rec tmp 0 false ""
