! Copyright (C) 2013 Val Packett.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel formatting assocs accessors namespaces environment math.parser io
       furnace.actions http.server http.server.dispatchers http.server.responses html.forms io.servers
       http.client urls.secure json.reader ;
IN: statusboardthings

TUPLE: statusboardthings < dispatcher ;

: get-value ( hsh str -- str ) swap at* drop ;

: get-repos ( str -- hsh ) "https://api.travis-ci.org/repos?owner_name=%s" sprintf http-get nip json> ;

! Actions

: <home-action> ( -- action )
  <page-action>
    { statusboardthings "home" } >>template ;

: <travis-action> ( -- action )
  <page-action>
    "username" >>rest
    [ "myfreeweb" get-repos "repos" set-value ] >>init
    { statusboardthings "travis" } >>template ;

! Routes

: <statusboardthings> ( -- dispatcher )
  statusboardthings new-dispatcher
    <home-action>   ""       add-responder
    <travis-action> "travis" add-responder ;

! Running

: run-dev ( -- threaded-server )
  <statusboardthings> main-responder set-global 8080 httpd ;

: run-prod ( -- )
  <statusboardthings> main-responder set-global "PORT" os-env string>number httpd wait-for-server ;

MAIN: run-prod
