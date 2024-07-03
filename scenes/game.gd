extends Node2D
var boardArray = Array()

var tile = preload("res://scenes/tile.tscn")
var piece = preload("res://scenes/piece.tscn")
var physicsPiece = preload("res://pieces/physics_piece.tscn")
var emptyPiece = piece.instantiate()
var turn = "white"
var capturedPieces = []

class spotContainer:
	var tile
	var piece

var curTile
var selectedPiece
var validLocked = false

var movingPiece = false
var activePiece = emptyPiece
var original_coords: Vector2

func createPiece(team, type, x, y):
	var curPiece = piece.instantiate()
	add_child(curPiece)
	curPiece.setTeam(team)
	curPiece.setType(type)
	curPiece.position.y = -192 + 64 * x
	curPiece.position.x = -192 + 64 * y
	curPiece.connect("mouseEntered", pieceMouseEntered)
	curPiece.connect("mouseExited", pieceMouseExited)
	#curPiece.connect("clicked", pieceClicked)
	return curPiece

# Called when the node enters the scene tree for the first time.
func _ready():
	$"(editor_only)board".hide()
	for x in 8:
		boardArray.append([])
		for y in 8:
			curTile = tile.instantiate()
			if ((x + y) % 2) == 1:
				curTile.black()
			else:
				curTile.white()
			add_child(curTile)
			curTile.set_z_index(1)
			curTile.position.y = -192 + 64 * x
			curTile.position.x = -192 + 64 * y
			boardArray[x].append(spotContainer.new())
			boardArray[x][y].tile = curTile
			if (x == 6):
				boardArray[x][y].piece = createPiece("white", "pawn", x, y)
			elif (x == 1):
				boardArray[x][y].piece = createPiece("black", "pawn", x, y)
			elif (x == 7):
				if (y == 0 or y == 7):
					boardArray[x][y].piece = createPiece("white", "castle", x, y)
				elif (y == 1 or y == 6):
					boardArray[x][y].piece = createPiece("white", "knight", x, y)
				elif (y == 2 or y == 5):
					boardArray[x][y].piece = createPiece("white", "bishop", x, y)
				elif (y == 3):
					boardArray[x][y].piece = createPiece("white", "queen", x, y)
				elif (y == 4):
					boardArray[x][y].piece = createPiece("white", "king", x, y)
			elif (x == 0):
				if (y == 0 or y == 7):
					boardArray[x][y].piece = createPiece("black", "castle", x, y)
				elif (y == 1 or y == 6):
					boardArray[x][y].piece = createPiece("black", "knight", x, y)
				elif (y == 2 or y == 5):
					boardArray[x][y].piece = createPiece("black", "bishop", x, y)
				elif (y == 3):
					boardArray[x][y].piece = createPiece("black", "queen", x, y)
				elif (y == 4):
					boardArray[x][y].piece = createPiece("black", "king", x, y)
			else:
				boardArray[x][y].piece = emptyPiece
			boardArray[x][y].piece.set_z_index(2)

func enableStraights(x, y):
	var team = boardArray[x][y].piece.team
	var j
	var k
	for z in 4:
		if (z % 2 == 1):
			j = 1
		else:
			j = -1
		k = j
		if (z <= 1):
			j = 0
		if (z >= 2):
			k = 0
		for i in 7:
			if (y + k + k * i > 7 or x + j + j * i > 7 or y + k + k * i < 0 or x + j + j * i < 0):
				break
			elif (boardArray[x + j + j * i][y + k + k * i].piece.team != "none"):
				if (boardArray[x + j + j * i][y + k + k * i].piece.team != team):
					if (team != turn):
						boardArray[x + j + j * i][y + k + k * i].tile.showEnemyMove()
					else:
						boardArray[x + j + j * i][y + k + k * i].tile.enableCapture()
				break
			else:
				if (team == turn):
					boardArray[x + j + j * i][y + k + k * i].tile.showValid()
				else:
					boardArray[x + j + j * i][y + k + k * i].tile.showEnemyMove()

func enableDiagonals(x, y):
	var team = boardArray[x][y].piece.team
	var j
	var k
	for z in 4:
		if (z < 2):
			j = 1
		else:
			j = -1
		if (z % 2 == 1):
			k = -1
		else:
			k = 1
		for i in 7:
			if (y + k + k * i > 7 or x + j + j * i > 7 or y + k + k * i < 0 or x + j + j * i < 0):
				break
			elif (boardArray[x + j + j * i][y + k + k * i].piece.team != "none"):
				if (boardArray[x + j + j * i][y + k + k * i].piece.team != team):
					if (team != turn):
						boardArray[x + j + j * i][y + k + k * i].tile.showEnemyMove()
					else:
						boardArray[x + j + j * i][y + k + k * i].tile.enableCapture()
				break
			else:
				if (team == turn):
					boardArray[x + j + j * i][y + k + k * i].tile.showValid()
				else:
					boardArray[x + j + j * i][y + k + k * i].tile.showEnemyMove()

func enableMisc(x,y):
	var team = boardArray[x][y].piece.team
	if (boardArray[x][y].piece.type == "pawn"):
		for move in boardArray[x][y].piece.validMoves:
			if (x + move[0] >= 0 and x + move[0] <= 7 and y + move[1] >= 0 and y + move[1] <= 7):
				if (boardArray[x + move[0]][y + move[1]].piece.type == "none"):
					if (team == turn):
						boardArray[x + move[0]][y + move[1]].tile.showValid()
					else:
						boardArray[x + move[0]][y + move[1]].tile.showEnemyMove()
				else:
					break
		if (boardArray[x][y].piece.team == "black"):
			if (y + 1 <= 7):
				if (boardArray[x + 1][y + 1].piece.team == "white"):
					if (team == turn):
						boardArray[x + 1][y + 1].tile.enableCapture()
					else:
						boardArray[x + 1][y + 1].tile.showEnemyMove()
			if (y - 1 >= 0):
				if (boardArray[x + 1][y - 1].piece.team == "white"):
					if (team == turn):
						boardArray[x + 1][y - 1].tile.enableCapture()
					else:
						boardArray[x + 1][y - 1].tile.showEnemyMove()
			if (boardArray[x][y].piece.passantL):
				if (team == turn):
					boardArray[x + 1][y - 1].tile.enableCapture()
				else:
					boardArray[x + 1][y - 1].tile.showEnemyMove()
			elif (boardArray[x][y].piece.passantR):
				if (team == turn):
					boardArray[x + 1][y + 1].tile.enableCapture()
				else:
					boardArray[x + 1][y + 1].tile.showEnemyMove()
		elif (boardArray[x][y].piece.team == "white"):
			if (y + 1 <= 7):
				if (boardArray[x - 1][y + 1].piece.team == "black"):
					if (team == turn):
						boardArray[x - 1][y + 1].tile.enableCapture()
					else:
						boardArray[x - 1][y + 1].tile.showEnemyMove()
			if (y - 1 >= 0):
				if (boardArray[x - 1][y - 1].piece.team == "black"):
					if (team == turn):
						boardArray[x - 1][y - 1].tile.enableCapture()
					else:
						boardArray[x - 1][y - 1].tile.showEnemyMove()
			if (boardArray[x][y].piece.passantL):
				if (team == turn):
					boardArray[x - 1][y - 1].tile.enableCapture()
				else:
					boardArray[x - 1][y - 1].tile.showEnemyMove()
			elif (boardArray[x][y].piece.passantR):
				if (team == turn):
					boardArray[x - 1][y + 1].tile.enableCapture()
				else:
					boardArray[x - 1][y + 1].tile.showEnemyMove()
	else:
		for move in boardArray[x][y].piece.validMoves:
			if (x + move[0] >= 0 and x + move[0] <= 7 and y + move[1] >= 0 and y + move[1] <= 7):
				if (boardArray[x + move[0]][y + move[1]].piece.type == "none"):
					if (team == turn):
						boardArray[x + move[0]][y + move[1]].tile.showValid()
					else:
						boardArray[x + move[0]][y + move[1]].tile.showEnemyMove()
				elif (boardArray[x][y].piece.team != boardArray[x + move[0]][y + move[1]].piece.team):
					if (team == turn):
						boardArray[x + move[0]][y + move[1]].tile.enableCapture()
					else:
						boardArray[x + move[0]][y + move[1]].tile.showEnemyMove()

func disableAll():
	for x in 8:
		for y in 8:
			boardArray[x][y].tile.hideValid()
			boardArray[x][y].tile.disableCapture()
			boardArray[x][y].tile.hideEnemyMove()

func pieceMouseEntered(x, y):
	if (not movingPiece): # and boardArray[x][y].piece.team == turn):
		disableAll()
		if (boardArray[x][y].piece.canMoveStraight):
			enableStraights(x, y)
		if (boardArray[x][y].piece.canMoveDiagonal):
			enableDiagonals(x, y)
		enableMisc(x, y)

func pieceMouseExited(x, y):
	if (not movingPiece):
		var mouseTileCoords = mouseCoords()
		if (mouseTileCoords.x < 0 or mouseTileCoords.x > 7 or mouseTileCoords.y < 0 or mouseTileCoords.y > 7):
			disableAll()
			return
		if (boardArray[mouseTileCoords.x][mouseTileCoords.y].piece) == emptyPiece:
			disableAll()

func _process(delta):
	if movingPiece:
		activePiece.position = get_global_mouse_position()

func _input(event):
	if event.is_action_pressed("rightClick"):
		activePiece.position = tileToPos(original_coords)
		activePiece.set_z_index(2)
		movingPiece = false
		var mouseTile = mouseCoords()
		if (0 > mouseTile.x or 7 < mouseTile.x or 0 > mouseTile.y or 7 < mouseTile.y):
				return
		if (boardArray[mouseTile.x][mouseTile.y].piece.type != "none" and boardArray[mouseTile.x][mouseTile.y].piece.team == turn):
			validLocked = true
			disableAll()
			await get_tree().create_timer(0.001).timeout
			if (boardArray[mouseTile.x][mouseTile.y].piece.canMoveStraight):
				enableStraights(mouseTile.x, mouseTile.y)
			if (boardArray[mouseTile.x][mouseTile.y].piece.canMoveDiagonal):
				enableDiagonals(mouseTile.x, mouseTile.y)
			enableMisc(mouseTile.x, mouseTile.y)
			validLocked = false
	if event.is_action_pressed("leftClick"):
		var mouseTileCoords = mouseCoords()
		if (mouseTileCoords.x < 0 or mouseTileCoords.x > 7 or mouseTileCoords.y < 0 or mouseTileCoords.y > 7):
			return
		if (not movingPiece):
			activePiece = boardArray[mouseTileCoords.x][mouseTileCoords.y].piece
			if (activePiece.team == turn):
				original_coords = Vector2(mouseTileCoords.x, mouseTileCoords.y)
				activePiece.set_z_index(3)
				movingPiece = true
			else:
				activePiece = emptyPiece
		elif movingPiece:
			if (0 > mouseTileCoords.x or 7 < mouseTileCoords.x or 0 > mouseTileCoords.y or 7 < mouseTileCoords.y):
				return
			var mouseTile = boardArray[mouseTileCoords.x][mouseTileCoords.y]
			if mouseTile.tile.isValid():
				disableAll()
				if activePiece.type == "pawn":
					if len(activePiece.validMoves) == 2:
						if activePiece.team == "black" and mouseTileCoords.x == 3:
							if (mouseTileCoords.y + 1 <= 7):
								if (boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.type == "pawn" and boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.team == "white"):
									boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.passantL = true
							if (mouseTileCoords.y - 1 >= 0):
								if (boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.type == "pawn" and boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.team == "white"):
									boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.passantR = true
						elif activePiece.team == "white" and mouseTileCoords.x == 4:
							if (mouseTileCoords.y + 1 <= 7):
								if (boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.type == "pawn" and boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.team == "black"):
									boardArray[mouseTileCoords.x][mouseTileCoords.y + 1].piece.passantL = true
							if (mouseTileCoords.y - 1 >= 0):
								if (boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.type == "pawn" and boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.team == "black"):
									boardArray[mouseTileCoords.x][mouseTileCoords.y - 1].piece.passantR = true
						activePiece.validMoves.remove_at(1)
					if activePiece.team == "black" and mouseTileCoords.x == 7:
						print("black pawn reached end, need to take user input")
					elif activePiece.team == "white" and mouseTileCoords.x == 0:
						print("white pawn reached end, need to take user input")
				mouseTile.piece = activePiece
				boardArray[original_coords.x][original_coords.y].piece = emptyPiece
				activePiece.position = tileToPos(mouseTileCoords)
				activePiece.set_z_index(2)
				movingPiece = false
				activePiece = emptyPiece
				changeTurn()
			elif mouseTile.tile.isCapturable():
				disableAll()
				capturedPieces.append(mouseTile.piece)
				var newPhysicsPiece = physicsPiece.instantiate()
				newPhysicsPiece.create(mouseTile.piece)
				add_child(newPhysicsPiece)
				newPhysicsPiece.set_z_index(0)
				mouseTile.piece.queue_free()
				mouseTile.piece = activePiece
				boardArray[original_coords.x][original_coords.y].piece = emptyPiece
				activePiece.position = tileToPos(mouseTileCoords)
				activePiece.set_z_index(2)
				movingPiece = false
				activePiece = emptyPiece
				changeTurn()
			else:
				#show red tile and return piece, didn't like this
				disableAll()
				mouseTile.tile.showInvalid()
				activePiece.position = tileToPos(original_coords)
				activePiece.set_z_index(2)
				movingPiece = false
				mouseTile = mouseCoords()
				if (boardArray[mouseTile.x][mouseTile.y].piece.type != "none"):
					validLocked = true
					disableAll()
					await get_tree().create_timer(0.001).timeout
					if (boardArray[mouseTile.x][mouseTile.y].piece.canMoveStraight):
						enableStraights(mouseTile.x, mouseTile.y)
					if (boardArray[mouseTile.x][mouseTile.y].piece.canMoveDiagonal):
						enableDiagonals(mouseTile.x, mouseTile.y)
					enableMisc(mouseTile.x, mouseTile.y)
					validLocked = false

func mouseCoords():
	return Vector2(floor((224 + get_local_mouse_position().y) / 64), floor((224 + get_local_mouse_position().x) / 64))

func tileToPos(vector):
	return Vector2(-192 + 64 * vector.y, -192 + 64 * vector.x)

func changeTurn():
	if (turn == "black"):
		for x in 2:
			for y in 8:
				if (boardArray[x + 4][y].piece.team == "black"):
					boardArray[x + 4][y].piece.passantL = false
					boardArray[x + 4][y].piece.passantR = false
		turn = "white"
		$whiteTurnBg.show()
		$BlackTurnBg.hide()
	elif (turn == "white"):
		for x in 2:
			for y in 8:
				if (boardArray[x + 2][y].piece.team == "white"):
					boardArray[x + 2][y].piece.passantL = false
					boardArray[x + 2][y].piece.passantR = false
		turn = "black"
		$BlackTurnBg.show()
		$whiteTurnBg.hide()
