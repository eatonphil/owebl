let print_i i = print_int i; print_newline ()
let print_s s = print_string s; print_newline ()

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