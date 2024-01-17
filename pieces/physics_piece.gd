extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create(piece):
	$Sprite2D.set_texture(piece.get_node('Sprite2D').get_texture())
	global_position = piece.global_position
	var randomVelocity = (randi() % 500) + 500
	linear_velocity = randomVelocity * Vector2(2 * randf() - 1, 2 * randf() - 1)
