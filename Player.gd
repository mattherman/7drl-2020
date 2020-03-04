extends Area2D

class_name Player

onready var Target = preload("res://Target.tscn")
onready var Fire = preload("res://Fire.tscn")

signal action_completed
signal damage_received

var tile_size = Constants.TILE_SIZE
var inputs = Constants.INPUTS

enum {STATE_IDLE, STATE_ACTIVE, STATE_TARGETING}
var state = STATE_ACTIVE

var health = 100

func _ready():
	add_to_group("can_receive_damage")
	hide()
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()
	
func activate():
	state = STATE_ACTIVE

func _unhandled_input(event):
	if state != STATE_ACTIVE:
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
	var flame = Fire.instance()
	flame.position = position + selected_position
	get_parent().add_child(flame)
	action_completed()

func move(dir):
	$CollisionRay.cast_to = inputs[dir] * tile_size
	$CollisionRay.force_raycast_update()
	if !$CollisionRay.is_colliding():
		position += inputs[dir] * tile_size
		action_completed()
		
func action_completed():
	state = STATE_IDLE
	print("emit: action_completed")
	emit_signal("action_completed")
	
func damage_received(damage):
	health = max(health - damage, 0)
	emit_signal("damage_received", health)
