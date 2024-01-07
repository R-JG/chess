/-  *chess
|%
::
::  (copied from the main agent)
+$  active-game-state
  $:  game=chess-game
      position=chess-position
      fen-repetition=(map @t @ud)
      special-draw-available=?
      auto-claim-special-draws=?
      sent-draw-offer=?
      got-draw-offer=?
      sent-undo-request=?
      got-undo-request=?
      opponent=ship
      practice-game=?
  ==
+$  games  (map game-id active-game-state)
+$  challenges-sent  (map ship chess-challenge)
+$  challenges-received  (map ship chess-challenge)
::
::  ui agent state
+$  source  @p
+$  ui-board  (list [key=tape =chess-square =chess-piece])
+$  menu-mode  ?(%games %challenges)
+$  notification  tape
+$  expand-game-options  $~(| bean)
+$  expand-challenge-form  $~(| bean)
+$  selected-game-id  ?(game-id ~)
+$  selected-game-pieces  ui-board
+$  selected-piece  ?([=chess-square =chess-piece] ~)
+$  available-moves  (set chess-square)
::
::  ui agent related actions
+$  chess-ui-agent
  $%  [%get-state ~]
      [%give-state =games =challenges-sent =challenges-received]
  ==
--