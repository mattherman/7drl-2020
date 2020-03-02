extends Area2D

var tile_size = 16
var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	$CollisionRay.cast_to = inputs[dir] * tile_size
	$CollisionRay.force_raycast_update()
	if !$CollisionRay.is_colliding():
		position += inputs[dir] * tile_size
