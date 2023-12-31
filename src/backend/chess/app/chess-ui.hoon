/-  *chess
/+  chess, default-agent, mast
/=  index  /app/chess-ui/index
/=  style  /app/chess-ui/style
|%
+$  source  @p
+$  view  $~([[%html ~] [[%head ~] ~] [[%body ~] ~] ~] manx)
+$  url  path
+$  ui-state
  $:  =view  =url
      =games  =challenges-sent  =challenges-received
      =menu-mode  =selected-game-id  =selected-game-pieces
      =selected-piece  =available-moves
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
          menu-mode  selected-game-id  selected-game-pieces
          selected-piece  available-moves
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
        ::
        ::  receive state data from the main agent (instead of using remote scry)
        ::  requested on http get
        %give-state
          =:  games                games.act
              challenges-sent      challenges-sent.act
              challenges-received  challenges-received.act
            ==
          =?  selected-game-pieces  !=(~ selected-game-id)
            ^-  ui-board
            %-  %~  rep  by  board.position:(~(got by games) (game-id selected-game-id))
            |=  [[k=chess-square v=chess-piece] acc=ui-board]
            [[(weld <(@ -.k)> <(@ +.k)>) k v] acc]
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          [(gust:mast /display-updates view new-view) ~]
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
          :_  this(view new-view, url req-url)
          :-  [%pass /get-state %agent [source %chess] %poke %chess-ui-agent !>([%get-state ~])]
          (plank:mast "chess-ui" /display-updates our.bowl eyre-id new-view)
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
          ?:  =(id-val selected-game-id)
            [~ this]
          =:  selected-game-id  id-val
              selected-game-pieces
                ^-  ui-board
                %-  %~  rep  by  board.position:(~(got by games) id-val)
                |=  [[k=chess-square v=chess-piece] acc=ui-board]
                [[(weld <(@ -.k)> <(@ +.k)>) k v] acc]
            ==
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          [(gust:mast /display-updates view new-view) ~]
        ::
        [%click %select-piece]
          ?~  selected-game-id  ~&('no selected game when selecting piece' !!)
          ?.  ?&  ?=(^ t.t.tags.client-poke)  ?=(^ t.t.t.tags.client-poke)
                  ?=(^ t.t.t.t.tags.client-poke)  ?=(^ t.t.t.t.t.tags.client-poke)
              ==
            ~&('select-piece path missing' (on-poke:def [mark vase]))
          =/  selection
            :-  (chess-square [i.t.t.tags.client-poke (slav %ud i.t.t.t.tags.client-poke)])
            (chess-piece [i.t.t.t.t.tags.client-poke i.t.t.t.t.t.tags.client-poke])
          =:  selected-piece  ?:(=(selected-piece selection) ~ selection)
              available-moves
                %-  silt
                %~  moves-and-threatens
                  %~  with-piece-on-square  with-board.chess
                    board.position:(~(got by games) selected-game-id)
                selection
            ==
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          [(gust:mast /display-updates view new-view) ~]
        ::
        [%click %move-piece]
          ?~  selected-game-id  
            ~&('no selected game for move-piece' (on-poke:def [mark vase]))
          ?~  selected-piece  
            ~&('no selected piece for move-piece' (on-poke:def [mark vase]))
          ?.  &(?=(^ t.t.tags.client-poke) ?=(^ t.t.t.tags.client-poke))
            ~&('move-piece path missing' (on-poke:def [mark vase]))
          =/  to  (chess-square [i.t.t.tags.client-poke (slav %ud i.t.t.t.tags.client-poke)])
          =.  available-moves  ~
          =/  new-view=manx  (rig:mast routes url sail-sample)
          :_  this(view new-view)
          :~  (gust:mast /display-updates view new-view)
              :*  %pass   /move-piece
                  %agent  [source %chess]
                  %poke   %chess-user-action
                  !>([%make-move selected-game-id %move chess-square.selected-piece to ~])
          ==  ==
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
  ::  ~&  >>  'on-agent'
  ::  ~&  >>  wire
  ::  ~&  >  sign
  ?+  wire  (on-agent:def wire sign)
    ::
    [%challenges ~]
      ?+  -.sign  (on-agent:def wire sign)
        ::
        %kick
          :_  this
          :_  ~
          [%pass /challenges %agent [source %chess] %watch /challenges]
        ::
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-update
              =/  update  !<(chess-update q.cage.sign)
              ?+  -.update  (on-agent:def wire sign)
                ::
                %challenge-sent
                  =.  challenges-sent
                    (~(put by challenges-sent) who.update challenge.update)
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-received
                  =.  challenges-received
                    (~(put by challenges-received) who.update challenge.update)
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-resolved
                  =.  challenges-sent
                    (~(del by challenges-sent) who.update)
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
                %challenge-replied
                  =.  challenges-received
                    (~(del by challenges-received) who.update)
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
              ==
          ==
      ==
    ::
    [%active-games ~]
      ?+  -.sign  (on-agent:def wire sign)
        ::
        %kick
          :_  this
          :_  ~
          [%pass /active-games %agent [source %chess] %watch /active-games]
        ::
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-game-active
              =/  chess-game-data  !<(chess-game q.cage.sign)
              =/  opponent
                ?:(=(source white.chess-game-data) black.chess-game-data white.chess-game-data)
              =/  new-game=active-game-state  
                :*  chess-game-data
                    *chess-position
                    *fen-repetition=(map @t @ud)
                    special-draw-available=%.n
                    auto-claim-special-draws=%.n
                    sent-draw-offer=%.n
                    got-draw-offer=%.n
                    sent-undo-request=%.n
                    got-undo-request=%.n
                    opponent
                    :: XX: need challenger's practice-game selection
                    practice-game=%.n
                ==
              =.  games  (~(put by games) game-id.chess-game-data new-game)
              =/  new-view=manx  (rig:mast routes url sail-sample)
              :_  this(view new-view)
              :~  (gust:mast /display-updates view new-view)
                  :*  %pass   /game-updates 
                      %agent  [source %chess] 
                      %watch  /game/(scot %da game-id.chess-game-data)/updates
              ==  ==
          ==
      ==
    ::
    [%game-updates ~]
      ?+  -.sign  (on-agent:def wire sign)
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-update
              =/  update  !<(chess-update q.cage.sign)
              ~&  >  'GAME UPDATE'
              ~&  >>  update
              ?+  -.update  (on-agent:def wire sign)
                ::
                %position
                  =/  from-data=tape  (trip p.move.update)
                  =/  to-data=tape  (trip q.move.update)
                  =/  from=chess-square
                    ?.  &(?=(^ from-data) ?=(^ t.from-data))
                      ~&('game-updates: data missing' !!)
                    (chess-square [i.from-data (slav %ud i.t.from-data)])
                  =/  to=chess-square
                    ?.  &(?=(^ to-data) ?=(^ t.to-data))
                      ~&('game-updates: data missing' !!)
                    (chess-square [i.to-data (slav %ud i.t.to-data)])
                  =/  game=(unit active-game-state)  (~(get by games) game-id.update)
                  ?~  game  ~&('game-updates: data missing' !!)
                  =/  piece=(unit chess-piece)  (~(get by board.position.u.game) from)
                  ?~  piece  
                    ::  because %position is hit twice if we are facing ourselves:
                    ::  ignore the second (where the piece has already been moved).
                    ?:  =(our.bowl opponent.u.game)
                      `this
                    ~&('game-updates: ui data missing' !!)
                  =/  en-passant-capture=?(chess-square ~)
                    ?:  ?&  =(%pawn +.u.piece)  !=(-.from -.to)
                            !(~(has by board.position.u.game) to)
                        ==
                      [-.to +.from]
                    ~
                  =.  board.position.u.game
                    (~(put by (~(del by board.position.u.game) from)) to u.piece)
                  =?  board.position.u.game  ?=(^ en-passant-capture)
                    (~(del by board.position.u.game) en-passant-capture)
                  =.  moves.game.u.game
                    %+  snoc  moves.game.u.game
                    ::  XX: add proper into=(unit chess-promotion) instead of ~
                    [[%move from to ~] position.update san.update]
                  =.  games  (~(put by games) game-id.update u.game)
                  =?  selected-game-pieces  =(game-id.update selected-game-id)
                    |-
                    ?~  selected-game-pieces  ~
                    ?:  ?|  =(to chess-square.i.selected-game-pieces)
                            =(en-passant-capture chess-square.i.selected-game-pieces)
                        ==
                      $(selected-game-pieces t.selected-game-pieces)                      
                    :-  ?.  =(from chess-square.i.selected-game-pieces)
                          i.selected-game-pieces
                        [key.i.selected-game-pieces to chess-piece.i.selected-game-pieces]
                    $(selected-game-pieces t.selected-game-pieces)
                  =/  new-view=manx  (rig:mast routes url sail-sample)
                  :_  this(view new-view)
                  [(gust:mast /display-updates view new-view) ~]
                ::
              ==
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