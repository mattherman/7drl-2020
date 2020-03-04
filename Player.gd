extends Area2D

onready var Target = preload("res://Target.tscn")

var tile_size = Constants.TILE_SIZE
var inputs = Constants.INPUTS

enum {STATE_IDLE, STATE_TARGETING}
var state = STATE_IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func _unhandled_input(event):
	if state != STATE_IDLE:
		return

	if event.is_action_pressed("cast_1"):
		cast_spell()
	else:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)
			
func cast_spell():
	state = STATE_TARGETING
	var target = Target.instance()
	target.connect("target_selected", self, "finish_cast_spell")
	add_child(target)
	
func finish_cast_spell(selected_position):
	print("receive: target_selected %s" % selected_position)
	state = STATE_IDLE

func move(dir):
	$CollisionRay.cast_to = inputs[dir] * tile_size
	$CollisionRay.force_raycast_update()
	if !$CollisionRay.is_colliding():
		position += inputs[dir] * tile_size
