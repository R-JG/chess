/-  *chess-ui
/+  chess, default-agent, mast
/=  render  /app/chess-ui/index
|%
+$  ui  manx
+$  ui-state
  $:  =games  =challenges-sent  =challenges-received  =menu-mode
      =notification  =expand-game-options  =expand-challenge-form
      =selected-game-id  =selected-game-pieces
      =selected-piece  =available-moves
  ==
+$  card  card:agent:gall
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
=+  (pin:mast ui-state)
%-  agent:mast
=|  [=source ui-state]
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
    sail-sample
      :*  source  bowl  games  challenges-sent  challenges-received
          menu-mode  notification  expand-game-options  expand-challenge-form
          selected-game-id  selected-game-pieces
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
  :~  (bind-url:mast dap.bowl /chess)
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
  :~  (bind-url:mast dap.bowl /chess)
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
          =:  games                games.act
              challenges-sent      challenges-sent.act
              challenges-received  challenges-received.act
            ==
          [~ this]
      ==
    ::
    %handle-http-request
      =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
      ?.  authenticated.req
        [(make-auth-redirect:mast eyre-id) this]
      ?+  method.request.req  [(make-400:mast eyre-id) this]
        ::
          %'GET'
        =^  cards  rig.mast
          (gale:mast our.bowl dap.bowl eyre-id src.bowl (render sail-sample))
        [cards this]
        ::
      ==
    ::
    %mast-event
      ?>  =(our.bowl src.bowl)
      =+  !<(eve=event:mast vase)
      ?+  path.eve  ~|(%no-event-handler (on-poke:def [mark vase]))
        ::
        [%click %set-menu-mode *]
          =/  menu-val=@ta  
            ?~  t.t.path.eve  ~&('set-menu-mode path missing' !!)
            i.t.t.path.eve
          =:  menu-mode  (^menu-mode menu-val)
              expand-challenge-form  |
            ==
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
        ::
        [%click %toggle-challenge-form *]
          =.  expand-challenge-form  !expand-challenge-form
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
        ::
        [%click %toggle-game-options *]
          =.  expand-game-options  !expand-game-options
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
        ::
        [%click %select-game *]
          =/  atom-id-input=@ta
            ?~  t.t.path.eve  ~&('select-game path missing' !!)
            i.t.t.path.eve
          =/  id-val=game-id  (game-id (slav %ud atom-id-input))
          ?:  =(id-val selected-game-id)
            [~ this]
          =:  selected-game-id  id-val
              selected-game-pieces
                ^-  ui-board
                %-  %~  rep  by  board.position:(~(got by games) id-val)
                |=  [[k=chess-square v=chess-piece] acc=ui-board]
                [[(weld <(@ -.k)> <(@ +.k)>) k v] acc]
              notification         ~
              selected-piece       ~
              available-moves      ~
              expand-game-options  |
            ==
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
        ::
        [%click %select-piece *]
          ?~  selected-game-id  ~&('no selected game when selecting piece' !!)
          ?.  ?&  ?=(^ t.t.path.eve)  ?=(^ t.t.t.path.eve)
                  ?=(^ t.t.t.t.path.eve)  ?=(^ t.t.t.t.t.path.eve)
              ==
            ~&('select-piece path missing' (on-poke:def [mark vase]))
          =/  selection
            :-  (chess-square [i.t.t.path.eve (slav %ud i.t.t.t.path.eve)])
            (chess-piece [i.t.t.t.t.path.eve i.t.t.t.t.t.path.eve])
          =:  selected-piece  ?:(=(selected-piece selection) ~ selection)
              notification  ~
              available-moves
                %-  silt
                %~  moves-and-threatens
                  %~  with-piece-on-square  with-board.chess
                    board.position:(~(got by games) selected-game-id)
                selection
            ==
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
        ::
        [%click %move-piece *]
          ?~  selected-game-id  
            ~&('no selected game for move-piece' (on-poke:def [mark vase]))
          ?~  selected-piece  
            ~&('no selected piece for move-piece' (on-poke:def [mark vase]))
          ?.  &(?=(^ t.t.path.eve) ?=(^ t.t.t.path.eve))
            ~&('move-piece path missing' (on-poke:def [mark vase]))
          =/  to  (chess-square [i.t.t.path.eve (slav %ud i.t.t.t.path.eve)])
          =.  available-moves  ~
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          :_  this
          :_  cards
          :*  %pass   /move-piece
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%make-move selected-game-id %move chess-square.selected-piece to ~])
          ==
        ::
        [%click %send-challenge *]
          =/  ship-input=@p
            (slav %p (~(got by data.eve) '/challenge-ship-input/value'))
          =/  note-input=@t
            (~(got by data.eve) '/challenge-note-input/value')
          =/  side-input
            %-  ?(%white %black %random)
            (~(got by data.eve) '/challenge-side-input/value')
          =/  practice-input=?
            =('true' (~(got by data.eve) '/challenge-practice-input/checked'))
          :_  this
          :_  ~
          :*  %pass   /send-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%send-challenge ship-input side-input note-input practice-input])
          ==
        ::
        [%click %accept-challenge *]
          =/  challenger=@p
            %+  slav  %p
            ?~  t.t.path.eve  ~&('accept-challenge path missing' !!)
            i.t.t.path.eve
          :_  this
          :_  ~
          :*  %pass   /accept-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%accept-challenge challenger])
          ==
        ::
        [%click %decline-challenge *]
          =/  challenger=@p
            %+  slav  %p
            ?~  t.t.path.eve  ~&('decline-challenge path missing' !!)
            i.t.t.path.eve
          :_  this
          :_  ~
          :*  %pass   /decline-challenge
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%decline-challenge challenger])
          ==
        ::
        [%click %resign *]
          ?~  selected-game-id
            ~&('selected-game-id missing from resign' !!)
          :_  %=  this
                selected-game-id  ~
                selected-piece    ~
                available-moves   ~
                expand-game-options  |
              ==
          :_  ~
          :*  %pass   /resign
              %agent  [source %chess]
              %poke   %chess-user-action
              !>([%resign selected-game-id])
          ==
        ::
      ==
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  [~ this]
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-leave  on-leave:def
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-peek:def path)
    [%x %style ~]
      :*  ~  ~  %css
      !>  .^  @
      :~  %cx  (scot %p p.byk.bowl)  q.byk.bowl  (scot %da p.r.byk.bowl) 
          %app  %chess-ui  %style  %css
      ==  ==  ==
    [%x %img @ta ~]
      =/  piece  (chess-piece-type -.+.+.path)
      :*  ~  ~  %svg
      !>  .^  @
      :~  %cx  (scot %p p.byk.bowl)  q.byk.bowl  (scot %da p.r.byk.bowl) 
          %app  %chess-ui  %img  piece  %svg
      ==  ==  ==
    [%x %background ~]
      :*  ~  ~  %png
      !>  .^  @
      :~  %cx  (scot %p p.byk.bowl)  q.byk.bowl  (scot %da p.r.byk.bowl) 
          %app  %chess-ui  %img  %background  %png
      ==  ==  ==
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
    ::
    [%move-piece ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?.  ?&  ?=(^ p.sign)  ?=(^ u.p.sign)  =(%leaf -.i.u.p.sign)
                  ?=(^ (find "invalid" +.i.u.p.sign))
              ==
            (on-agent:def wire sign)
          =:  notification  "Invalid move"
              selected-piece  ~
            ==
          =^  cards  rig.mast
            (gust:mast src.bowl (render sail-sample))
          [cards this]
      ==
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
                  =:  expand-challenge-form  |
                      challenges-sent
                        (~(put by challenges-sent) who.update challenge.update)
                    ==
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
                ::
                %challenge-received
                  =.  challenges-received
                    (~(put by challenges-received) who.update challenge.update)
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
                ::
                %challenge-resolved
                  =.  challenges-sent
                    (~(del by challenges-sent) who.update)
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
                ::
                %challenge-replied
                  =.  challenges-received
                    (~(del by challenges-received) who.update)
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
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
              =^  cards  rig.mast
                (gust:mast src.bowl (render sail-sample))
              :_  this
              :_  cards
              :*  %pass   /game-updates 
                  %agent  [source %chess] 
                  %watch  /game/(scot %da game-id.chess-game-data)/updates
              ==
          ==
      ==
    ::
    [%game-updates ~]
      ?+  -.sign  (on-agent:def wire sign)
        %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
            %chess-update
              =/  update  !<(chess-update q.cage.sign)
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
                    ?:  =(source opponent.u.game)
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
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
                ::
                %result
                  =:  games  (~(del by games) game-id.update)
                      selected-game-id  ~
                      selected-game-pieces  ~
                      selected-piece  ~
                      available-moves  ~
                    ==
                  =^  cards  rig.mast
                    (gust:mast src.bowl (render sail-sample))
                  [cards this]
                ::
              ==
          ==
      ==
    ::
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
