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
        ::  receive state data from the main agent (instead of using remote scry) 
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
        [%click %set-menu-mode]
          =/  menu-val=@ta  
            ?~  t.t.tags.client-poke  ~&('set-menu-mode path missing' !!)
            i.t.t.tags.client-poke
          =.  menu-mode  (^menu-mode menu-val)
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          [(gust:mast /display-updates view new-view) ~]
        ::
        [%click %select-game]
          =/  atom-id-input=@ta
            ?~  t.t.tags.client-poke  ~&('select-game path missing' !!)
            i.t.t.tags.client-poke
          =/  id-val=game-id  (game-id (slav %ud atom-id-input))
          ?:  =(id-val selected-game)
            [~ this]
          =.  selected-game  id-val
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          [(gust:mast /display-updates view new-view) ~]
        ::
        [%click %send-challenge]
          =/  ship-input=@p
            (slav %p (~(got by data.client-poke) '/challenge-ship-input/value'))
          =/  note-input=@t
            (~(got by data.client-poke) '/challenge-note-input/value')
          =/  side-input
            %-  ?(%white %black %random)
            (~(got by data.client-poke) '/challenge-side-input/value')
          =/  practice-input=?
            =('true' (~(got by data.client-poke) '/challenge-practice-input/checked'))
          :_  this
          :_  ~
          :*  %pass   /send-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%send-challenge ship-input side-input note-input practice-input])
          ==
        ::
        [%click %accept-challenge]
          =/  challenger=@p
            %+  slav  %p
            ?~  t.t.tags.client-poke  ~&('accept-challenge path missing' !!)
            i.t.t.tags.client-poke
          :_  this
          :_  ~
          :*  %pass   /accept-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%accept-challenge challenger])
          ==
        ::
        [%click %decline-challenge]
          =/  challenger=@p
            %+  slav  %p
            ?~  t.t.tags.client-poke  ~&('decline-challenge path missing' !!)
            i.t.t.tags.client-poke
          :_  this
          :_  ~
          :*  %pass   /decline-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%decline-challenge challenger])
          ==
        ::
        [%click %test-resign]
          =/  atom-id-input=@t  (~(got by data.client-poke) '/target/id')
          =/  id-val=game-id  (game-id (slav %ud atom-id-input))
          :_  this
          :_  ~
          :*  %pass   /test-resign
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%resign id-val])
          ==
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
  ~&  >  'on-agent hit'
  ~&  >  wire
  ~&  >  sign
  ?+  wire  (on-agent:def wire sign)
    ::
    [%challenges ~]
      ?+  -.sign  (on-agent:def wire sign)
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-update
              =/  update  !<(chess-update q.cage.sign)
              ?+  -.update  (on-agent:def wire sign)
                ::
                %challenge-sent
                  =.  challenges-sent
                    (~(put by challenges-sent) who.update challenge.update)
                  ~&  >  'new in challenges-sent'
                  ~&  >  challenges-sent
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-received
                  =.  challenges-received
                    (~(put by challenges-received) who.update challenge.update)
                  ~&  >  'new in challenges-received'
                  ~&  >  challenges-received
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-resolved
                  =.  challenges-sent
                    (~(del by challenges-sent) who.update)
                  ~&  >  'del in challenges-sent'
                  ~&  >  challenges-sent
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-replied
                  =.  challenges-received
                    (~(del by challenges-received) who.update)
                  ~&  >  'del in challenges-received'
                  ~&  >  challenges-received
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
              ==
          ==
      ==
    ::
    [%active-games ~]
      ?+  -.sign  (on-agent:def wire sign)
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-game-active
              =/  new-game  !<(active-game-state q.cage.sign)
              =.  games  (~(put by games) game-id.game.new-game new-game)
              ~&  >  'new in games'
              ~&  >  games
              =/  new-view=manx  (rig:mast routes url sail-sample)
              :_  this(view new-view)
              [(gust:mast /display-updates view new-view) ~]
          ==
      ==
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