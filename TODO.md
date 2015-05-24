# TODO

## Tests
* write more tests

## Recipes

* database integration
* session management
* blog engine

## Projects

* a simple CMS
  * meetowebl.com desperately needs this

## Architecture

* file-type deduction (or lookup)
  * sending a file of a "unique" type (not text/html) requires explicitly setting the file-type
* standard template library
  * for instance, end-users need not duplicate the "include" code in every OWebl project that needs that functionality
* SSL termination
  * obviously not strictly necessary, but could be a fun optional component
* move from pure forking to async io with forking for larger connection support
