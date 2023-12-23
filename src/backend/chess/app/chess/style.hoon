^~
'''
body {
  margin: 0;
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
  padding: 2rem;
  background-color: blue;
}
.games-tab {
  padding: 2rem;
  background-color: pink;
}
.game-selector {
  cursor: pointer;
}
.game-selector.selected {
  border: 3px solid black;
}
.chessboard {
  height: 30rem;
  width: 30rem;
  margin: 2rem;
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
  border: 1px solid black;
}
.square.light {
  background-color: white;
}
.square.dark {
  background-color: black;
}
'''
