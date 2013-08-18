! Copyright © 2013 Greg V <floatboth@me.com>
! This work is free. You can redistribute it and/or modify it under the
! terms of the Do What The Fuck You Want To Public License, Version 2,
! as published by Sam Hocevar. See the COPYING file for more details.

USING: kernel formatting assocs accessors sequences namespaces
       environment math.parser io io.servers
       furnace.actions http.server http.server.dispatchers
       http.server.responses http.server.static html.forms
       http.client urls.secure json json.reader ;
IN: statusboardthings

TUPLE: statusboardthings < dispatcher ;

: get-value ( hsh str -- str ) swap at* drop ;

: get-repos ( str -- hsh )
    "https://api.travis-ci.org/repos?owner_name=%s"
    sprintf http-get nip json> reverse ;

: success? ( -- ? ) "last_build_status" value 0 = ;
: progress? ( -- ? ) "last_build_status" value json-null = ;
: fail? ( -- ? ) success? progress? or not ;

! Actions

: <home-action> ( -- action )
  <page-action>
    { statusboardthings "home" } >>template ;

: <travis-action> ( -- action )
  <page-action>
    "username" >>rest
    [ "username" param get-repos "repos" set-value ] >>init
    { statusboardthings "travis" } >>template ;

! Routes

: <statusboardthings> ( -- dispatcher )
  statusboardthings new-dispatcher
    <home-action>   ""       add-responder
    <travis-action> "travis" add-responder
    "vocab:statusboardthings" <static> "static" add-responder ;

! Running

: run-dev ( -- threaded-server )
  <statusboardthings> main-responder set-global 8080 httpd ;

: run-prod ( -- )
  <statusboardthings> main-responder set-global
  "PORT" os-env string>number httpd wait-for-server ;

MAIN: run-prod
