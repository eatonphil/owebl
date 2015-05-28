module MimeTypes = Map.Make(String);;

type t = string MimeTypes.t

let default_type = "text/html"

(* Add additional file extension -> mime-type mappings here*)
let m = MimeTypes.(empty
    |> add "html"   "text/html"
    |> add "htm"    "text/html"
    |> add "css"    "text/css"
    |> add "png"    "image/png"
    |> add "jpg"    "image/jpeg"
    |> add "jpeg"   "image/jpeg"
    |> add "js"     "application/javascript"
    |> add "json"   "application/json"
    |> add "ico"    "image/x-icon"
)

let get_file_type file_name = Utils.substr_index file_name "\\." (-1)

let get_mime_type file_name =
    let file_type = get_file_type file_name in
    if MimeTypes.exists (fun nth_key ctx -> nth_key = file_type) m
    then MimeTypes.find file_type m
    else default_type
