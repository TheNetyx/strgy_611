/************************************************************************
* this file is probably the most spaghetti file in this entire thing.   *
* i dont even know javascript. at least it works i guess. good luck     *
* trying to understand what i wrote.                                    *
************************************************************************/

// an array, players, is defined previously, containing the members to display
const NUM_PLAYERS = 8;
var ACCESSIBLE_GRIDS = [  // << this is def not the best way to do this.
  {x: 1, y: 4},
  {x: 2, y: 3},
  {x: 2, y: 4},
  {x: 3, y: 1},
  {x: 3, y: 2},
  {x: 3, y: 3},
  {x: 3, y: 4},
  {x: 3, y: 5},
  {x: 3, y: 6},
  {x: 3, y: 7},
  {x: 4, y: 1},
  {x: 4, y: 2},
  {x: 4, y: 3},
  {x: 4, y: 4},
  {x: 4, y: 5},
  {x: 4, y: 6},
  {x: 5, y: 2},
  {x: 5, y: 3},
  {x: 5, y: 4},
  {x: 5, y: 5},
  {x: 5, y: 6},
  {x: 6, y: 1},
  {x: 6, y: 2},
  {x: 6, y: 3},
  {x: 6, y: 4},
  {x: 6, y: 5},
  {x: 6, y: 6},
  {x: 7, y: 1},
  {x: 7, y: 2},
  {x: 7, y: 3},
  {x: 7, y: 4},
  {x: 7, y: 5},
  {x: 7, y: 6},
  {x: 7, y: 7},
  {x: 8, y: 3},
  {x: 8, y: 4},
  {x: 9, y: 4},
];

var players = [];
var movedPlayers = [];
var selectedPlayer;
var round;
var notifyPlayerWhenMoveAvailable;

window.addEventListener('load', (event) => {
  init();
});


function init() {
  document.getElementById("cell-9-1").classList.add("cemetery");
  renderPlayersWrapper();

  getRound();

  checkSub();

  updateMovedTable();

  // set onclick is moved into renderplayers(), which is called inside the
  // wrapper, which is async and now sets player onclick properly
}

function renderPlayers(players) {
  var oldPlayers = document.getElementsByClassName("player");
  while (oldPlayers.length){
    oldPlayers[0].remove();
  }

  for(var i = 0 ; i < players.length ; i++) {
    // show players at top right corner if its dead
    if (players[i].alive)
      var dest = "cell-" + players[i].xpos + "-" + players[i].ypos
    else
      var dest = "cell-9-1"
    var grid = document.getElementById(dest);
    if (grid == null) { // player with invalid location
      continue;
    }
    var nametag = document.createElement("button");
    nametag.classList.add("player");
    nametag.classList.add("team" + players[i].team);
    nametag.setAttribute("id", players[i].id);
    if (! players[i].alive)
      nametag.classList.add("dead");
    var nametext = document.createTextNode(players[i].name);
    nametag.appendChild(nametext);

    grid.appendChild(nametag);
  }

  setHexagonOnClick("moveTo");
  setPlayerOnClick("moveTo");
}





// get JSON data from a url
function getJSON(url, callback) {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', url, true);
  xhr.responseType = 'json';
  xhr.onload = function() {
    var status = xhr.status;
    if (status === 200) {
      return callback(null, xhr.response);
    } else {
      return callback(status, xhr.response);
    }
  };
  xhr.send();
};

// clear all selections and legal move squares
function clearSelected() {
  var legalMoves = document.getElementsByClassName("legal-move");
  while(legalMoves.length > 0){
    legalMoves[0].classList.remove("legal-move");
  }
}

// returns an array of legal moves for a player
function getPossibleSpaces(id) {
  var player = getPlayerWithId(id);
  var arr = [ // theres probably a smarter way to do this.
    {x: player.xpos, y: player.ypos},
    {x: player.xpos, y: player.ypos + 1},
    {x: player.xpos, y: player.ypos + 2},
    {x: player.xpos, y: player.ypos - 1},
    {x: player.xpos, y: player.ypos - 2},

    {x: player.xpos - 1, y: player.ypos},
    {x: player.xpos - 1, y: player.ypos + 1},
    {x: player.xpos - 1, y: player.ypos - 1},


    {x: player.xpos + 1, y: player.ypos},
    {x: player.xpos + 1, y: player.ypos + 1},
    {x: player.xpos + 1, y: player.ypos - 1},

    {x: player.xpos + 2, y: player.ypos},
    {x: player.xpos + 2, y: player.ypos + 1},
    {x: player.xpos + 2, y: player.ypos - 1},

    {x: player.xpos - 2, y: player.ypos},
    {x: player.xpos - 2, y: player.ypos + 1},
    {x: player.xpos - 2, y: player.ypos - 1},
  ];

  if (player.xpos % 2) {
    arr.push({x: player.xpos - 1, y: player.ypos - 2})
    arr.push({x: player.xpos + 1, y: player.ypos - 2})
  } else {
    arr.push({x: player.xpos - 1, y: player.ypos + 2})
    arr.push({x: player.xpos + 1, y: player.ypos + 2})
  }

  for (var i = 0 ; i < arr.length ; i++) {
    if (! isAccessable({x: arr[i].x, y: arr[i].y})) {
      arr.splice (i--, 1);  //decrements i afterward because the array shrinks
    }
  }
  return arr;
}

function isAccessable(coords) {
  for (var i = 0 ; i < ACCESSIBLE_GRIDS.length ; i++) {
    if (coords.x == ACCESSIBLE_GRIDS[i].x && coords.y == ACCESSIBLE_GRIDS[i].y) {
      return true;
    }
  }
  return false;
}

function getPlayerWithId(id) {
  return getEntryWithId (players, id)
}

function getMovedPlayerWithId(id) {
  return getEntryWithId (movedPlayers, id)
}

// dont use this.
function getEntryWithId(arr, id) {
  for (var i = 0 ; i < arr.length ; i++) {
    if (arr[i].id == id) {
      return arr[i];
    }
  }
  return null;
}


function convertNumCordsToStr(player) {
  return "cell-" + player.x + "-" + player.y
} // original coordinate format

function convertNewNumCordsToStr(player) {
  return "cell-" + player.xpos + "-" + player.ypos
} // new coordinate format

function getRound() {
  getJSON("/api/round-number",
  function(err, data) {
    if (err !== null) {
      alert('Something went wrong: ' + err);
    } else {
      round = data.data
      updateRoundCounter();
    }
  });
}
