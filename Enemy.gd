extends Area2D

var tile_size = Constants.TILE_SIZE

var health = 15
var target

func _ready():
	add_to_group("can_receive_damage")
	add_to_group("enemies")
	hide()
	
func start(pos, player):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	target = player
	show()

func tick():
	if health <= 0:
		queue_free()
	$LineOfSightRay.cast_to = target.position
	$LineOfSightRay.force_raycast_update()
	if $LineOfSightRay.is_colliding():
		print("enemy: position %s" % position)
		print("ray_collision: position %s" % $LineOfSightRay.get_collision_point())
		print("ray_colliction: collider %s" % $LineOfSightRay.get_collider())
		pursue_player()

func pursue_player():
	print("enemy: pursue")
	
func damage_received(damage):
	health = max(health - damage, 0)
