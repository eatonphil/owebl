module Fulfillment = struct
    type t =
        | Variable of string
        | Function of Request.t -> string
end

module StringMap = Map.Make(String)

module Context = struct
    (* String maps to either a string or a function that takes a request and
     * returns a string. Having a function alone gives great used in conjuction
     * with closures. *)
    type t = Fullfillment.t StringMap
end

(* Template marker. *)
val tm = "%"
let tm_regexp= Str.regexp ("[^\\\\]%[ ]*[a-zA-Z0-9_]*\([ ]*([ ]*)[ ]*\)?")

let templatize (tmp: string) (ctx: Context.t) (req: Request.t) : string =
    let templatize_key key : string =
        if Map.exists key ctx then
            let value = Map.find key ctx in
            begin
                if Str.match_string func_regexp value 0
                then let func = value in func (req)
                else value
            end
        else (Printf.sprintf "Error, key \"%s\" not found." str) in
    Str.global_replace tm_regexp templatize_key tmp
