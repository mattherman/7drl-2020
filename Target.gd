extends Area2D

signal target_selected

var tile_size = Constants.TILE_SIZE
var inputs = Constants.INPUTS

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(0, 0)
	$Flash.start()

func _on_Flash_timeout():
	if visible:
		hide()
	else:
		show()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		select_target()
	else:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)

func select_target():
	print("emit: target_selected")
	emit_signal("target_selected", position)
	queue_free()

func move(dir):
	$CollisionRay.cast_to = inputs[dir] * tile_size
	$CollisionRay.force_raycast_update()
	if !$CollisionRay.is_colliding():
		position += inputs[dir] * tile_size
