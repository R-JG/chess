/-  *chess
/+  *chess, default-agent, mast
/=  index  /app/chess-ui/index
/=  style  /app/chess-ui/style
|%
+$  source  @p
+$  view  manx
+$  url  path
+$  ui-state
  $:  =view  =url
      =games  =challenges-sent  =challenges-received
      =menu-mode  =selected-game  =selected-piece
      =available-moves
  ==
+$  card  card:agent:gall
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
=|  [=source ui-state]
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
      :*  bowl  games  challenges-sent  challenges-received
          menu-mode  selected-game  selected-piece
          available-moves
      ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-init
  ^-  (quip card _this)
  =.  source
    ?:  =(%earl (clan:title our.bowl))
      (sein:title our.bowl now.bowl our.bowl)
    our.bowl
  :_  this(+.state *ui-state)
  :~  [%pass /bind %arvo %e %connect `/chess %chess-ui]
      [%pass /challenges %agent [source %chess] %watch /challenges]
      [%pass /active-games %agent [source %chess] %watch /active-games]
      [%pass /get-state %agent [source %chess] %poke %chess-ui-agent !>([%get-state ~])]
  ==
++  on-save
  !>(~)
++  on-load
  |=  *
  ^-  (quip card _this)
  =.  source
    ?:  =(%earl (clan:title our.bowl))
      (sein:title our.bowl now.bowl our.bowl)
    our.bowl
  :_  this(+.state *ui-state)
  :~  [%pass /bind %arvo %e %connect `/chess %chess-ui]
      [%pass /challenges %agent [source %chess] %watch /challenges]
      [%pass /active-games %agent [source %chess] %watch /active-games]
      [%pass /get-state %agent [source %chess] %poke %chess-ui-agent !>([%get-state ~])]
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::
    %chess-ui-agent
      =/  act  !<(chess-ui-agent vase)
      ?+  -.act  (on-poke:def mark vase)
        %give-state
          :-  ~
          %=  this
            games                games.act
            challenges-sent      challenges-sent.act
            challenges-received  challenges-received.act
          ==
      ==
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
        [%click %test-challenge]
          :_  this
          :_  ~
          :*  %pass   /test-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%send-challenge ~zod %white 'test' &])
          ==
        ::
        [%click %test-decline]
          :_  this
          [[%pass ~ %agent [source %chess] %poke %chess-user-action !>([%decline-challenge ~zod])] ~]
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
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
    ::
    [%challenges ~]
      ~&  'challenges agent path hit'
      ~&  sign
      `this
    ::
    [%active-games ~]
      ~&  'active-games agent path hit'
      ~&  sign
      `this
    ::
    [%test-challenge ~]
      ~&  'test-challenge poke res path hit'
      ~&  sign
      `this
    ::
  ==
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