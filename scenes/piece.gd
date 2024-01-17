extends Node2D


signal mouseEntered(x, y)
signal mouseExited(x, y)
signal clicked(x, y)

var type = "none"
var team = "none"
var validMoves = []
var canMoveStraight := false
var canMoveDiagonal := false
var passantL = false
var passantR = false

func _on_area_2d_mouse_entered():
	mouseEntered.emit((self.position.y + 192) / 64, (self.position.x + 192) / 64)

func _on_area_2d_mouse_exited():
	mouseExited.emit((self.position.y + 192) / 64, (self.position.x + 192) / 64)
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		clicked.emit((self.position.y + 192) / 64, (self.position.x + 192) / 64)

func setTeam(teamName):
	if teamName == "black":
		team = "black"
	elif teamName == "white":
		team = "white"
	else:
		print("Invalid team set for ", self)

func setType(typeName):
	if team == "black":
		if typeName == "pawn":
			$Sprite2D.set_texture(load("res://pieces/blackpawn.png"))
			validMoves = [ [1, 0], [2, 0] ]
		elif typeName == "castle":
			$Sprite2D.set_texture(load("res://pieces/blackcastle.png"))
			canMoveStraight = true
		elif typeName == "knight":
			$Sprite2D.set_texture(load("res://pieces/blackknight.png"))
			validMoves = [ [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1] ]
		elif typeName == "bishop":
			$Sprite2D.set_texture(load("res://pieces/blackbishop.png"))
			canMoveDiagonal = true
		elif typeName == "queen":
			$Sprite2D.set_texture(load("res://pieces/blackqueen.png"))
			canMoveStraight = true
			canMoveDiagonal = true
		elif typeName == "king":
			type = "king"
			$Sprite2D.set_texture(load("res://pieces/blackking.png"))
			validMoves = [ [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0] ]
		else:
			print("Invalid piece type for ", self)
			return
	elif team == "white":
		if typeName == "pawn":
			$Sprite2D.set_texture(load("res://pieces/whitepawn.png"))
			validMoves = [ [-1, 0], [-2, 0] ]
		elif typeName == "castle":
			$Sprite2D.set_texture(load("res://pieces/whitecastle.png"))
			canMoveStraight = true
		elif typeName == "knight":
			$Sprite2D.set_texture(load("res://pieces/whiteknight.png"))
			validMoves = [ [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1] ]
		elif typeName == "bishop":
			$Sprite2D.set_texture(load("res://pieces/whitebishop.png"))
			canMoveDiagonal = true
		elif typeName == "queen":
			$Sprite2D.set_texture(load("res://pieces/whitequeen.png"))
			canMoveStraight = true
			canMoveDiagonal = true
		elif typeName == "king":
			$Sprite2D.set_texture(load("res://pieces/whiteking.png"))
			validMoves = [ [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0] ] 
		else:
			print("Invalid piece type for ", self)
			return
	else:
		print("Invalid team for ", self)
	type = typeName
		

