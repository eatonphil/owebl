open Request

let test1 = "GET /foo/bar/ HTTP/1.1"

let test2 = "POST /path/script.cgi HTTP/1.0\n\
From: frog@jmarshall.com\n\
\n\
home=Cosby&favorite+flavor=flies";;

let test =
    let _assert req =
        let err = (fun a b -> Printf.eprintf
        "Failed converting request to string:\n%s\nGot:\n%s\n\n" a b) in
    Assert.test req (Request.createFromLiteral req)#toString err in

    _assert test1;

    _assert test2;

    ()
