let success a b = 
    Printf.printf "Test successful:\n%s\n%s\n\n" a b

let test a b err =
    try
        assert (a = b);
        success a b
    with _ -> err a b
