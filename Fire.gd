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
		area.add_to_group("condition:burning")

func _on_Fire_area_exited(area):
	if area.is_in_group("condition:burning"):
		area.remove_from_group("condition:burning")
