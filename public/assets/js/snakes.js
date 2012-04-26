var canvasUtils, players;

canvasUtils = (function() {

  function canvasUtils() {}

  canvasUtils.isCanvasSupported = function() {
    var e;
    e = document.createElement("canvas");
    return !!(e.getContext && e.getContext("2d"));
  };

  return canvasUtils;

})();

players = {};

$(function() {
  var addChatMessage, mainCanvas, p, processingFunctions, socket;
  if (!canvasUtils.isCanvasSupported()) {
    $("#canvas-unsupported").show();
    return;
  }
  mainCanvas = {
    element: $("#canvas").get(0),
    context: $("#canvas").get(0).getContext("2d"),
    id: $("#canvas").attr("data-canvas-id")
  };
  socket = io.connect("/snakes");
  socket.on("connect", function(data) {
    $("#server-link-lost").stop(true).slideUp();
    return socket.emit("canvas_join", mainCanvas.id);
  });
  socket.on("disconnect", function(data) {
    return $("#server-link-lost").delay(5000).slideDown();
  });
  socket.on("client_count", function(count) {
    var color, oc;
    oc = $("#online-count");
    if (this.prev === undefined) this.prev = count;
    if (this.orig === undefined) this.orig = oc.css("color");
    oc.text(count + (count === 1 ? " person" : " people") + " on this canvas");
    color = this.orig;
    if (count > this.prev) color = "#090";
    if (count < this.prev) color = "#C00";
    this.prev = count;
    return $("#online-count").css("color", color).animate({
      color: this.orig
    }, {
      duration: 2000,
      queue: false
    });
  });
  socket.on("canvas_ttl", function(percentage) {});
  socket.on("stroke_history", function(strokeHistory) {
    return console.log("stroke history recieved - doing nothing");
  });
  socket.on("chat_history", function(chatHistory) {
    var n, _results;
    _results = [];
    for (n in chatHistory) {
      _results.push(addChatMessage(chatHistory[n].user, chatHistory[n].message, chatHistory[n].time, false));
    }
    return _results;
  });
  socket.on("chat_received", function(chat) {
    return addChatMessage(chat.user, chat.message, chat.time, false);
  });
  $("#chat-input-form").submit(function(e) {
    e.preventDefault();
    socket.emit("chat_sent", $("#chat-input").val());
    return $("#chat-input").val("");
  });
  addChatMessage = function(user, message, time, self) {
    var t;
    self = !!self;
    t = new Date(time);
    $("#chat-history").append($("<div>").addClass("chat-message").append($("<span>").addClass("timestamp").text(t.getHours() + ":" + t.getMinutes())).append($("<a>").addClass("author").toggleClass("author-me", self).text("@" + user).prop("href", "http://twitter.com/" + user)).append(document.createTextNode(message)));
    return $("#chat-history").animate({
      scrollTop: $("#chat-history").prop("scrollHeight")
    }, {
      queue: false
    });
  };
  socket.on("player_joined", function(playerData) {
    var player;
    return player = players[playerData.id] = playerData;
  });
  socket.on("player_left", function(playerId) {
    return delete players[playerId];
  });
  socket.on("move_received", function(moveData) {
    var player;
    player = players[moveData.id];
    player.direction = moveData.dir;
    return player.tail.push({
      x: player.x,
      y: player.y
    });
  });
  processingFunctions = function(pjs) {
    var changeOwnDirection, direction, drawGrid, drawHead, drawPlayer, drawTail, headRadius, tailWidth, updatePlayer;
    headRadius = 10;
    tailWidth = headRadius;
    direction = pjs.RIGHT;
    pjs.setup = function() {
      pjs.size(mainCanvas.element.width, mainCanvas.element.height);
      return pjs.frameRate(60);
    };
    pjs.draw = function() {
      var i, player, _results;
      pjs.background(50);
      drawGrid();
      _results = [];
      for (i in players) {
        player = players[i];
        updatePlayer(player);
        _results.push(drawPlayer(player));
      }
      return _results;
    };
    updatePlayer = function(player) {
      switch (player.direction) {
        case pjs.UP:
          return player.y -= 1;
        case pjs.DOWN:
          return player.y += 1;
        case pjs.RIGHT:
          return player.x += 1;
        case pjs.LEFT:
          return player.x -= 1;
      }
    };
    drawGrid = function() {
      var gridSizeX, gridSizeY, tilesX, tilesY, x, y, _ref, _ref2, _results;
      tilesX = 12;
      tilesY = 10;
      gridSizeX = pjs.width / tilesX;
      gridSizeY = pjs.height / tilesY;
      pjs.noFill();
      pjs.stroke(255, 255, 255, 20);
      pjs.strokeWeight(1);
      for (x = 1, _ref = pjs.width; 1 <= _ref ? x <= _ref : x >= _ref; x += gridSizeX) {
        pjs.line(x, 0, x, pjs.height);
      }
      _results = [];
      for (y = 1, _ref2 = pjs.height; 1 <= _ref2 ? y <= _ref2 : y >= _ref2; y += gridSizeY) {
        _results.push(pjs.line(0, y, pjs.width, y));
      }
      return _results;
    };
    drawPlayer = function(player) {
      drawTail(player);
      return drawHead(player);
    };
    drawTail = function(player) {
      var tailJoint, _i, _len, _ref;
      pjs.noFill();
      pjs.stroke(player.color.red, player.color.green, player.color.blue);
      pjs.strokeWeight(tailWidth);
      pjs.strokeCap(pjs.ROUND);
      pjs.strokeJoin(pjs.ROUND);
      pjs.beginShape();
      _ref = player.tail;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tailJoint = _ref[_i];
        pjs.vertex(tailJoint.x, tailJoint.y);
      }
      pjs.vertex(player.x, player.y);
      return pjs.endShape();
    };
    drawHead = function(player) {
      pjs.fill(player.color.red, player.color.green, player.color.blue);
      pjs.stroke(player.color.red + 70, player.color.green + 70, player.color.blue + 70);
      pjs.strokeWeight(3);
      return pjs.ellipse(player.x, player.y, headRadius, headRadius);
    };
    pjs.keyPressed = function() {
      var _ref;
      if ((_ref = pjs.keyCode) !== pjs.UP && _ref !== pjs.DOWN && _ref !== pjs.LEFT && _ref !== pjs.RIGHT) {
        return;
      }
      if (pjs.keyCode === direction) return;
      if (pjs.keyCode === pjs.UP && direction === pjs.DOWN) return;
      if (pjs.keyCode === pjs.DOWN && direction === pjs.UP) return;
      if (pjs.keyCode === pjs.LEFT && direction === pjs.RIGHT) return;
      if (pjs.keyCode === pjs.RIGHT && direction === pjs.LEFT) return;
      return changeOwnDirection(pjs.keyCode);
    };
    return changeOwnDirection = function(playerId, newDirection) {
      direction = pjs.keyCode;
      return socket.emit("move_sent", {
        dir: direction
      });
    };
  };
  return p = new Processing(mainCanvas.element, processingFunctions);
});
