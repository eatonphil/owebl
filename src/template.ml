module Fulfillment = struct
    type f = Request.t -> string
    type t =
        | Variable of string
        | Function of f
end

module StringMap = Map.Make(String);;

(* Template marker. *)
let tm = '`';;

let fulfill_key (key: string) (ctx: Fulfillment.t StringMap.t) : string =
    match StringMap.find key ctx with
    | Fulfillment.Variable v -> v
    | _ -> ""

let fulfillment_index key value index =
    index - (String.length key) + (String.length value)

let templatize (tmp: string) (ctx: Fulfillment.t StringMap.t) : string =
    let rec templatize_rec tmp i (in_tmp_key: bool) (tmp_key: string) =
        if i < (String.length tmp) then begin
            let c = tmp.[i] in match c = tm with
            | true -> begin
                if in_tmp_key
                then let key_fulfilled =
                    fulfill_key tmp_key ctx in
                let new_index =
                    fulfillment_index tmp_key key_fulfilled i in
                let tmp_key_fulfilled =
                    let tm_str = String.make 1 tm in
                    let key_regexp = Str.regexp (tm_str ^ tmp_key ^ tm_str) in
                    Str.replace_first key_regexp key_fulfilled tmp in
                templatize_rec tmp_key_fulfilled (new_index + 1) false ""
                else templatize_rec tmp (i + 1) true ""
            end
            | false -> templatize_rec tmp (i + 1) in_tmp_key (tmp_key ^ (String.make 1 c))
        end
        else tmp in
    templatize_rec tmp 0 false ""
