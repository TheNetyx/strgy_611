var allPlayersMoved = false;

// override functions for players (moving, selecting, etc)
function updateRoundCounter(){
} // admin page round counter doesnt update.

function selectPlayer(){
}

function moveTo(){
}

function submitForm(){
}

function checkSub(){
}

function setHexagonOnClick(type){
}

function setPlayerOnClick(type){
}

function renderPlayersWrapper(){
  getJSON("/api/get-players-all/",
  function(err, data) {
    if (err !== null) {
      alert('Something went wrong: ' + err);
    } else {
      players = data.data;
      for (var i = 0 ; i < players.length ; i++) {
        if (!players[i].alive) {
          players.splice(i--, 1);
        }
      }
      movedPlayers = JSON.parse(JSON.stringify(players));

      renderPlayers(movedPlayers);
    }
  });

}

// in init(), change the table showing which teams have moved
function updateMovedTable() {
  getJSON("/api/check-sub-all/",
  function(err, data) {
    if (err !== null) {
      alert('Something went wrong: ' + err);
    } else {
      for(var i = 1 ; i <= NUM_PLAYERS ; i++) {
        el = document.getElementById("team" + i + "-moved");
        allPlayersMoved = true;
        if(data.data[i - 1]) {
          el.innerHTML = "Y";
          el.classList.remove("negative");
        } else {
          allPlayersMoved = false;
          el.innerHTML = "N";
          el.classList.add("negative");
        }
      }

      if(allPlayersMoved && document.getElementById("info-area").innerHTML.includes("responding") && confirm("All teams have moved. Advance round?")) {
        advanceOnSubmit();
      }
    }
  });
}

// refresh map every 5 sec
setInterval(function() {
  init();
}, 5000);

// confirm before advancing round if not all teams have moved
function advanceOnSubmit() {
  if(allPlayersMoved || confirm("Some teams haven't moved yet. Advance anyway?")) {
    document.getElementById("advance-form").submit();
  }
}
