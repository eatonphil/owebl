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

open Unix

let timestamp : string =
    let t : tm = localtime (time ()) in
    (* 2015/02/17 21:19:50 *)
    Printf.sprintf "%d/%d/%d %d:%d:%d"
    t.tm_year
    t.tm_mon
    t.tm_mday
    t.tm_hour
    t.tm_min
    t.tm_sec
