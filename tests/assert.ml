let test a b err =
    try
        assert (a = b);
        Printf.printf "Test successful:\n%s\n%s\n\n" a b
    with _ -> err a b
