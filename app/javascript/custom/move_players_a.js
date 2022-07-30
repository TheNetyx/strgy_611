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
        el.innerHTML = data.data[i - 1] ? "Y" : "N";
        if (data.data[i - 1]) {
          el.classList.remove("negative");
        } else {
          el.classList.add("negative");
        }
      }
    }
  });
}

// refresh map every 5 sec
setInterval(function() {
  init();
}, 5000);
