extends Area2D

class_name Player

export (PackedScene) var Target
export (PackedScene) var Fire

signal action_completed
signal damage_received
signal spell_cast
signal killed

var tile_size = Constants.TILE_SIZE
var inputs = Constants.INPUTS

enum {STATE_IDLE, STATE_ACTIVE, STATE_TARGETING}
var state = STATE_ACTIVE

export (int) var health = 100
export (int) var melee_strength_min = 5
export (int) var melee_strength_max = 10

func _ready():
	hide()
	add_to_group("player")
	add_to_group("can_receive_damage")
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()
	
func tick():
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
	target.connect("target_canceled", self, "cancel_cast_spell")
	add_child(target)
	
func finish_cast_spell(selected_position):
	var flame = Fire.instance()
	flame.position = position + selected_position
	get_parent().add_child(flame)
	emit_signal("spell_cast", "Flame")
	action_completed()
	
func cancel_cast_spell():
	state = STATE_ACTIVE

func move(dir):
	var target_pos = position + (inputs[dir] * tile_size)
	var state = get_world_2d().direct_space_state
	var result = collision_check(state, position, target_pos)
	if result:
		if result.collider.is_in_group("enemies"):
			var damage = randi() % (melee_strength_max - melee_strength_min) + melee_strength_min
			result.collider.damage_received(damage, "melee", "")
			action_completed()
	else:
		position = target_pos
		action_completed()
		
func collision_check(state, from, to):
	return state.intersect_ray(
		from,
		to,
		[self],
		collision_mask,
		true,
		true
	)
		
func action_completed():
	state = STATE_IDLE
	emit_signal("action_completed")
	
func damage_received(damage, type, description):
	$HitEffect.play_damage_animation()
	var prev_health = health
	health = max(prev_health - damage, 0)
	emit_signal("damage_received", prev_health, health, type, description)
	if health <= 0:
		emit_signal("killed")
