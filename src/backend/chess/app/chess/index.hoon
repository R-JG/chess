/-  *chess
|=  $:  =games  =challenges-sent  =challenges-received
        =menu-mode  =selected-game  =selected-piece
        =available-moves  =available-threatens
    ==
|^  ^-  manx
::
;html
  ;head
    ;meta(charset "utf-8");
    ;link(href "/chess/style", rel "stylesheet");
  ==
  ;body
    ;h1(class "title"): Chess
    ;button
      =event  "/click/test-challenge"
      ;+  ;/  "TEST CHALLENGE"
    ==
    ;button
      =event  "/click/test-decline"
      ;+  ;/  "TEST DECLINE"
    ==
    ;button
      =event  "/click/test-accept"
      ;+  ;/  "TEST ACCEPT"
    ==
    ;div
      ;h1: Challenges
      ;*  %+  turn  ~(tap in ~(key by challenges-received))
        |=  =ship
        ;div: {<ship>}
    ==
    ;+  menu
    ;+  chessboard
  ==
==
::
++  menu
  :: a tab list for: games, challenges, settings
  :: and a panel for viewing one of these options at a time
  ^-  manx
  ;div(class "menu")
    ;div(class "games-tab")
      ;*  %+  turn  `(list [game-id active-game-state])`~(tap by games)
        |=  [=game-id =active-game-state]
        ;div
          =id  <(@ game-id)>
          =class  "game-selector {?:(=(selected-game game-id) "selected" "")}"
          =event  "/click/select-game"
          =return  "/target/id"
          ;p: {"Opponent: {<opponent.active-game-state>}"}
        ==
    ==
  ==
::
++  game-panel
  ^-  manx
  ;div;
::
++  chessboard
  ^-  manx
  ;div(class "chessboard")
    ;+  pieces-on-board
    ;+  ?~  selected-piece
        squares-without-selection
      squares-with-selection
  ==
::
++  pieces-on-board
  ^-  manx
  =/  game-to-render=(unit active-game-state) 
    ?~  selected-game  ~
    (~(get by games) selected-game)
  ?~  game-to-render
    ;div(class "pieces-container");
  ;div(class "pieces-container")
    ;*  %+  turn  ~(tap by board.position.u.game-to-render)
      |=  [=chess-square =chess-piece]
      =/  trans-x=tape  ?:  =(%a -.chess-square)  "0"
        "{<(sub (@ -.chess-square) 97)>}00%"
      =/  trans-y=tape  ?:  =(%1 +.chess-square)  "0"
        "-{<(sub (@ +.chess-square) 1)>}00%"
      ;div
        =class  "piece {(trip -.chess-piece)}"
        =style  "transform: translate({trans-x}, {trans-y});"
        ;+  ;/  (trip +.chess-piece)
      ==
  ==
::
++  squares-with-selection
  ^-  manx
  ;div(class "squares-container")
    ;*  %+  turn  square-cells
      |=  =chess-square
      ?:  (~(has in available-threatens) chess-square)
        ;div(class "square threaten {(get-color chess-square)}");
      ?:  (~(has in available-moves) chess-square)
        ;div(class "square can-move {(get-color chess-square)}");
      ;div(class "square {(get-color chess-square)}");
  ==
::
++  squares-without-selection
  ^-  manx
  ;div(class "squares-container")
    ;*  %+  turn  square-cells
      |=  =chess-square
      ;div(class "square {(get-color chess-square)}");
  ==
::
++  get-color
  |=  =chess-square
  ^-  tape
  ?:  (bean (mod (@ -.chess-square) 2))
    ?:  (bean (mod (@ +.chess-square) 2))
      "dark"
    "light"
  ?:  (bean (mod (@ +.chess-square) 2))
    "light"
  "dark"
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