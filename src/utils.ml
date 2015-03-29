let substr_index (str: string) (delimiter: string) (index: int) =
    let split = Str.split (Str.regexp delimiter) str in
    let length = Array.length (Array.of_list split) in
    if index >= length || index < 0 then ""
    else List.nth split index

let read_from_fd fd read_timeout =
    let buff_size = 4096 in
    let buff = Bytes.create buff_size in
    let rec read_data last_data current_data =
        if last_data = current_data then current_data
        else let last_data = current_data in
        let (read_fds, _, _) = Unix.select [fd] [] [] read_timeout in
        let rec read_all_helper data =
            match read_fds with
            | [] -> data
            | (read_fd :: _) -> begin
                let r = Unix.read read_fd buff 0 buff_size in
                let data = data ^ (String. sub buff 0 r) in
                if r < buff_size then read_data last_data data
                else read_all_helper data
            end in
        read_all_helper current_data in
    read_data "_" ""

let read_file_to_string file_name =
    let file_fd = Unix.openfile file_name [] 0 in
    let file_st = read_from_fd file_fd (-1.0) in
    let _ = Unix.close file_fd in
    file_st

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
