# Thomas Manning
#
# A ship game for fun

# --------------- etc ---------------
@print = print = console.log.bind(console)

# --------------- Global Variables ---------------
canvas = document.getElementById("canvas")
ctx = canvas.getContext("2d")

counter = 0

# --------------- Settings ---------------
fps = 60
ups = 60
update_interval = 1000 / ups
render_interval = 1000 / fps
max_frame_time = (ups / 4)
time_accumulator = 0
total_time = 0
running = true
paused = false

ship =
	x: 500
	y: 300
	r: Math.PI/2
	speed: 0
	fire: false

# --------------- Functions ---------------
keys =
	right: false
	left: false
	up: false
	down: false
	space: false

keydown = (e) ->
	switch e.keyCode
		when KEY.RIGHT
			keys.right = true
		when KEY.LEFT
			keys.left = true
		when KEY.UP
			keys.up = true
		when KEY.DOWN
			keys.down = true
		when KEY.SPACE
			keys.space = true

keyup = (e) ->
	switch e.keyCode
		when KEY.RIGHT
			keys.right = false
		when KEY.LEFT
			keys.left = false
		when KEY.UP
			keys.up = false
		when KEY.DOWN
			keys.down = false
		when KEY.SPACE
			keys.space = false

init = () ->
	canvas.width = window.innerWidth
	canvas.height = window.innerHeight
	document.addEventListener('keydown', keydown)
	document.addEventListener('keyup', keyup)


updateLogic = (time) ->
	ACCELERATION = (10 / ups)
	SPEED_LIMIT = 6
	counter += 1
	ship.x -= ship.speed * Math.cos(ship.r)
	ship.y -= ship.speed * Math.sin(ship.r)

	background = document.getElementById "background3"
	ship.x = -ship.x if Math.abs(ship.x) > background.width / 2 - edge_buffer.x
	ship.y = -ship.y if Math.abs(ship.y) > background.height / 2 - edge_buffer.y

	if keys.right
		ship.r = (ship.r + (Math.PI / ups)) % (2 * Math.PI)
	if keys.left
		ship.r = (ship.r - (Math.PI / ups)) % (2 * Math.PI)
	if keys.up
		ship.speed += ACCELERATION if ship.speed < SPEED_LIMIT
	if keys.down
		ship.speed -= ACCELERATION if ship.speed > ACCELERATION

	ship.fire = keys.space


last_turn = 0
camera_pos = {x: 0, y: 0}
edge_buffer = {x: 100, y: 100}
buffer_diff = {x: 0, y: 0}
updateScreen = () ->
	window.requestAnimationFrame(updateScreen)

	# print buffer_diff.y
	# print buffer_diff.y < camera_pos.y
	buffer_diff =
		x_top: ship.x - (camera_pos.x + edge_buffer.x)
		x_bottom: (camera_pos.x + canvas.width - edge_buffer.x) - ship.x
		y_top: ship.y - (camera_pos.y + edge_buffer.y)
		y_bottom: (camera_pos.y + canvas.height - edge_buffer.y) - ship.y

	# print camera_pos.y
	# print buffer_diff.y
	camera_pos.x += buffer_diff.x_top if buffer_diff.x_top < 0
	camera_pos.y += buffer_diff.y_top if buffer_diff.y_top < 0

	camera_pos.x -= buffer_diff.x_bottom if buffer_diff.x_bottom < 0
	camera_pos.y -= buffer_diff.y_bottom if buffer_diff.y_bottom < 0

	# print camera_pos.x

	############### Absolute Positioning ###############

	# --------------- Background ---------------
	# background1 = document.getElementById "background1"
	# background2 = document.getElementById "background2"
	# ctx.drawImage(background1, 0, 0)
	# ctx.drawImage(background2, 0, -background2.height)
	background3 = document.getElementById "background3"
	sx = (background3.width / 2) + camera_pos.x
	sy = (background3.height / 2) + camera_pos.y
	ctx.drawImage(background3, sx, sy, canvas.width, canvas.height, 0, 0, canvas.width, canvas.height)

	# Draw where the scroll "edge" is
	# ctx.strokeStyle = "white"
	# ctx.strokeRect(edge_buffer.x, edge_buffer.y, canvas.width - 2*edge_buffer.x, canvas.height - 2*edge_buffer.y)

	####################################################
	ctx.translate(-camera_pos.x, -camera_pos.y)
	############### Relative Positioning ###############
	# ctx.strokeRect(-background3.width / 2, -background3.height / 2, background3.width, background3.height)

	# --------------- Select Ship Image ---------------
	turn = 5 - (ship.speed // 5)
	turn = 5 if turn >= 5
	if turn > last_turn
		turn = last_turn + 1
		if counter % (ups) == 0
			last_turn += 1

	suffix = switch
		when keys.right then "_right" + turn
		when keys.left then "_left" + turn
		else ""

	ship_image = document.getElementById "fighter"+suffix

	ctx.translate(ship.x, ship.y)
	ctx.scale(.5, .5)
	ctx.rotate(ship.r - Math.PI/2)
	ctx.translate(-ship.x, -ship.y)
	ctx.drawImage(ship_image, ship.x - ship_image.width / 2, ship.y - ship_image.height / 2)
	if ship.fire
		ship.laser_mount =
			x: ship.x
			y: ship.y - ship_image.height / 2 + 15
		laser =
			width: 7
			length: 2000
		laser_pos =
			x: ship.laser_mount.x - laser.width / 2
			y: ship.laser_mount.y - laser.length

		laser_gradient = ctx.createLinearGradient(0, 0, laser.width, 0)
		laser_gradient.addColorStop(0, "#FF7777")
		laser_gradient.addColorStop(.5, "#FF0000")
		laser_gradient.addColorStop(1, "#FF7777")
		ctx.fillStyle = laser_gradient
		
		ctx.save()
		ctx.translate(laser_pos.x, laser_pos.y)
		ctx.fillRect(0, 0, laser.width, laser.length)
		ctx.restore()
	ctx.translate(ship.x, ship.y)
	ctx.rotate(-(ship.r - Math.PI/2))
	ctx.scale(2, 2)
	ctx.translate(-ship.x, -ship.y)

	ctx.translate(camera_pos.x, camera_pos.y)


gameloop = (previous_time) ->
	if not running
		return

	current_time = Date.now()
	frame_time = current_time - previous_time

	if frame_time > max_frame_time * update_interval
		frame_time = max_frame_time

	time_accumulator += frame_time

	while time_accumulator >= update_interval
		updateLogic(total_time, update_interval)
		total_time += update_interval
		time_accumulator -= update_interval

	setTimeout((-> gameloop(current_time)), render_interval)

init()
gameloop(0)
updateScreen()

# --------------- Other Stuff... ---------------
KEY =
	BACKSPACE: 8,
	TAB:       9,
	RETURN:   13,
	ESC:      27,
	SPACE:    32,
	PAGEUP:   33,
	PAGEDOWN: 34,
	END:      35,
	HOME:     36,
	LEFT:     37,
	UP:       38,
	RIGHT:    39,
	DOWN:     40,
	INSERT:   45,
	DELETE:   46,
	ZERO:     48, ONE: 49, TWO: 50, THREE: 51, FOUR: 52, FIVE: 53, SIX: 54, SEVEN: 55, EIGHT: 56, NINE: 57,
	A:        65, B: 66, C: 67, D: 68, E: 69, F: 70, G: 71, H: 72, I: 73, J: 74, K: 75, L: 76, M: 77,
	N: 	  78, O: 79, P: 80, Q: 81, R: 82, S: 83, T: 84, U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90,
	TILDA:    192

# KEY =
# 	8: "backspace"
# 	9: "tab"
# 	13: "return"
# 	27: "esc"
# 	32: "space"
# 	33: "pageup"
# 	34: "pagedown"
# 	35: "end"
# 	36: "home"
# 	37: "left"
# 	38: "up"
# 	39: "right"
# 	40: "down"
# 	45: "insert"
# 	46: "delete"
# 	48: "zero"
# 	49: "one"
# 	50: "two"
# 	51: "three"
# 	52: "four"
# 	53: "five"
# 	54: "six"
# 	55: "seven"
# 	56: "eight"
# 	57: "nine"
# 	65: "a"
# 	66: "b"
# 	67: "c"
# 	68: "d"
# 	69: "e"
# 	70: "f"
# 	71: "g"
# 	72: "h"
# 	73: "i"
# 	74: "j"
# 	75: "k"
# 	76: "l"
# 	77: "m"
# 	78: "n"
# 	79: "o"
# 	80: "p"
# 	81: "q"
# 	82: "r"
# 	83: "s"
# 	84: "t"
# 	85: "u"
# 	86: "v"
# 	87: "w"
# 	88: "x"
# 	89: "y"
# 	90: "z"
# 	192: "tilda"

# --------------- Old Code Bits ---------------

# # --------------- Flip the buffers ---------------
# # Flip which buffer is visible
# buffers[1 - current_buffer].style.visibility = 'none'
# buffers[current_buffer].style.visibility = 'visible'
# # Toggle the current buffer
# current_buffer = 1 - current_buffer
# # Set the new current_buffer to be the one we work with (it's the hidden one
# canvas = buffers[current_buffer]
# ctx = canvas.getContext("2d")

# canvas1 = document.getElementById("canvas1")
# canvas2 = document.getElementById("canvas2")
# buffers = [canvas1, canvas2]
# current_buffer = 0
