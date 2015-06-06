open Template

let dummy_request =
    Request.create Verb.GET "/" "HTTP/1.1" Request.Headers.empty ""

let context = Context.(empty
    |> add "name"       (Context.Var "Phil")
    |> add "world"      (Context.Var "World")
    |> add "first_name" (Context.Var "Grace")
    |> add "last_name"  (Context.Var "Kelly")
    |> add "img"        (Context.Ctx Context.(empty
        |> add "src"    (Context.Var "/home")
    ))
)

let test =
    let _assert tmp str =
        let err = (fun a b -> Printf.eprintf
            "Failed fulfilling template:\n%s\nExpected:\n%s\nGot:\n%s\n\n" tmp b a) in
        Assert.test (templatize tmp context dummy_request) str err in

    _assert
    "{{world}}"
    "World";

    _assert
    "Hello, {{world}}! My name is {{name}}."
    "Hello, World! My name is Phil.";

    _assert
    "Hello, {{world}}{{world}}! My name is {{name}}"
    "Hello, WorldWorld! My name is Phil";

    _assert
    "<img src='{{img src}}'/>"
    "<img src='/home'/>";

    _assert
    {|\{\{name}}\{\{{{world}}}}|}
    "{{name}}{{World}}";

    ()
