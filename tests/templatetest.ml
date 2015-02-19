open Template

let dummy_request =
    Request.create "/" Verb.GET [] ""

let context = Context.make [
    ("name", Context.Var "Phil");
    ("world", Context.Var "World")
]

let test =
    assert ((templatize "Hello, `world`! My name is `name`." context) =
        "Hello World! My name is Phil.");

    assert ((templatize "Hello, `world``world`! My name is `name`" context) =
        "Hello, WorldWorld! My name is Phil");

    assert ((templatize "\`name\``name`\``name`" context) =
        "`name`Phil`Phil");
    ()
