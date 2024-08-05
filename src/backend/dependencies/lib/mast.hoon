/*  mast-js  %js  /lib/mast-js/js
:: :: :: ::
::
::  Mast  -  a Sail framework
::
::  [v.1.0.1]
::
::  
::  This library contains a system for building fully dynamic Sail front-ends
::  where all front-end app state and the current state of the display itself
::  live on your ship.
::
::  A small script that is generic to any application is inserted into your Sail
::  and used to establish an Eyre channel, receive display updates from your ship, 
::  and to sync the browser with them.
::  
::  Events on the browser are handled completely within your ship, 
::  without the need to write a single line of JavaScript.
::  You may describe event listeners in your Sail components with attributes like this:
::    =event  "/click/..."
::  The first segment of the path is the event listener name, 
::  with further segments defining an arbitrary endpoint for an event handler on your agent.
::  Events are sent as pokes under a json mark, which can be parsed with the library.
::  You may also return data from the event like this:
::    =return  "/target/value"
::  The first segment is the object to return data from, and the second is the property to return.
::  Data can be returned from the target element, event object, or any other element associated by id.
::  
::  When the display state changes as a result of events initiated on the browser,
::  or from any other kind of event in the agent, updates to the browser containing 
::  only the necessary amount of html to achieve this state are sent and swapped in.
::  
::  
::  The server section contains all of the arms for usage in your app.
::  Rig, plank, and gust are the main arms. See the description of these arms below.
::
::  For more details visit: https://github.com/R-JG/mast
::
:: :: :: ::
|%
+$  view  manx
+$  yard  [url=path sail=gate]
+$  yards  (list yard)
+$  parsed-req  [tags=path data=(map @t @t)]
:: :: :: ::
::
::  Server 
::
:: :: :: ::
::
::  - the rig arm is used to produce a new instance of the display state.
::  - "yards" is the list of your app's routes, each corresponding to a root level Sail component
::    (i.e. a complete document with html, head, and body tags).
::  - "url" is either the request url from Eyre in the context of a direct http request,
::    or the current url (this should be saved in state).
::  - "sail-sample" represents the total sample for each of your root level Sail components 
::    (currently, root level Sail components in yards each need to take the same sample).
::  - rig uses the url to select the matching yard and renders its Sail component.
::  - the newly produced display state should then be used with either plank or gust,
::    and saved as the current display state in the agent.
::
++  rig
  |*  [=yards url=path sail-sample=*]
  ^-  view
  ?~  yards
    (adky (manx sail-404))
  =/  yurl=path  url.i.yards
  ?:  |-
      ?~  url
        %.n
      ?~  yurl
        %.n
      ?.  |(=(i.url i.yurl) =(%$ i.yurl))
        %.n
      ?:  &(=(~ t.url) =(~ t.yurl))
        %.y
      $(url t.url, yurl t.yurl)
    =/  rigd  (adky (manx (sail.i.yards sail-sample)))
    rigd(a.g (mart [[%url (path <url>)] a.g.rigd]))
  $(yards t.yards)
::
::  - the plank arm is used for serving whole pages in response to %handle-http-request pokes,
::    acting as the first point of contact for the app.
::  - plank needs to take some basic information about the page that you are serving:
::  - "app" is the name of the app,
::  - "sub" is the subscription path that the client will subscribe to for receiving display updates,
::  - "ship" is your patp,
::  - "rid" is the Eyre id from the %handle-http-request poke,
::  - "new" is the newly rendered display state produced with rig.
::  - plank produces a list of cards serving the http response.
::    
++  plank
  |=  [app=tape sub=path ship=@p rid=@ta new=view]
  ^-  (list card:agent:gall)
  ?~  c.new  !!
  %^  make-direct-http-cards  rid
    [200 ['Content-Type' 'text/html'] ~]
  :-  ~
  ^-  octs
  %-  as-octt:mimes:html
  %-  en-xml:html
  ^-  manx
  %=  new
    a.g  %-  mart  :^  
      [%app app] 
      [%path <(path sub)>]
      [%ship +:(scow %p ship)]
      a.g.new
    c.i.c  (marl [script-node c.i.c.new])
  ==
::
::  - the gust arm is used for producing a set of display updates for the browser,
::    used typically after making changes to your app's state, and rendering new display data with rig. 
::  - "sub" is the subscription path that was sent initially in plank, where gust will send the updates.
::  - "old" is the display state that is currently saved in your agent's state, 
::    produced some time previously by rig.
::  - "new" is the new display data to be produced with rig just before gust gets used.
::  - gust can be used anywhere you'd make a subscription update (in contrast to plank).
::  - gust produces a single card.
::  
++  gust
  |=  [sub=path old=view new=view]
  ^-  card:agent:gall
  ?~  c.old  !!
  ?~  c.new  !!
  ?~  t.c.old  !!
  ?~  t.c.new  !!
  ?~  a.g.new  !!
  :: ~&  >  (en:json:html [%a (json-algo c.i.t.c.old c.i.t.c.new)])
  :: ~&  >>  (crip (en-xml:html `manx`[[%g ~] (algo c.i.t.c.old c.i.t.c.new)]))
  :^  %give  %fact  ~[sub]
  :-  %json
  !>  ^-  json
  :-  %a
  %+  json-algo
    c.i.t.c.old
  c.i.t.c.new
::
++  parse-json
  |=  j=json
  ^-  parsed-req
  %-  (ot ~[tags+pa data+(om so)]):dejs:format  j
::
++  parse-url
  |=  url=@t
  ^-  path
  %-  paru  (trip url)
::
++  make-css-response
  |=  [rid=@ta css=@t]
  ^-  (list card:agent:gall)
  %^  make-direct-http-cards  rid 
    [200 ['Content-Type' 'text/css'] ~]
  [~ (as-octs:mimes:html css)]
::
++  make-auth-redirect
  |=  rid=@ta
  ^-  (list card:agent:gall)
  %^  make-direct-http-cards  rid
  [307 ['Location' '/~/login?redirect='] ~]  ~
::
++  make-400
  |=  rid=@ta
  ^-  (list card:agent:gall)
  %^  make-direct-http-cards
  rid  [400 ~]  ~
::
++  make-404
  |=  [rid=@ta data=(unit octs)]
  ^-  (list card:agent:gall)
  %^  make-direct-http-cards
  rid  [404 ~]  data
::
++  make-direct-http-cards
  |=  [rid=@ta head=response-header.simple-payload:http data=(unit octs)]
  ^-  (list card:agent:gall)
  :~  [%give %fact ~[/http-response/[rid]] [%http-response-header !>(head)]]
      [%give %fact ~[/http-response/[rid]] [%http-response-data !>(data)]]
      [%give %kick ~[/http-response/[rid]] ~]
  ==
:: :: :: ::
::
:: MARL ALGO
::
:: :: :: ::
++  algo
  |=  [old=marl new=marl]
  =|  i=@ud
  =|  pkey=tape
  =|  acc=marl
  |-  ^-  marl
  ?~  new
    ?.  =(~ old)
      ?:  =(%skip -.-.-.old)
        $(old +.old)
      :_  acc
      :_  ~
      :-  %d
      =/  c=@ud  0
      |-  ^-  mart
      ?~  old
        ~
      :-  :-  (crip (weld "d" <c>)) 
        (old-getv %key a.g.i.old)
      $(old t.old, c +(c))
    acc
  ?:  &(?=(^ old) =(%skip -.-.-.old))
    $(old t.old)
  ?:  =(%m n.g.i.new)
    $(new t.new, i +(i), acc (snoc acc i.new))
  =/  j=@ud  0
  =/  jold=marl  old
  =/  nkey=[n=mane k=tape]  [n.g.i.new (old-getv %key a.g.i.new)]
  |-  ^-  marl
  ?~  new
    !!
  ?~  jold
    %=  ^$
      new  t.new
      i    +(i)
      acc  %+  snoc  acc
        ;n(id <i>, pkey pkey) :: temp pkey insert
          ;+  i.new
        ==
    ==
  ?~  old
    !!
  ?:  =(%skip n.g.i.jold)
    $(jold t.jold, j +(j))
  ?:  =(nkey [n.g.i.jold (old-getv %key a.g.i.jold)])
    ?.  =(0 j)
      =/  n=@ud  0
      =/  nnew=marl  new
      =/  okey=[n=mane k=tape]  [n.g.i.old (old-getv %key a.g.i.old)]
      |-  ^-  marl
      ?~  nnew
        ^^$(old (snoc t.old i.old))
      ?:  =(%m n.g.i.nnew)
        $(nnew t.nnew, n +(n))
      =/  nnky=[n=mane k=tape]  [n.g.i.nnew (old-getv %key a.g.i.nnew)]
      ?.  =(okey nnky)
        $(nnew t.nnew, n +(n))
      ?:  (gte n j)
        =/  aupd=mart  (old-upda a.g.i.old a.g.i.nnew)
        ?~  aupd
          %=  ^^$
            old  c.i.old
            new  c.i.nnew
            pkey  k.nnky
            i    0
            acc
              %=  ^^$
                old  t.old
                new
                  ^-  marl
                  %^  newm  new  n
                  `manx`;m(id <(add n i)>, key k.nnky);
              ==
          ==
        %=  ^^$
          old  c.i.old
          new  c.i.nnew
          pkey  k.nnky
          i    0
          acc
            %=  ^^$
              old  t.old
              new
                ^-  marl
                %^  newm  new  n
                `manx`;m(id <(add n i)>, key k.nnky);
              acc
                :_  acc
                [[%c [[%key k.nnky] aupd]] ~]
            ==
        ==
      =/  aupd=mart  (old-upda a.g.i.jold a.g.i.new)
      ?~  aupd
        %=  ^^$
          old  c.i.jold
          new  c.i.new
          pkey  k.nkey
          i    0
          acc
            %=  ^^$
              old  `marl`(newm old j `manx`;skip;)
              new  t.new
              i    +(i)
              acc
                %+  snoc  acc
                ;m(id <i>, key k.nkey);
            ==
        ==
      %=  ^^$
        old  c.i.jold
        new  c.i.new
        pkey  k.nkey
        i    0
        acc
          %=  ^^$
            old  `marl`(newm old j `manx`;skip;)
            new  t.new
            i    +(i)
            acc
              :-  [[%c [[%key k.nkey] aupd]] ~]
              %+  snoc
                acc
              ;m(id <i>, key k.nkey);
          ==
      ==
    ?:  =(%t- n.g.i.new)
      ?:  =(+.-.+.-.-.+.-.old +.-.+.-.-.+.-.new)
        ^$(old t.old, new t.new, i +(i))
      %=  ^$
        old  t.old
        new  t.new
        i    +(i)
        acc  [i.new acc]
      ==
    =/  aupd=mart  (old-upda a.g.i.old a.g.i.new)
    ?~  aupd
      %=  ^$
        old  c.i.old
        new  c.i.new
        pkey  k.nkey
        i    0
        acc  ^$(old t.old, new t.new, i +(i))
      ==
    %=  ^$
      old  c.i.old
      new  c.i.new
      pkey  k.nkey
      i    0
      acc
        %=  ^$
          old  t.old
          new  t.new
          i    +(i)
          acc
            :_  acc
            [[%c [[%key k.nkey] aupd]] ~]
        ==
    ==
  $(jold t.jold, j +(j))
::
:: :: :: ::
::
:: JSON ALGO
::
:: :: :: ::
++  json-algo
  |=  [old=marl new=marl]
  =|  i=@ud
  =|  pkey=@t
  =|  acc=(list json)
  |-  ^-  (list json)
  ?~  new
    ?~  old
      acc
    ?:  =(%skip- n.g.i.old)
      %=  $
        old  t.old
      ==
    :_  acc      :: node delete case
    ^-  json
    :-  %o
    %-  my
    :~  ['p' [%s 'd']]
        ['q' [%a (turn old |=(m=manx [%s (getv %key a.g.m)]))]]
    ==
  ?:  &(?=(^ old) =(%skip- n.g.i.old))
    %=  $
      old  t.old
    ==
  ?:  =(%move- n.g.i.new)
    %=  $
      new  t.new
      i    +(i)
      acc
        %+  snoc  acc  :: node ;move-; placeholder resolution case
        ^-  json
        :-  %o
        %-  my
        :~  ['p' [%s 'm']]
            ['q' [%s (getv %key a.g.i.new)]]
            ['r' [%n (getv %i a.g.i.new)]]
        ==
    ==
  =|  j=@ud
  =/  jold=marl  old
  =/  nkey=[n=mane k=@t]  [n.g.i.new (getv %key a.g.i.new)]
  |-  ^-  (list json)
  ?~  new
    !!
  ?~  jold
    %=  ^$
      new  t.new
      i    +(i)
      acc
        %+  snoc  acc  :: new node case
        ^-  json
        :-  %o
        %-  my
        :~  ['p' [%s 'n']]
            ['q' [%s pkey]]
            ['r' [%n (scot %ud i)]]
            ['s' [%s (crip (en-xml:html i.new))]]
        ==
    ==
  ?~  old
    !!
  ?:  =(%skip- n.g.i.jold)
    %=  $
      jold  t.jold
      j     +(j)
    ==
  ?:  =(nkey [n.g.i.jold (getv %key a.g.i.jold)])
    ?.  =(0 j)
      =|  n=@ud
      =/  nnew=marl  new
      =/  okey=[n=mane k=@t]  [n.g.i.old (getv %key a.g.i.old)]
      |-  ^-  (list json)
      ?~  nnew
        %=  ^^$
          old  (snoc t.old i.old)
        ==
      ?:  =(%move- n.g.i.nnew)
        %=  $
          nnew  t.nnew
          n     +(n)
        ==
      =/  nnky=[n=mane k=@t]  [n.g.i.nnew (getv %key a.g.i.nnew)]
      ?.  =(okey nnky)
        %=  $
          nnew  t.nnew
          n     +(n)
        ==
      ?:  (gte n j)
        =/  aupd  (upda a.g.i.old a.g.i.nnew)
        %=  ^^$
          old   c.i.old
          new   c.i.nnew
          pkey  k.nnky
          i     0
          acc
            %=  ^^$
              old  t.old
              new
                %^  newm  new  n  :: insert ;move-; placeholder
                ;move-(i (scow %ud (add n i)), key (trip k.nnky));
              acc
                ?:  &(?=(~ del.aupd) ?=(~ new.aupd))
                  acc
                :_  acc         :: node attribute change case
                ^-  json
                :-  %o
                %-  my
                :~  ['p' [%s 'c']]
                    ['q' [%s k.nnky]]
                    ['r' [%a del.aupd]]
                    ['s' [%a new.aupd]]
                ==
            ==
        ==
      =/  aupd  (upda a.g.i.jold a.g.i.new)
      %=  ^^$
        old   c.i.jold
        new   c.i.new
        pkey  k.nkey
        i     0
        acc
          %=  ^^$
            old  (newm old j ;skip-;)
            new  t.new
            i    +(i)
            acc
              =.  acc
                %+  snoc  acc  :: node move case
                ^-  json
                :-  %o
                %-  my
                :~  ['p' [%s 'm']]
                    ['q' [%s k.nkey]]
                    ['r' [%n (scot %ud i)]]
                ==
              ?:  &(?=(~ del.aupd) ?=(~ new.aupd))
                acc
              :_  acc
              ^-  json         :: node attribute change case
              :-  %o
              %-  my
              :~  ['p' [%s 'c']]
                  ['q' [%s k.nkey]]
                  ['r' [%a del.aupd]]
                  ['s' [%a new.aupd]]
              ==
          ==
      ==
    ?:  =(%t- n.g.i.new)
      ?:  ?&  ?=(^ c.i.old)  ?=(^ c.i.new)
              ?=(^ a.g.i.c.i.old)  ?=(^ a.g.i.c.i.new)
              =(v.i.a.g.i.c.i.old v.i.a.g.i.c.i.new)
          ==
        %=  ^$
          old  t.old
          new  t.new
          i    +(i)
        ==
      =/  txt=@t
        ?.  &(?=(^ c.i.new) ?=(^ a.g.i.c.i.new))
          ''
        (crip v.i.a.g.i.c.i.new)
      %=  ^$
        old  t.old
        new  t.new
        i    +(i)
        acc
          :_  acc    :: text node change case
          ^-  json
          :-  %o
          %-  my
          :~  ['p' [%s 't']]
              ['q' [%s (getv %key a.g.i.new)]]
              ['r' [%s txt]]
          ==
      ==
    =/  aupd  (upda a.g.i.old a.g.i.new)
    %=  ^$
      old   c.i.old
      new   c.i.new
      pkey  k.nkey
      i     0
      acc
        %=  ^$
          old  t.old
          new  t.new
          i    +(i)
          acc
            ?:  &(?=(~ del.aupd) ?=(~ new.aupd))
              acc
            :_  acc           :: node attribute change case
            ^-  json
            :-  %o
            %-  my
            :~  ['p' [%s 'c']]
                ['q' [%s k.nkey]]
                ['r' [%a del.aupd]]
                ['s' [%a new.aupd]]
            ==
        ==
    ==
  %=  $
    jold  t.jold
    j     +(j)
  ==
::
++  adky
  |=  root=manx
  |^  ^-  manx
  (tanx root ["" ~])
  ++  tanx
    |=  [m=manx key=(pair tape (list @))]
    ^-  manx
    =/  fkey=@t  (getv %key a.g.m)
    =/  nkey=(pair tape (list @))  ?~(fkey key [((w-co:co 1) `@uw`(mug fkey)) ~])
    =/  ntap=tape  (weld p.nkey ((w-co:co 1) `@uw`(jam q.nkey)))
    ?:  =(%$ n.g.m)
      ;t-
        =key  ntap
        ;+  m
      ==
    %_    m
        a.g
      ^-  mart  
      ?~  fkey
        [[%key ntap] a.g.m]
      a.g.m
        c
      (tarl c.m nkey)
    ==
  ++  tarl
    |=  [m=marl key=(pair tape (list @))]
    =|  i=@
    |-  ^-  marl
    ?~  m  ~
    :-  %+  tanx
          i.m
        key(q [i q.key])
    $(m t.m, i +(i))
  --
::
++  old-getv
  |=  [t=@tas m=mart]
  ^-  tape
  ?~  m
    ~
  ?:  =(n.i.m t)
    v.i.m
  $(m t.m)
::
++  getv
  |=  [t=@tas m=mart]
  ^-  @t
  ?~  m
    ''
  ?:  =(n.i.m t)
    (crip v.i.m)
  $(m t.m)
::
++  old-upda                :: produce a "c" attribute diff
  |=  [om=mart nm=mart]
  =|  acc=mart
  |-  ^-  mart
  ?~  nm
    ?~  om
      acc
    :_  acc
    :-  %rem
    =/  omom=mart  om
    |-  ^-  tape       :: make this better
    ?~  omom
      ~
    =/  nom=tape  +:<n.i.omom>  :: rem case -> whitespace separated attribute names to delete
    |-  ^-  tape
    ?~  nom
      [' ' ^$(omom t.omom)]
    [i.nom $(nom t.nom)]
  =|  i=@ud
  =/  com=mart  om
  |-  ^-  mart
  ?~  nm
    !!
  ?~  com
    ^$(nm t.nm, acc [i.nm acc])
  ?~  om
    !!
  ?:  =(n.i.com n.i.nm)
    ?:  =(v.i.com v.i.nm)
      ^$(om (oust [i 1] (mart om)), nm t.nm)
    %=  ^$
      om  (oust [i 1] (mart om))
      nm  t.nm
      acc  [i.nm acc]
    ==
  $(com t.com, i +(i))
::
++  upda                :: produce a "c" attribute diff
  |=  [om=mart nm=mart]
  =|  acc=[del=(list json) new=(list json)]
  |-  ^+  acc
  ?~  nm
    ?~  om
      acc
    %_    acc
        del
      %+  turn  om
      |=  [n=mane *]
      [%s `@t`?>(?=(@ n) n)]
    ==
  =|  i=@ud
  =/  com=mart  om
  |-  ^+  acc
  ?~  nm
    !!
  ?~  com
    %=  ^$
      nm  t.nm
      new.acc
        :_  new.acc
        :-  %a
        :~  [%s `@t`?>(?=(@ n.i.nm) n.i.nm)]
            [%s (crip v.i.nm)]
        ==
    ==
  ?~  om
    !!
  ?:  =(n.i.com n.i.nm)
    ?:  =(v.i.com v.i.nm)
      %=  ^$
        om  (oust [i 1] (mart om))
        nm  t.nm
      ==
    %=  ^$
      om   (oust [i 1] (mart om))
      nm   t.nm
      new.acc
        :_  new.acc
        :-  %a
        :~  [%s `@t`?>(?=(@ n.i.nm) n.i.nm)]
            [%s (crip v.i.nm)]
        ==
    ==
  %=  $
    com  t.com
    i    +(i)
  ==
::
++  newm                       :: is this identical to snap???
  |=  [ml=marl i=@ud mx=manx]
  =|  j=@ud
  |-  ^-  marl
  ?~  ml
    ~
  :-  ?:  =(i j)
      mx
    i.ml
  $(ml t.ml, j +(j))
::
++  paru
  |=  turl=tape
  ^-  path
  =/  tacc=tape  ~
  =/  pacc=path  ~
  |-
  ?~  turl
    ?~  tacc
      pacc
    (snoc pacc (crip tacc))
  ?:  =('/' i.turl)
    ?~  tacc
      $(turl t.turl)
    %=  $
      turl  t.turl
      tacc  ~
      pacc  (snoc pacc (crip tacc))
    ==
  $(turl t.turl, tacc (snoc tacc i.turl))
:: :: :: ::
::
::  Sail 
::
:: :: :: ::
++  script-node
  ^-  manx
  ;script
    ;+  ;/  (trip mast-js)
  ==
++  sail-404
  ^-  manx
  ;html
    ;head
      ;meta(charset "utf-8");
    ==
    ;body
      ;span: 404
    ==
  ==
::
--