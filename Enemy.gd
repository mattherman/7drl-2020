extends Area2D

var tile_size = Constants.TILE_SIZE

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var path_color = Color.cornflower

var pathfinder: Pathfinder

export (int) var health = 15
export (int) var detect_radius = 7
export (int) var speed = 2
var target
var path
var hit_pos

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
	if health <= 0:
		queue_free()
	if target && is_target_visible():
		path = pathfinder.find_path(position, target.position)
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
		var result = space_state.intersect_ray(position,
				pos, [self], collision_mask, true, true)
		if result:
			hit_pos.append(result.position)
			if result.collider.name == "Player":
				return true
	return false

func pursue_target():
	print("enemy: pursuing")
	print(path)
	
func can_move(pos):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position,
				pos, [self], collision_mask, true, true)
	if result:
		print(result.collider)
		return false
	else:
		return true
	
func damage_received(damage):
	health = max(health - damage, 0)

func _on_Visibility_area_entered(area):
	if area is Player:
		target = area

func _on_Visibility_area_exited(area):
	if target == area:
		target = null
