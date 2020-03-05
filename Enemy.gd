extends Area2D

var tile_size = Constants.TILE_SIZE

var health = 15
var target_player

func _ready():
	add_to_group("can_receive_damage")
	add_to_group("enemies")
	hide()
	
func start(pos, player):
	position = pos.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	target_player = player
	show()

func tick():
	if health <= 0:
		queue_free()
	$LineOfSightRay.cast_to = target_player.position
	$LineOfSightRay.force_raycast_update()
	if $LineOfSightRay.is_colliding():
		pursue_player()

func pursue_player():
	print("enemy: pursue")
	
func damage_received(damage):
	health = max(health - damage, 0)
