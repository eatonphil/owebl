open Recore.Std

module StringMap = Map.Make(String);;

module Context = struct
    type f = string list -> t -> Request.t -> string
    and t = m StringMap.t
    and m =
        | Var of string
        | Fun of f
        | Ctx of t
        | Arr of t list

    let exists (key: string) (ctx: t) : bool =
        StringMap.exists (fun nth_key ctx -> nth_key = key) ctx

    let get (key: string) (ctx: t) : m =
        StringMap.find key ctx

    let add (key: string) value (ctx: t) : t =
        StringMap.add key (value :> m)  ctx

    let make (l: (string * m) list) : t =
        let ctx = StringMap.empty in
        let rec makeHelper l ctx =
            match l with
            | [] -> ctx
            | (key, value) :: tail -> let ctx =
                StringMap.add key value ctx in
            makeHelper tail ctx in
        makeHelper l ctx
end


(* Template marker. *)
let tm_start = "{{"
let tm_end = "}}"


let rec fulfillKey (key: string) (ctx: Context.t) (req: Request.t): string =
    match Str.split (Str.regexp " ") key with
    | [] -> Printf.printf "Template error: no key specified.\n"; ""
    | (key :: args) ->
    if (Context.exists key ctx) then begin
        match Context.get key ctx with
        | Context.Var v -> v
        | Context.Fun f -> f args ctx req
        | Context.Ctx c -> fulfillKey (String.join " " args) c req
        | Context.Arr a -> match args with
            | [] -> Printf.printf "Template error: index not found for key (array): %s" key; ""
            | (ind :: args) -> let c = (List.nth a (int_of_string ind)) in
                fulfillKey (String.join " " args) c req
    end
    else begin
        Printf.printf "Template error: key \"%s\" not found.\n" key;
        ""
    end


let escaped str ind =
    ind <> 0 && str.[ind - 1] = '\\'


let rec getEndIndex str ind =
    match ind < (String.len str - 1) with
    | true ->
        let endi = String.indexOf tm_end str ind in
        if escaped str endi
        then getEndIndex str (ind + 1)
        else endi
    | false -> Printf.printf "Template error: template not terminated.\n"; -1


let templatize (tmp: string) (ctx: Context.t) (req: Request.t) : string =
    let fn ind tmp =
        if ind < (String.len tmp) && escaped tmp ind = false then
            match String.indexOf tm_start tmp ind = ind with
            | true -> let endi = getEndIndex tmp ind in
                if endi = (-1) then (tmp, ind + 1)
                else let starti = ind + String.len tm_start in
                    let key = String.sub tmp starti (endi - starti) in
                    let resolved_key = fulfillKey key ctx req in
                    let resolved_tmp =
                        String.replace (tm_start ^ key ^ tm_end) resolved_key tmp in
                    (resolved_tmp, ind)
            | false -> (tmp, ind + 1)
        else match ind <> 0 && escaped tmp ind with
        | false -> (tmp, ind + 1)
        | true -> let resolved_escape =
                let first_char_str = String.make 1 tm_start.[0] in
            String.replace ({|\|} ^ first_char_str) first_char_str tmp in
            (resolved_escape, ind) in
    String.mapi fn tmp
