^~
'''
body {
  margin: 0;
}
.chessboard {
  height: 30rem;
  width: 30rem;
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
