open Template

let dummy_request =
    Request.create Verb.GET "/" "HTTP/1.1" [] ""

let context = Context.make [
    ("name", Context.Var "Phil");
    ("world", Context.Var "World");
    ("first_name", Context.Var "Grace");
    ("last_name", Context.Var "Kelly");
    ("img", Context.Ctx (Context.make [
        ("src", Context.Var "/home")
    ]));
]

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
