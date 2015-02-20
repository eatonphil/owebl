sudo apt-get update -qq
sudo apt-get install -qq ocaml

make test
./test.native
