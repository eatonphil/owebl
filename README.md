OWebl
====

OWebl is a simple web framework for OCaml. While other frameworks do exist
for writing web applications in OCaml (ocsigen, js_of_caml), these are
massive and difficult to maneuver.

Look at how easy it is to use:

```ocaml
open Handler
open Verb
open Response
open Request
open Rule
open Server

let hello_world_handler =
    Handler.create
        (StaticRouteRule.create "/hello" [Verb.GET])
        (SimpleResponse.create "Hello World!");;

let server = SimpleServer.create [index_handler; hello_world_handler];;
```

To build the example server:

```
$ ocamlbuild -libs unix,str -Is src examples/simple_server/main.native
$ ./main.native
```

Alternatively, use make:

```
make simpleserver
```

Features
--------

- Be awesome
- Make things faster

Installation
------------

Install OWebl by running:

    git clone https://github.com/eatonphil/owebl

To build, simply include Unix and Str modules and reference the path
to owebl/src in your ocamlbuild line:

    ocamlbuild -libs unix,str -Is path/to/owebl/src my_server.native

Contribute
----------

- Issue Tracker: github.com/eatonphil/owebl/issues
- Source Code: github.com/eatonphil/owebl

Support
-------

If you are having issues, please let us know.
Email me at me@eatonphil.com

License
-------

The project is licensed under the BSD license.
