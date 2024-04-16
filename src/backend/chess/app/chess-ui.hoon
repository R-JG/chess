/-  *chess-ui
/+  chess, default-agent
|%
+$  data
  $%  [%sel p=@t]
      [%act p=@t]
      [%form p=@t q=(map @t @t)]
  ==
+$  ui-state
  $:  =games  =challenges-sent  =challenges-received
      =menu-mode  =notification  =expand-game-options  =expand-challenge-form
      =selected-game-id  =selected-game-pieces
      =selected-piece  =available-moves
  ==
+$  card  card:agent:gall
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
=|  [=source ui-state]
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
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
      [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
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
      [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
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
        %give-state
      =:  games                games.act
          challenges-sent      challenges-sent.act
          challenges-received  challenges-received.act
        ==
      [~ this]
    ==
    ::
      %homunculus
    ?>  =(our.bowl src.bowl)
    =/  dat  !<(data vase)
    ?+  -.dat  !!
        %act
      =/  pat=path  (stab p.dat)
      ?~  pat  !!
      ?+  i.pat  !!
        ::
          %set-menu-mode
        =/  menu-val=@ta  
          ?~  t.pat  ~&('set-menu-mode path missing' !!)
          i.t.pat
        =:  menu-mode  (^menu-mode menu-val)
            expand-challenge-form  |
          ==
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
        ==
        ::
          %toggle-challenge-form
        =.  expand-challenge-form  !expand-challenge-form
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
        ==
        ::
          %toggle-game-options
        =.  expand-game-options  !expand-game-options
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
        ==
        ::
          %select-game
        =/  atom-id-input=@ta
          ?~  t.pat  ~&('select-game path missing' !!)
          i.t.pat
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
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
        ==
        ::
          %select-piece
        ?~  selected-game-id  ~&('no selected game when selecting piece' !!)
        ?.  ?&  ?=(^ t.pat)  ?=(^ t.t.pat)
                ?=(^ t.t.t.pat)  ?=(^ t.t.t.t.pat)
            ==
          ~&('select-piece path missing' (on-poke:def [mark vase]))
        =/  selection
          :-  (chess-square [i.t.pat (slav %ud i.t.t.pat)])
          (chess-piece [i.t.t.t.pat i.t.t.t.t.pat])
        =:  selected-piece   ?:(=(selected-piece selection) ~ selection)
            notification     ~
            available-moves
              %-  silt
              %~  moves-and-threatens
                %~  with-piece-on-square  with-board.chess
                  board.position:(~(got by games) selected-game-id)
              selection
          ==
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
        ==
        ::
          %move-piece
        ?~  selected-game-id  
          ~&('no selected game for move-piece' (on-poke:def [mark vase]))
        ?~  selected-piece  
          ~&('no selected piece for move-piece' (on-poke:def [mark vase]))
        ?.  &(?=(^ t.pat) ?=(^ t.t.pat))
          ~&('move-piece path missing' (on-poke:def [mark vase]))
        =/  to  (chess-square [i.t.pat (slav %ud i.t.t.pat)])
        =.  available-moves  ~
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
            :*  %pass   /move-piece
                %agent  [source %chess]
                %poke   %chess-user-action
                !>([%make-move selected-game-id %move chess-square.selected-piece to ~])
        ==  ==
        ::
          %accept-challenge
        =/  challenger=@p
          %+  slav  %p
          ?~  t.pat  ~&('accept-challenge path missing' !!)
          i.t.pat
        :_  this
        :_  ~
        :*  %pass   /accept-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%accept-challenge challenger])
        ==
        ::
          %decline-challenge
        =/  challenger=@p
          %+  slav  %p
          ?~  t.pat  ~&('decline-challenge path missing' !!)
          i.t.pat
        :_  this
        :_  ~
        :*  %pass   /decline-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%decline-challenge challenger])
        ==
        ::
          %resign
        ?~  selected-game-id
          ~&('selected-game-id missing from resign' !!)
        :_  %=  this
              selected-game-id     ~
              selected-piece       ~
              available-moves      ~
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
      ::
        %form
      =/  pat=path  (stab p.dat)
      ?~  pat  !!
      ?+  i.pat  !!
        ::
          %send-challenge
        =/  ship-input=@p
          =/  n=tape  (trip (~(got by q.dat) 'challenge-ship-input'))
          ?>  ?=(^ n)
          =?  n  !=('~' i.n)  ['~' n]
          (slav %p (crip n))
        =/  note-input=@t
          (~(got by q.dat) 'challenge-note-input')
        =/  side-option-white=@t
          (~(got by q.dat) 'side-option-white')
        =/  side-option-black=@t
          (~(got by q.dat) 'side-option-black')
        =/  side-option-random=@t
          (~(got by q.dat) 'side-option-random')
        =/  practice-input=?
          =('%.y' (~(got by q.dat) 'challenge-practice-checkbox'))
        =/  challenge-side=?(%white %black %random)
          ?:  =('%.y' side-option-white)  %white
          ?:  =('%.y' side-option-black)  %black
          %random
        :_  this
        :_  ~
        :*  %pass   /send-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%send-challenge ship-input challenge-side note-input practice-input])
        ==
        ::
      ==
    ==


        ::
        ::  [%click %offer-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from offer-draw' !!)
        ::    :_  this
        ::    :_  ~
        ::    :*  %pass   /offer-draw
        ::        %agent  [source %chess]
        ::        %poke   %chess-user-action
        ::        !>([%offer-draw selected-game-id])
        ::    ==
        ::  ::
        ::  [%click %accept-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from accept-draw' !!)
        ::    :_  this
        ::    :_  ~
        ::    :*  %pass   /accept-draw
        ::        %agent  [source %chess]
        ::        %poke   %chess-user-action
        ::        !>([%accept-draw selected-game-id])
        ::    ==
        ::  ::
        ::  [%click %decline-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from decline-draw' !!)
        ::    =/  current-game  (~(got by games) selected-game-id)
        ::    =.  got-draw-offer.current-game  |
        ::    =.  games  (~(put by games) selected-game-id current-game)
        ::    =/  new-view=manx  (rig:mast routes url sail-sample)
        ::    :_  this(view new-view)
        ::    :~  (gust:mast /display-updates view new-view)
        ::        :*  %pass   /decline-draw
        ::            %agent  [source %chess]
        ::            %poke   %chess-user-action
        ::            !>([%decline-draw selected-game-id])
        ::    ==  ==
        ::
      
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
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?>  =(our.bowl src.bowl)
  !!
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ::  ~&  >>  'on-agent'
  ::  ~&  >>  wire
  ::  ~&  >  sign
  ?+  wire  (on-agent:def wire sign)
    ::
      [%move-piece ~]
    ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
      ?.  ?&  ?=(^ p.sign)  ?=(^ u.p.sign)  =(%leaf -.i.u.p.sign)
              ?=(^ (find "invalid" +.i.u.p.sign))
          ==
        (on-agent:def wire sign)
      =:  notification    "Invalid move"
          selected-piece  ~
        ==
      :_  this
      :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
      ==
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
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
          ::
            %challenge-received
          =.  challenges-received
            (~(put by challenges-received) who.update challenge.update)
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
          ::
            %challenge-resolved
          =.  challenges-sent
            (~(del by challenges-sent) who.update)
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
          ::
            %challenge-replied
          =.  challenges-received
            (~(del by challenges-received) who.update)
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
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
        :_  this
        :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
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
        ::  ~&  >  'GAME UPDATE'
        ::  ~&  >>  update
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
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
          ::
          ::  %draw-offered
          ::    =/  game-to-update  (~(get by games) game-id.update)
          ::    ?~  game-to-update  ~&('game not found for chess-update draw-offered' !!)
          ::    =.  games
          ::      (~(put by games) game-id.update u.game-to-update(got-draw-offer &))
          ::    =/  new-view=manx  (rig:mast routes url sail-sample)
          ::    :_  this(view new-view)
          ::    [(gust:mast /display-updates view new-view) ~]
          ::
            %result
          =:  games                 (~(del by games) game-id.update)
              selected-game-id      ~
              selected-game-pieces  ~
              selected-piece        ~
              available-moves       ~
            ==
          :_  this
          :~  [%pass /elem %agent [our.bowl %homunculus] %poke %elem !>(index)]
          ==
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
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
|%
++  index
  ^-  manx
  ;box(w "100%", h "100%", cb "cyan")
    ;layer(fx "end", fy "center")
      ;+  game-options
    ==
    ;layer(fx "center", fy "center")
      ;+  chessboard
      ;box(w "30", h "24", ml "6", mt "1", cb "white", cf "black", fl "column")
        ;+  game-panel
        ;+  menu
      ==
    ==
  ==
::
++  menu
  ^-  manx
  ;scroll(w "100%", h ?~(selected-game-id "100%" "70%"), fl "column")
    ;box(w "100%", px "1", pt "1")
      ;select(w "48%", p "1", cf "white", cb "magenta", fx "center")
        =d    ?:(?=(%challenges menu-mode) "bold" "")
        =act  "/set-menu-mode/challenges"
        ;+  ;/  "Challenges"
      ==
      ;select(w "48%", p "1", cf "white", cb "blue", fx "center")
        =d    ?:(?=(%games menu-mode) "bold" "")
        =act  "/set-menu-mode/games"
        ;+  ;/  "Games"
      ==
    ==
    ;+  ?-  menu-mode
          %challenges  challenges-menu
          %games       games-menu
        ==
  ==
::
++  challenges-menu
  ^-  manx
  ;box(w "100%", px "1", pt "1", fl "column")
    ;+  ?:  expand-challenge-form
          ;txt(d "underline"): Send a Challenge:
        ;select(cb "magenta", cf "white", sel-d "blink")
          =act  "/toggle-challenge-form"
          ;+  ;/  ">Send a Challenge<"
        ==
    ;+  ?.  expand-challenge-form
          ;null;
        challenge-form
    ;+  ?:  =(~ challenges-sent)
          ;null;
        ;box(mt "1", fl "column")
          ;txt(d "underline"): Sent Challenges:
          ;box(fl "column")
            ;*  %+  turn  ~(tap by challenges-sent)
                |=  [=ship =chess-challenge]
                ;box(fl "column")
                  ;txt: {"To: {<ship>}"}
                  ;txt: {"Your side: {(trip challenger-side.chess-challenge)}"}
                ==
          ==
        ==
    ;txt(mt "1", d "underline"): Received Challenges:
    ;+  ?:  =(~ challenges-received)
          ;txt: You have no challenges. 
        ;box(fl "column")
          ;*  %+  turn  ~(tap by challenges-received)
            |=  [=ship =chess-challenge]
            ;box(fl "column")
              ;txt: {"Challenger: {<ship>}"}
              ;txt: {"Their side: {(trip challenger-side.chess-challenge)}"}
              ;box
                ;select(mx "1", cb "magenta", cf "white", sel-d "blink")
                  =act  "/accept-challenge/{<ship>}"
                  ;+  ;/  ">Accept<"
                ==
                ;select(mx "1", cb "magenta", cf "white", sel-d "blink")
                  =act  "/decline-challenge/{<ship>}"
                  ;+  ;/  ">Decline<"
                ==
              ==
            ==
        ==
  ==
::
++  challenge-form
  ^-  manx
  ;form(p "1", cb "#c7e4ff", fl "column", key "/send-challenge")
    ;box(mb "1")
      ;txt(mr "2"): Ship:
      ;input(key "challenge-ship-input");
    ==
    ;box(mb "1")
      ;txt(mr "2"): Note:
      ;input(key "challenge-note-input");
    ==
    ;box(mb "1", fl "column")
      ;txt: Side:
      ;radio
        ;txt: White
        ;checkbox(key "side-option-white");
        ;txt(ml "1"): Black
        ;checkbox(key "side-option-black");
        ;txt(ml "1"): Random
        ;checkbox(key "side-option-random");
      ==
    ==
    ;box(mb "1")
      ;txt(mr "2"): Practice?
      ;checkbox(key "challenge-practice-checkbox");
    ==
    ;submit(h "1", cb "magenta", cf "white", sel-d "blink"): >Send Challenge<
  ==
::
++  games-menu
  ^-  manx
  ?:  =(~ games)
    ;box(w "100%", p "1", fl "column")
      ;txt: You currently have no games.
    ==
  ;box(w "100%", h "5", p "1", fl "column")
    ;*  %+  turn  ^-((list [game-id active-game-state]) ~(tap by games))
      |=  [=game-id =active-game-state]
      ;select(ml "2", sel-d "underline")
        =act  "/select-game/{<(@ game-id)>}"
        ;+  ;/  "Opponent: {<opponent.active-game-state>}"
      ==
  ==
::
++  game-panel
  ^-  manx
  ?~  selected-game-id
    ;box(w "0", h "0");
  =/  current-game  (~(got by games) selected-game-id)
  =/  num-moves=@ud  (lent moves.game.current-game)
  =/  side-turn=tape  ?:((bean (mod num-moves 2)) "White" "Black")
  ;box(w "100%", h "30%", b "light", fl "column", fx "center")
    ;txt: {"Opponent: {<opponent.current-game>}"}
    ;txt: {"Turn: {<+(num-moves)>}"}
    ;txt: {side-turn}
    ;select(mt "1", cb "black", cf "white", sel-d "blink")
      =act  "/toggle-game-options"
      ;+  ;/  ">Options<"
    ==
  ==
::
++  game-options
  ^-  manx
  ?.  expand-game-options
    ;null;
  ;box(w "21", h "5", mr "6", cb "black", cf "white", fx "center", fy "center")
    ;select(mr "6", cb "magenta", sel-d "blink", act "/resign"): >Resign<
    ;select(cb "magenta", sel-d "blink", act "/toggle-game-options"): X
  ==
::
:: ++  pieces-on-board
::   ^-  manx
::   =/  game-to-render=(unit active-game-state) 
::     ?~  selected-game-id  ~
::     (~(get by games) selected-game-id)
::   ?~  game-to-render
::     ;div(class "pieces-container");
::   ;div(class "pieces-container")
::     ;*  %+  turn  selected-game-pieces
::       |=  [key=tape =chess-square =chess-piece]
::       =/  trans-x=tape  ?:  =(%a -.chess-square)  "0"
::         "{<(sub (@ -.chess-square) 97)>}00%"
::       =/  trans-y=tape  ?:  =(%1 +.chess-square)  "0"
::         "-{<(sub (@ +.chess-square) 1)>}00%"
::       =/  ownership=bean
::         ?-  -.chess-piece
::           %white  =(source white.game.u.game-to-render)
::           %black  =(source black.game.u.game-to-render)
::         ==
::       =/  is-its-turn=bean
::         ?:  (bean (mod (lent moves.game.u.game-to-render) 2))
::           =(%white -.chess-piece)
::         =(%black -.chess-piece)
::       ;div
::         =key    key
::         =class  "piece {(trip -.chess-piece)} on-{(get-color chess-square)} {?:(&(ownership is-its-turn) "act" "")} {?:(&(?=(^ selected-piece) =(chess-square -.selected-piece)) "sel" "")}"
::         =style  "transform: translate({trans-x}, {trans-y});"
::         =event  ?.(ownership "" "/click/select-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}/{(trip -.chess-piece)}/{(trip +.chess-piece)}")
::         ;img(src "/~/scry/chess-ui/img/{(trip +.chess-piece)}.svg");
::       ==
::   ==
::
++  chessboard
  ^-  manx
  =/  game-to-render=(unit active-game-state) 
    ?~  selected-game-id  ~
    (~(get by games) selected-game-id)
  =/  side-turn=tape
    ?~  game-to-render  ~
    ?:  (bean (mod (lent moves.game.u.game-to-render) 2)) 
      "white"
    "black"
  ;box(w "52", h "26", px "1", b "heavy", fl "row-wrap", cf ?~(side-turn "cyan" side-turn))
    ;*  %+  turn  square-cells
      |=  =chess-square
      =/  pie=(unit chess-piece)
        ?~  game-to-render  ~
        (~(get by board.position.u.game-to-render) chess-square)
      =/  is-its-turn=bean
        ?:  |(?=(~ pie) ?=(~ game-to-render))  |
        ?:  (bean (mod (lent moves.game.u.game-to-render) 2))
          =(%white -.u.pie)
        =(%black -.u.pie)
      ?.  (~(has in available-moves) chess-square)
        ;box(h "3", w "6", cb (get-color chess-square), cf "cyan")
          ;*  ?^(pie ~[(make-piece chess-square u.pie is-its-turn |)] ~)
        ==
      ?^  pie
        ;select(h "3", w "6", cb (get-color chess-square), cf "magenta")
          =act  "/move-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}"
          ;+  (make-piece chess-square u.pie is-its-turn &)
        ==
      ;select(h "3", w "6", cb (get-color chess-square), cf "magenta", b "double", act "/move-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}");
  ==
::
++  make-piece
  |=  [=chess-square =chess-piece is-its-turn=bean threaten=bean]
  ^-  manx
  ?:  threaten
    ;box(w "100%", h "1", mx "1", mt "1", d "bold", cf "magenta")
      ;+  ;/  (trip +.chess-piece)
    ==
  ;select(w "100%", h "1", mx "1", mt "1", d "bold", sel-d "blink", cb ?:(?=(%white -.chess-piece) "#FFFFFF" "#000000"), cf ?:(?=(%white -.chess-piece) "black" "white"))
    =act  ?:(is-its-turn "/select-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}/{(trip -.chess-piece)}/{(trip +.chess-piece)}" "")
    ;+  ;/  (trip +.chess-piece)
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  get-color
  |=  =chess-square
  ^-  tape
  ?:  (bean (mod (@ -.chess-square) 2))
    ?:  (bean (mod (@ +.chess-square) 2))
      "black"
    "white"
  ?:  (bean (mod (@ +.chess-square) 2))
    "white"
  "black"
::
++  square-cells
  ^-  (list chess-square)
  :~
    [%a %8]  [%b %8]  [%c %8]  [%d %8]  [%e %8]  [%f %8]  [%g %8]  [%h %8]
    [%a %7]  [%b %7]  [%c %7]  [%d %7]  [%e %7]  [%f %7]  [%g %7]  [%h %7]
    [%a %6]  [%b %6]  [%c %6]  [%d %6]  [%e %6]  [%f %6]  [%g %6]  [%h %6]
    [%a %5]  [%b %5]  [%c %5]  [%d %5]  [%e %5]  [%f %5]  [%g %5]  [%h %5]
    [%a %4]  [%b %4]  [%c %4]  [%d %4]  [%e %4]  [%f %4]  [%g %4]  [%h %4]
    [%a %3]  [%b %3]  [%c %3]  [%d %3]  [%e %3]  [%f %3]  [%g %3]  [%h %3]
    [%a %2]  [%b %2]  [%c %2]  [%d %2]  [%e %2]  [%f %2]  [%g %2]  [%h %2]
    [%a %1]  [%b %1]  [%c %1]  [%d %1]  [%e %1]  [%f %1]  [%g %1]  [%h %1]
  ==
--
