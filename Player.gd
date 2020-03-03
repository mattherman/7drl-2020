extends Area2D

var tile_size = 16
var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_up_right": Vector2.UP + Vector2.RIGHT,
	"ui_up_left": Vector2.UP + Vector2.LEFT,
	"ui_down_right": Vector2.DOWN + Vector2.RIGHT,
	"ui_down_left": Vector2.DOWN + Vector2.LEFT
}
var casting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func _unhandled_input(event):
	if event.is_action_pressed("cast_1"):
		cast_spell()
	if event.is_action_pressed("ui_accept"):
		finish_cast_spell()
	else:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)
			
func cast_spell():
	casting = true
	$Selector.start()
	
func finish_cast_spell():
	casting = false
	$Selector.stop()

func move(dir):
	var ray = $Selector/CollisionRay if casting else $CollisionRay
	ray.cast_to = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		var move = inputs[dir] * tile_size
		if casting:
			$Selector.position += move
		else:
			position += move
