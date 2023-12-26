/-  *chess
/+  *chess, default-agent, mast
/=  index  /app/chess-ui/index
/=  style  /app/chess-ui/style
|%
+$  view  manx
+$  url  path
+$  menu-mode  ?(%settings %games %challenges)
+$  selected-game  ?(game-id ~)
+$  selected-piece  ?([square=chess-square piece=chess-piece] ~)
+$  available-moves  (set chess-square)
+$  ui-state
  $:  =view  =url
  ==
+$  card  card:agent:gall
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
=|  ui-state
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
    ::  ::  ::
    routes  
      %-  limo
      :~  [/chess index]
      ==
    sail-sample
      :*  bowl
      ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-init  [~ this]
++  on-save  !>(~)
++  on-load
  |=  *
  :_  this(state *ui-state)
  [[%pass /bind %arvo %e %connect `/chess %chess-ui] ~]
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::
    %handle-http-request
      =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
      ?.  authenticated.req
        [(make-auth-redirect:mast eyre-id) this]
      ?+    method.request.req  [(make-400:mast eyre-id) this]
        %'GET'
          =/  req-url=path  (parse-url:mast url.request.req)
          ?:  =(/chess/style req-url)
            [(make-css-response:mast eyre-id style) this]
          =/  new-view=manx  (rig:mast routes req-url sail-sample)
          :-  (plank:mast "chess-ui" /display-updates our.bowl eyre-id new-view)
          this(view new-view, url req-url)
      ==
    ::
    %json
      ?>  =(our.bowl src.bowl)
      =/  client-poke  (parse-json:mast !<(json vase))
      ?.  &(?=(^ tags.client-poke) ?=(^ t.tags.client-poke))
        ~&('tags are missing from client poke' (on-poke:def [mark vase]))
      ?+  [i.tags.client-poke i.t.tags.client-poke]
          ~&('client event not handled' (on-poke:def [mark vase]))
        ::
        [%click %test]
          `this
        ::
      ==
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-watch:def path)
    [%http-response *]
      [~ this]
    [%display-updates *]
      [~ this]
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%bind ~] wire)
    (on-arvo:def [wire sign-arvo])
  ?.  ?=([%eyre %bound *] sign-arvo)
    (on-arvo:def [wire sign-arvo])
  ~?  !accepted.sign-arvo
    %eyre-rejected-squad-binding
  `this
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-fail   on-fail:def
--