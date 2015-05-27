open Utils

let test =
    let err = (fun a b -> Printf.eprintf
        "Failed getting substring '.' -1:\n%s\nGot:\n%s\n\n" a b) in

    Assert.test "png" (substr_index "/my/img/this.png" "\\." (-1)) err;

    ()
