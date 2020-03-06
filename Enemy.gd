extends Area2D

var tile_size = Constants.TILE_SIZE

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var health = 15
export (int) var detect_radius = 7
var target
var collision_point

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
		draw_line(Vector2(), (collision_point - position), laser_color)
		draw_circle((collision_point - position), 5, laser_color)
	
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
	collision_point = target.position
	$LineOfSightRay.cast_to = target.position - position
	$LineOfSightRay.force_raycast_update()
	if $LineOfSightRay.is_colliding():
		collision_point = $LineOfSightRay.get_collision_point()
		return false
	else:
		return true

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
