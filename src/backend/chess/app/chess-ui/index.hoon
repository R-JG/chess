/-  *chess
|=  *
^-  manx
;html
  ;head
    ;meta(charset "utf-8");
    ;link(href "/chess/style", rel "stylesheet");
  ==
  ;body
    ;h1: TEST
  ==
==
::  |=  $:  =bowl:gall  =games  =challenges-sent  =challenges-received
::          =menu-mode  =selected-game  =selected-piece
::          =available-moves
::      ==
::  |^  ^-  manx
::  ::
::  ;html
::    ;head
::      ;meta(charset "utf-8");
::      ;link(href "/chess/style", rel "stylesheet");
::    ==
::    ;body
::      ;h1(class "title"): Chess
::      ;main
::        ;button(id <(@ selected-game)>, event "/click/test-resign", return "/target/id"): TEST RESIGN
::        ;+  chessboard
::        ;+  menu
::      ==
::    ==
::  ==
::  ::
::  ++  menu
::    ^-  manx
::    ;div(class "menu")
::      ;div(class "menu-tabs")
::        ;div
::          =class  "tab challenges"
::          =event  "/click/set-menu-mode/challenges"
::          ;+  ;/  "Challenges"
::        ==
::        ;div
::          =class  "tab games"
::          =event  "/click/set-menu-mode/games"
::          ;+  ;/  "Games"
::        ==
::        ;div
::          =class  "tab settings"
::          =event  "/click/set-menu-mode/settings"
::          ;+  ;/  "Settings"
::        ==
::      ==
::      ;+  ?-  menu-mode
::            %challenges  challenges-menu
::            %games       games-menu
::            %settings    settings-menu
::          ==
::    ==
::  ::
::  ++  challenges-menu
::    ^-  manx
::    ;div(class "challenges-menu")
::      ;p: Send a challenge:
::      ;div(class "challenge-form")
::        ;label
::          ;+  ;/  "Ship"
::          ;input(id "challenge-ship-input");
::        ==
::        ;label
::          ;+  ;/  "Note"
::          ;input(id "challenge-note-input");
::        ==
::        ;label
::          ;+  ;/  "Side"
::          ;select(id "challenge-side-input")
::            ;option(value "white"): White
::            ;option(value "black"): Black
::            ;option(value "random"): Random
::          ==
::        ==
::        ;label
::          ;+  ;/  "Practice"
::          ;input(type "checkbox", id "challenge-practice-input");
::        ==
::        ;button
::          =event  "/click/send-challenge"
::          =return  
::            """
::            /challenge-ship-input/value 
::            /challenge-note-input/value 
::            /challenge-side-input/value 
::            /challenge-practice-input/checked
::            """
::          ;+  ;/  "Send challenge"
::        ==
::      ==
::      ;p: Received Challenges:
::      ;+  ?:  =(0 ~(wyt by challenges-received))
::          ;div(class "received-challenges")
::            ;+  ;/  "You have not received any challenges."
::          ==
::        ;div(class "received-challenges")
::          ;*  %+  turn  ~(tap by challenges-received)
::            |=  [=ship =chess-challenge]
::            ;div(class "challenge")
::              ;p: {"Challenger: {<ship>}"}
::              ;p: {"Their side: {(trip challenger-side.chess-challenge)}"}
::              ;p: {?:(practice-game.chess-challenge "Practice game" "")}
::              ;button
::                =event  "/click/accept-challenge/{<ship>}"
::                ;+  ;/  "Accept"
::              ==
::              ;button
::                =event  "/click/decline-challenge/{<ship>}"
::                ;+  ;/  "Decline"
::              ==
::            ==
::        ==
::    ==
::  ::
::  ++  games-menu
::    ^-  manx
::    ;div(class "games-menu")
::      ;*  %+  turn  `(list [game-id active-game-state])`~(tap by games)
::        |=  [=game-id =active-game-state]
::        ;div
::          =class  "game-selector {?:(=(selected-game game-id) "selected" "")}"
::          =event  "/click/select-game/{<(@ game-id)>}"
::          ;p: {"Opponent: {<opponent.active-game-state>}"}
::        ==
::    ==
::  ::
::  ++  settings-menu
::    ^-  manx
::    ;div(class "settings-menu");
::  ::
::  ++  game-panel
::    ^-  manx
::    ;div;
::  ::
::  ++  chessboard
::    ^-  manx
::    ;div(class "chessboard")
::      ;+  pieces-on-board
::      ;+  ?~  selected-piece
::          squares-without-selection
::        squares-with-selection
::    ==
::  ::
::  ++  pieces-on-board
::    ^-  manx
::    =/  game-to-render=(unit active-game-state) 
::      ?~  selected-game  ~
::      (~(get by games) selected-game)
::    ?~  game-to-render
::      ;div(class "pieces-container");
::    ;div(class "pieces-container")
::      ;*  %+  turn  ~(tap by board.position.u.game-to-render)
::        |=  [=chess-square =chess-piece]
::        =/  trans-x=tape  ?:  =(%a -.chess-square)  "0"
::          "{<(sub (@ -.chess-square) 97)>}00%"
::        =/  trans-y=tape  ?:  =(%1 +.chess-square)  "0"
::          "-{<(sub (@ +.chess-square) 1)>}00%"
::        =/  ownership=bean
::          ?-  -.chess-piece
::            %white  =(our.bowl white.game.u.game-to-render)
::            %black  =(our.bowl black.game.u.game-to-render)
::          ==
::        ;div
::          =key  "{(trip -.chess-square)}{(trip (@ +.chess-square))}{(trip -.chess-piece)}{(trip +.chess-piece)}"
::          =class  "piece {(trip -.chess-piece)} {?:(ownership "our" "")}"
::          =style  "transform: translate({trans-x}, {trans-y});"
::          =event  ?.(ownership "" "/click/select-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}/{(trip -.chess-piece)}/{(trip +.chess-piece)}")
::          ;+  ;/  (trip +.chess-piece)
::        ==
::    ==
::  ::
::  ++  squares-with-selection
::    ^-  manx
::    ;div(class "squares-container")
::      ;*  %+  turn  square-cells
::        |=  =chess-square
::        ;div(key "{(trip -.chess-square)}{(trip (@ +.chess-square))}", class "square {?:((~(has in available-moves) chess-square) "can-move" "")} {(get-color chess-square)}", event "/click/move-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}");
::    ==
::  ::
::  ++  squares-without-selection
::    ^-  manx
::    ;div(class "squares-container")
::      ;*  %+  turn  square-cells
::        |=  =chess-square
::        ;div(key "{(trip -.chess-square)}{(trip (@ +.chess-square))}", class "square {(get-color chess-square)}");
::    ==
::  ::
::  ++  get-color
::    |=  =chess-square
::    ^-  tape
::    ?:  (bean (mod (@ -.chess-square) 2))
::      ?:  (bean (mod (@ +.chess-square) 2))
::        "black"
::      "white"
::    ?:  (bean (mod (@ +.chess-square) 2))
::      "white"
::    "black"
::  ::
::  ++  square-cells
::    ^-  (list chess-square)
::    :~
::      [%a %8]  [%b %8]  [%c %8]  [%d %8]  [%e %8]  [%f %8]  [%g %8]  [%h %8]
::      [%a %7]  [%b %7]  [%c %7]  [%d %7]  [%e %7]  [%f %7]  [%g %7]  [%h %7]
::      [%a %6]  [%b %6]  [%c %6]  [%d %6]  [%e %6]  [%f %6]  [%g %6]  [%h %6]
::      [%a %5]  [%b %5]  [%c %5]  [%d %5]  [%e %5]  [%f %5]  [%g %5]  [%h %5]
::      [%a %4]  [%b %4]  [%c %4]  [%d %4]  [%e %4]  [%f %4]  [%g %4]  [%h %4]
::      [%a %3]  [%b %3]  [%c %3]  [%d %3]  [%e %3]  [%f %3]  [%g %3]  [%h %3]
::      [%a %2]  [%b %2]  [%c %2]  [%d %2]  [%e %2]  [%f %2]  [%g %2]  [%h %2]
::      [%a %1]  [%b %1]  [%c %1]  [%d %1]  [%e %1]  [%f %1]  [%g %1]  [%h %1]
::    ==
::  --
