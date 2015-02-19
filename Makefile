DEPS = src
LIBS = unix,str

LFLAGS = -libs $(LIBS)
CFLAGS = -Is $(DEPS)

SS = examples/simple_server/main

simpleserver: $(DEPS)/*.ml $(SS).ml
	ocamlbuild $(LFLAGS) $(CFLAGS) $(SS).native

FS = examples/file_server/main

fileserver: $(DEPS)/*.ml $(FS).ml
	ocamlbuild $(LFLAGS) $(CFLAGS) $(FS).native

TS = examples/template_server/main

templateserver: $(DEPS)/*.ml $(TS).ml
	ocamlbuild $(LFLAGS) $(CFLAGS) $(TS).native

test: $(DEPS)/*.ml tests/*.ml
	ocamlbuild $(LFLAGS) $(CFLAGS),tests tests/test.native

clean:
	rm -rf _build *.native *.byte
