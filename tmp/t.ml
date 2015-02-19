let t = Str.replace_first (Str.regexp ("\\\\" ^ "`")) "`" "\\`foo";;
print_string (t^"\n")
