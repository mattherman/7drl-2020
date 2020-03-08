extends Area2D

signal damage_received
signal alerted
signal killed

var tile_size = Constants.TILE_SIZE

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var path_color = Color.cornflower

var pathfinder: Pathfinder

export (int) var health = 60
export (int) var detect_radius = 7
export (int) var speed = 2
export (int) var melee_strength = 5
export (String) var display_name = "Goblin"

var target
var path
var hit_pos
var has_been_alerted
var has_been_killed

func _ready():
	add_to_group("can_receive_damage")
	add_to_group("enemies")
	hide()
	var shape = CircleShape2D.new()
	shape.radius = detect_radius * tile_size
	$Visibility/CollisionShape2D.shape = shape
	
func _draw():
	if Debug.show_visibility_range:
		draw_circle(Vector2(), detect_radius * tile_size, vis_color)
	if target && Debug.show_visibility_rays:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), tile_size/6, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
	if path && Debug.show_paths:
		for pos in path:
			draw_circle(pos - position, tile_size/4, path_color)

func start(pos, pf):
	pathfinder = pf
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func tick():
	if has_been_killed:
		return

	if target && is_target_visible():
		if !has_been_alerted:
			alert()
		path = pathfinder.find_path(position, target.position)
		path.pop_front() # pop the initial position
	else:
		has_been_alerted = false
	if path:
		pursue_target()
	update()
		
func is_target_visible():
	hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var target_extents = target.get_node('CollisionShape2D').shape.extents
	var nw = target.position - target_extents
	var se = target.position + target_extents
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)
	for pos in [target.position, nw, ne, se, sw]:
		var result = collision_check(space_state, position, pos)
		if result:
			hit_pos.append(result.position)
			if result.collider.is_in_group("player"):
				return true
	return false

func pursue_target():
	for i in range(0, speed):
		move_or_attack()

func move_or_attack():
	var next = path.front()
	var space_state = get_world_2d().direct_space_state
	var result = collision_check(space_state, position, next);
	if result:
		if result.collider.is_in_group("player"):
			result.collider.damage_received(melee_strength, "melee", display_name)
	else:
		position = next
		path.pop_front()

func collision_check(state, from, to):
	return state.intersect_ray(
		from,
		to,
		[self],
		collision_mask,
		true,
		true
	)
	
func damage_received(damage, type, description):
	$HitEffect.play_damage_animation()
	var prev_health = health
	health = max(prev_health - damage, 0)
	emit_signal("damage_received", prev_health, health, display_name, type, description)
	if health <= 0:
		has_been_killed = true
		emit_signal("killed", display_name)
		queue_free()
	
func alert():
	has_been_alerted = true
	emit_signal("alerted", display_name)

func _on_Visibility_area_entered(area):
	if area is Player:
		target = area

func _on_Visibility_area_exited(area):
	if target == area:
		target = null
