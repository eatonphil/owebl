let total = ref 0
let passed = ref 0

let success a b = 
    Printf.printf "Test successful:\n%s\n%s\n\n" a b

let test a b err =
    total := !total + 1;
    try
        assert (a = b);
        success a b;
        passed := !passed + 1
    with _ -> err a b
