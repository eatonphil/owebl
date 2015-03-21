OCAMLMAKEFILE = OCamlMakeFile

LIB_PACK_NAME = owebl
RESULT = owebl
SOURCES = src/utils.ml src/verb.ml src/request.ml src/template.ml src/response.ml src/rule.ml src/handler.ml src/server.ml
PACKS = unix str

all: native-code-library byte-code-library
install:
	ocamlfind install owebl META owebl.o owebl.cmi owebl.cma owebl.cmxa owebl.a
uninstall: libuninstall

include $(OCAMLMAKEFILE)
