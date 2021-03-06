// Generated by CoffeeScript 1.7.1
(function() {
  var KEY, buffer_diff, camera_pos, canvas, counter, ctx, edge_buffer, fps, gameloop, init, keydown, keys, keyup, last_turn, max_frame_time, paused, print, render_interval, running, ship, time_accumulator, total_time, updateLogic, updateScreen, update_interval, ups;

  this.print = print = console.log.bind(console);

  canvas = document.getElementById("canvas");

  ctx = canvas.getContext("2d");

  counter = 0;

  fps = 60;

  ups = 60;

  update_interval = 1000 / ups;

  render_interval = 1000 / fps;

  max_frame_time = ups / 4;

  time_accumulator = 0;

  total_time = 0;

  running = true;

  paused = false;

  ship = {
    x: 500,
    y: 300,
    r: Math.PI / 2,
    speed: 0,
    fire: false
  };

  keys = {
    right: false,
    left: false,
    up: false,
    down: false,
    space: false
  };

  keydown = function(e) {
    switch (e.keyCode) {
      case KEY.RIGHT:
        return keys.right = true;
      case KEY.LEFT:
        return keys.left = true;
      case KEY.UP:
        return keys.up = true;
      case KEY.DOWN:
        return keys.down = true;
      case KEY.SPACE:
        return keys.space = true;
    }
  };

  keyup = function(e) {
    switch (e.keyCode) {
      case KEY.RIGHT:
        return keys.right = false;
      case KEY.LEFT:
        return keys.left = false;
      case KEY.UP:
        return keys.up = false;
      case KEY.DOWN:
        return keys.down = false;
      case KEY.SPACE:
        return keys.space = false;
    }
  };

  init = function() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    document.addEventListener('keydown', keydown);
    return document.addEventListener('keyup', keyup);
  };

  updateLogic = function(time) {
    var ACCELERATION, SPEED_LIMIT, background;
    ACCELERATION = 10 / ups;
    SPEED_LIMIT = 6;
    counter += 1;
    ship.x -= ship.speed * Math.cos(ship.r);
    ship.y -= ship.speed * Math.sin(ship.r);
    background = document.getElementById("background3");
    if (Math.abs(ship.x) > background.width / 2 - edge_buffer.x) {
      ship.x = -ship.x;
    }
    if (Math.abs(ship.y) > background.height / 2 - edge_buffer.y) {
      ship.y = -ship.y;
    }
    if (keys.right) {
      ship.r = (ship.r + (Math.PI / ups)) % (2 * Math.PI);
    }
    if (keys.left) {
      ship.r = (ship.r - (Math.PI / ups)) % (2 * Math.PI);
    }
    if (keys.up) {
      if (ship.speed < SPEED_LIMIT) {
        ship.speed += ACCELERATION;
      }
    }
    if (keys.down) {
      if (ship.speed > ACCELERATION) {
        ship.speed -= ACCELERATION;
      }
    }
    return ship.fire = keys.space;
  };

  last_turn = 0;

  camera_pos = {
    x: 0,
    y: 0
  };

  edge_buffer = {
    x: 100,
    y: 100
  };

  buffer_diff = {
    x: 0,
    y: 0
  };

  updateScreen = function() {
    var background3, laser, laser_gradient, laser_pos, ship_image, suffix, sx, sy, turn;
    window.requestAnimationFrame(updateScreen);
    buffer_diff = {
      x_top: ship.x - (camera_pos.x + edge_buffer.x),
      x_bottom: (camera_pos.x + canvas.width - edge_buffer.x) - ship.x,
      y_top: ship.y - (camera_pos.y + edge_buffer.y),
      y_bottom: (camera_pos.y + canvas.height - edge_buffer.y) - ship.y
    };
    if (buffer_diff.x_top < 0) {
      camera_pos.x += buffer_diff.x_top;
    }
    if (buffer_diff.y_top < 0) {
      camera_pos.y += buffer_diff.y_top;
    }
    if (buffer_diff.x_bottom < 0) {
      camera_pos.x -= buffer_diff.x_bottom;
    }
    if (buffer_diff.y_bottom < 0) {
      camera_pos.y -= buffer_diff.y_bottom;
    }
    background3 = document.getElementById("background3");
    sx = (background3.width / 2) + camera_pos.x;
    sy = (background3.height / 2) + camera_pos.y;
    ctx.drawImage(background3, sx, sy, canvas.width, canvas.height, 0, 0, canvas.width, canvas.height);
    ctx.translate(-camera_pos.x, -camera_pos.y);
    turn = 5 - (Math.floor(ship.speed / 5));
    if (turn >= 5) {
      turn = 5;
    }
    if (turn > last_turn) {
      turn = last_turn + 1;
      if (counter % ups === 0) {
        last_turn += 1;
      }
    }
    suffix = (function() {
      switch (false) {
        case !keys.right:
          return "_right" + turn;
        case !keys.left:
          return "_left" + turn;
        default:
          return "";
      }
    })();
    ship_image = document.getElementById("fighter" + suffix);
    ctx.translate(ship.x, ship.y);
    ctx.scale(.5, .5);
    ctx.rotate(ship.r - Math.PI / 2);
    ctx.translate(-ship.x, -ship.y);
    ctx.drawImage(ship_image, ship.x - ship_image.width / 2, ship.y - ship_image.height / 2);
    if (ship.fire) {
      ship.laser_mount = {
        x: ship.x,
        y: ship.y - ship_image.height / 2 + 15
      };
      laser = {
        width: 7,
        length: 2000
      };
      laser_pos = {
        x: ship.laser_mount.x - laser.width / 2,
        y: ship.laser_mount.y - laser.length
      };
      laser_gradient = ctx.createLinearGradient(0, 0, laser.width, 0);
      laser_gradient.addColorStop(0, "#FF7777");
      laser_gradient.addColorStop(.5, "#FF0000");
      laser_gradient.addColorStop(1, "#FF7777");
      ctx.fillStyle = laser_gradient;
      ctx.save();
      ctx.translate(laser_pos.x, laser_pos.y);
      ctx.fillRect(0, 0, laser.width, laser.length);
      ctx.restore();
    }
    ctx.translate(ship.x, ship.y);
    ctx.rotate(-(ship.r - Math.PI / 2));
    ctx.scale(2, 2);
    ctx.translate(-ship.x, -ship.y);
    return ctx.translate(camera_pos.x, camera_pos.y);
  };

  gameloop = function(previous_time) {
    var current_time, frame_time;
    if (!running) {
      return;
    }
    current_time = Date.now();
    frame_time = current_time - previous_time;
    if (frame_time > max_frame_time * update_interval) {
      frame_time = max_frame_time;
    }
    time_accumulator += frame_time;
    while (time_accumulator >= update_interval) {
      updateLogic(total_time, update_interval);
      total_time += update_interval;
      time_accumulator -= update_interval;
    }
    return setTimeout((function() {
      return gameloop(current_time);
    }), render_interval);
  };

  init();

  gameloop(0);

  updateScreen();

  KEY = {
    BACKSPACE: 8,
    TAB: 9,
    RETURN: 13,
    ESC: 27,
    SPACE: 32,
    PAGEUP: 33,
    PAGEDOWN: 34,
    END: 35,
    HOME: 36,
    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,
    INSERT: 45,
    DELETE: 46,
    ZERO: 48,
    ONE: 49,
    TWO: 50,
    THREE: 51,
    FOUR: 52,
    FIVE: 53,
    SIX: 54,
    SEVEN: 55,
    EIGHT: 56,
    NINE: 57,
    A: 65,
    B: 66,
    C: 67,
    D: 68,
    E: 69,
    F: 70,
    G: 71,
    H: 72,
    I: 73,
    J: 74,
    K: 75,
    L: 76,
    M: 77,
    N: 78,
    O: 79,
    P: 80,
    Q: 81,
    R: 82,
    S: 83,
    T: 84,
    U: 85,
    V: 86,
    W: 87,
    X: 88,
    Y: 89,
    Z: 90,
    TILDA: 192
  };

}).call(this);
