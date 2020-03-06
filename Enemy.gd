extends Area2D

var tile_size = Constants.TILE_SIZE

var health = 15
var detect_radius = 4 * tile_size
var target: Player
var vis_color = Color(.867, .91, .247, 0.1)

func _ready():
	add_to_group("can_receive_damage")
	add_to_group("enemies")
	hide()
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	
func _draw():
	draw_circle(Vector2(), detect_radius, vis_color)
	
func start(pos):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	show()

func tick():
	if health <= 0:
		queue_free()
	if target:
		pursue_player()
#	$LineOfSightRay.cast_to = target.position
#	$LineOfSightRay.force_raycast_update()
#	if $LineOfSightRay.is_colliding():
#		print("enemy: position %s" % position)
#		print("ray_collision: position %s" % $LineOfSightRay.get_collision_point())
#		print("ray_colliction: collider %s" % $LineOfSightRay.get_collider())
#		pursue_player()

func pursue_player():
	print("enemy: pursue")
	
func damage_received(damage):
	health = max(health - damage, 0)

func _on_Visibility_area_entered(area):
	if area is Player:
		target = area as Player

func _on_Visibility_area_exited(area):
	target = null
