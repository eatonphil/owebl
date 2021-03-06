open Mime

let test =
    let err = (fun a b -> Printf.eprintf
        "Failed getting mime type:\n%s\nGot:\n%s\n\n" a b) in

    Assert.test "image/png" (Mime.getMimeType "/my/img/this.png") err;

    ()
