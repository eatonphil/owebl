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

* standard template library
  * for instance, end-users need not duplicate the "include" code in every OWebl project that needs that functionality
* convert to using recore
  * stdlib alternative
* SSL termination
  * obviously not strictly necessary, but could be a fun optional component
* move from pure forking to async io with forking for larger connection support
* add gzip support, vary header
* set cache headers from a config

## Misc

* add startup information (port, address, etc)
  * something with forking currently precludes this from happening
