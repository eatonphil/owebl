DEPS = src
LIBS = unix,str

LFLAGS = -libs $(LIBS)
CFLAGS = -Is $(DEPS)

SS = examples/simple_server/main

simpleserver: $(DEPS)/*.ml $(SS).ml
	ocamlbuild $(LFLAGS) $(CFLAGS) $(SS).native

clean:
	rm -rf _build *.native *.byte
