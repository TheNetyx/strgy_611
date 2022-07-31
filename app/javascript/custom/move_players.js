/************************************************************************
* this file is probably the most spaghetti file in this entire thing.   *
* i dont even know javascript. at least it works i guess. good luck     *
* trying to understand what i wrote.                                    *
************************************************************************/

// an array, players, is defined previously, containing the members to display
const NUM_PLAYERS = 8;

var players = [];
var movedPlayers = [];
var selectedPlayer;
var round;
var notifyPlayerWhenMoveAvailable;

window.addEventListener('load', (event) => {
  init();
});


function init() {
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
      var dest = "cell-0-0"
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
function isValidMove(id, destCoords) {
  var player = getPlayerWithId(id);

  if(destCoords.x < 0 || destCoords.y < 0 || destCoords.x > 9
     || destCoords.y > 9 || destCoords.x - player.xpos > 2
     || destCoords.x - player.xpos < -2 || destCoords.y - player.ypos > 2
     || destCoords.y - player.ypos < -2 ) {
    return false;
  }
  return true;
}

function getPossibleSpaces(id) {
  var player = getPlayerWithId(id);
  var coords;

  arr = [];
  for(var i = -2; i <= 2; i++) {
    for(var j = -2; j <= 2; j++) {
      coords = {x: player.xpos + i, y: player.ypos + j};
      if(coords.x > 0 && coords.y > 0 && coords.x <= 9 && coords.y <= 9) {
        arr.push(coords);
      }
    }
  }
  return arr;
}

function isAccessable(coords) {
  return coords.x && coords.y && coords.x <= 9 && coords.y <= 9
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
