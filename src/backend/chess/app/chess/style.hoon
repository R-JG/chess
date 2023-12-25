^~
'''
body {
  margin: 0;
}
main {
  padding: 3rem;
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: flex-start;
}
label {
  margin-top: 0.5rem;
  margin-left: 0.5rem;
}
.title {
  padding: 2rem;
  background-color: blue;
}
.title span {
  padding: 0.6rem;
  background-color: pink;
  display: block;
  text-align: center;
}
.menu {
  width: 20rem;
  border: 2px solid black;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
}
.menu-tabs {
  width: 100%;
  padding-top: 0.5rem;
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: center;
}
.tab {
  padding: 1rem;
  box-shadow: rgba(0, 0, 0, 0.15) 0px 3px 6px;
  cursor: pointer;
  transition: transform .1s ease;
}
.tab:hover {
  transform: scale(1.05);
}
.tab.challenges {
  background-color: orange;
}
.tab.games {
  background-color: yellowgreen;
}
.tab.settings {
  background-color: cornflowerblue;
}
.challenge-form {
  background-color: lightgray;
  padding: 1rem;
  display: flex;
  flex-direction: column;
}
.challenges-menu, .games-menu, .settings-menu {
  padding-inline: 2rem;
  padding-bottom: 2rem;
}
.received-challenges {
  background-color: lightgray;
  padding: 1rem;
}
.game-selector {
  cursor: pointer;
}
.game-selector.selected {
  background-color: firebrick;
}
.chessboard {
  height: 30rem;
  width: 30rem;
  border: 6px solid #555;
  box-shadow: 10px 10px 20px rgba(0, 0, 0, 0.5);
}
.pieces-container {
  position: absolute;
  height: inherit;
  width: inherit;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: flex-start;
}
.piece {
  position: absolute;
  box-sizing: border-box;
  font-size: 0.8rem;
  height: 12.5%;
  width: 12.5%;
  border: 10px solid yellowgreen;
  border-radius: 5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.piece.our {
  cursor: pointer;
}
.piece.white {
  color: black;
  background-color: white;
}
.piece.black {
  color: white;
  background-color: black;
}
.squares-container {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: flex-start;
  flex-wrap: wrap;
}
.square {
  box-sizing: border-box;
  height: 12.5%;
  width: 12.5%;
  transition: border 0.02s ease;
}
.square.white {
  background-color: white;
}
.square.black {
  background-color: black;
}
.square.white.can-move {
  border: 5px solid #9dccfa;
  z-index: 1;
  cursor: pointer;
}
.square.black.can-move {
  border: 5px solid cornflowerblue;
  z-index: 1;
  cursor: pointer;
}
'''
