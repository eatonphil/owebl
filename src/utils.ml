let substr_index (str: string) (delimiter: string) (index: int) =
    let split = Str.split (Str.regexp delimiter) str in
    let length = Array.length (Array.of_list split) in
    if index >= length || index < 0 then ""
    else List.nth (Str.split (Str.regexp delimiter) str) index

(* http://stackoverflow.com/questions/5774934/how-do-i-read-in-lines-from-a-text-file-in-ocaml *)
let read_file filename = 
	let lines = ref [] in
	let chan = open_in filename in
	try
  		while true; do
    	lines := input_line chan :: !lines
  		done; []
	with End_of_file ->
		close_in chan;
  		List.rev !lines

let read_file_to_string filename = String.concat "\n" (read_file filename)

let pad_int i l p prepend =
    let s = string_of_int i in begin
        if (String.length s) < l
        then begin
            let rec pad s =
                match String.length s = l with
                | true -> s
                | false -> if prepend
                then pad (p ^ s)
                else pad (s ^ p) in
            pad s
        end
        else s
    end

open Unix
let timestamp : string =
    let t : tm = localtime (time ()) in
    (* 2015/02/17 21:19:50 *)
    Printf.sprintf "%d/%s/%s %s:%s:%s"
    (t.tm_year + 1900)
    (pad_int t.tm_mon 2 "0" true)
    (pad_int t.tm_mday 2 "0" true)
    (pad_int t.tm_hour 2 "0" true)
    (pad_int t.tm_min 2 "0" true)
    (pad_int t.tm_sec 2 "0" true)
