extends Area2D

var remaining_ticks = 5

func _ready():
	add_to_group("effects")
	
func tick():
	remaining_ticks -= 1
	if remaining_ticks <= 0:
		queue_free()
