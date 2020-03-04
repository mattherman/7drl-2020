extends Area2D

var remaining_ticks = 5

func _ready():
	add_to_group("effects")
	
func tick():
	if remaining_ticks <= 0:
		queue_free()
	remaining_ticks -= 1

func _on_Fire_area_entered(area):
	if area.is_in_group("can_receive_damage"):
		area.damage_received(10)
