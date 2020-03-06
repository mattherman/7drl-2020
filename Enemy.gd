extends Area2D

var tile_size = Constants.TILE_SIZE

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var health = 15
export (int) var detect_radius = 7
var target
var hit_pos

func _ready():
	add_to_group("can_receive_damage")
	add_to_group("enemies")
	hide()
	var shape = CircleShape2D.new()
	shape.radius = detect_radius * tile_size
	$Visibility/CollisionShape2D.shape = shape
	
func _draw():
	draw_circle(Vector2(), detect_radius * tile_size, vis_color)
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 5, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)

func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func tick():
	if health <= 0:
		queue_free()
	if target && is_target_visible():
		pursue_player()
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

func pursue_player():
	print("enemy: pursue")
	
func damage_received(damage):
	health = max(health - damage, 0)

func _on_Visibility_area_entered(area):
	if area is Player:
		target = area

func _on_Visibility_area_exited(area):
	if target == area:
		target = null
