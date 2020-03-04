extends Node

func _ready():
	$Player.start($StartPosition.position)

func _on_Player_action_completed():
	get_tree().call_group("effects", "tick")
	$Player.activate()

func _on_Player_damage_received(new_health):
	$HUD.update_health(new_health)
