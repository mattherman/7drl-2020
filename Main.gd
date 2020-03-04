extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.start($StartPosition.position)


func _on_Player_action_completed():
	get_tree().call_group("effects", "tick")
	$Player.activate()
