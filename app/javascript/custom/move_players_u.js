//overwrite functions for admin page
function updateMovedTable(){
}



function renderPlayersWrapper() {
  getJSON("/api/get-players/" + teamid,
  function(err, data) {
    if (err !== null) {
      alert('Something went wrong: ' + err);
    } else {
      players = data.data;
/*      for (var i = 0 ; i < players.length ; i++) {
        if (!players[i].alive) {
          players.splice(i--, 1);
        }
      }
*/
      movedPlayers = JSON.parse(JSON.stringify(players));

      renderPlayers(movedPlayers);

      dead = document.getElementsByClassName("dead")
      for (var i = 0 ; i < dead.length ; i++) {
        dead[i].setAttribute("onclick", "");
      }
    }
  });
}

function updateRoundCounter() {
  document.getElementById("round-counter").innerHTML = "Round " + round;
}

// select a player
function selectPlayer(id) {
  // clear all highlighted moves
  var el = document.getElementById(id);

  clearSelected();

  // deselecting
  if (selectedPlayer == id) {
    selectedPlayer = null;
    el.classList.remove("selected-member");
  }

  // selecting
  else {
/*    if (! MOVE_THIS_ROUND || getPlayerWithId(id).patrol != MYPATROL) {
      return;
    }
*/
    // deselect currently selected one
    var cur = document.getElementsByClassName("selected-member");
    if(cur[0]){
      cur[0].classList.remove("selected-member");
    }
    selectedPlayer = id;
    el.classList.add("selected-member");
    var spaces = getPossibleSpaces(selectedPlayer);
    for (var i = 0 ; i < spaces.length ; i++) {
//      legalMoves.push(convertNumCordsToStr(spaces[i]));
      document.getElementById(convertNumCordsToStr(spaces[i])).classList.add("legal-move");
    }
  }
}

// moving the selected player
function moveTo(dest) {
  // WHY DOES JAVASCRIPT NOT HAVE SSCANF.
  destxy = dest.replace("cell-", "").split("-");
  for (var i = 0 ; i <= 1 ; i++) {
    destxy[i] = parseInt(destxy[i])
  }
  if (selectedPlayer == null) {
    return;
  }

  var destCoords = {
    x: destxy[0],
    y: destxy[1]
  }

  if (isValidMove(id, destCoords)) {
    // change movedPlayers.
    getMovedPlayerWithId(selectedPlayer).xpos = destCoords.x;
    getMovedPlayerWithId(selectedPlayer).ypos = destCoords.y;

    renderPlayers(movedPlayers);
  }

  // if invalid, just deselect; if valid, needs deselect anyway
  selectPlayer(selectedPlayer); // select itself again to deselect
  return false
}

function submitForm(f) { // handlings sending the data to the server
  if (!confirm("Confirm?")) {
    return false;
  }

  document.getElementById("response-input").value = JSON.stringify(movedPlayers)
  f.submit();
  return true;
}

function checkSub() {
  getJSON("/api/check-sub/" + teamid,
  function(err, data) {
    if (err !== null) {
      alert('Something went wrong: ' + err);
    } else {
      // if a move isn't available, notify when one is
      notifyPlayerWhenMoveAvailable = data.data;
    }
  });

}

// the form refreshes the page, so only setting notifyPLayerWhenMoveAvailable
// in init() is enough
setInterval(function() {
  if(notifyPlayerWhenMoveAvailable) {
    getJSON("/api/check-sub/" + teamid,
    function(err, data) {
      if (err !== null) {
        alert('Something went wrong: ' + err);
      } else {
        if (!data.data) {
          notifyPlayerWhenMoveAvailable = false;
          alert ("the next round has started");
          /* lazy way to update scoreboard */
          location.reload();
          getRound();
        }
      }
    });
  }
}, 5000);

// yes, i know the following 2 functions are very similar, but
// i can't be bothered to DRY it up
function setHexagonOnClick(type) {
  var hexagons = document.getElementsByClassName("hexagon");
  if (type == "moveTo") {
    for (var i = 0 ; i < hexagons.length ; i++) {
      hexagons[i].setAttribute("onclick", "moveTo(\"" + hexagons[i].firstElementChild.id + "\")");
    }
  } else if (type == "select") {
    for (var i = 0 ; i < hexagons.length ; i++) {
      hexagons[i].setAttribute("onclick", "pickCell(\"" + hexagons[i].firstElementChild.id + "\")");
    }
    p = document.getElementsByClassName("player");
    for (var i = 0 ; i < p.length ; i++) {
      if (! p.classList.contains("dead"))
        p[i].setAttribute("onclick", "pickCellPlayer(" + p[i].id + ");event.stopPropagation();")
    }
  }
}

function setPlayerOnClick(type) {
  var p = document.getElementsByClassName("player");
  if (type == "moveTo") {
    for (var i = 0 ; i < p.length ; i++) {
      p[i].setAttribute("onclick", "selectPlayer(" + p[i].id + ");event.stopPropagation();");
    }
  } else if (type == "select") {
    for (var i = 0 ; i < p.length ; i++) {
      p[i].setAttribute("onclick", "pickPlayer(\"" + p[i].id + "\");event.stopPropagation();");
    }
  }
}

function pickPlayer(player){
  document.getElementById("player-field").value = player;
  setPlayerOnClick("moveTo");
}

function pickCell(cell) {
  document.getElementById("cell-field").value = cell;
  setHexagonOnClick("moveTo");
  setPlayerOnClick("moveTo");
}

// click on player to select cell underneath
function pickCellPlayer(player) {
  for (var i = 0 ; i < movedPlayers.length ; i++) {
    if (movedPlayers[i].id + "" == player) {
      document.getElementById("cell-field").value = "cell-" + movedPlayers[i].xpos + "-" + movedPlayers[i].ypos;
      break;
    }
  }

  setHexagonOnClick("moveTo");
  setPlayerOnClick("moveTo");
}
