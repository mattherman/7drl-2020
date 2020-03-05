extends Node

func _ready():
	$Player.start($StartPosition.position)

func _on_Player_action_completed():
	var tree = get_tree()
	tree.call_group("condition:burning", "damage_received", 10)
	tree.call_group("effects", "tick")
	tree.call_group("enemies", "tick")
	$Player.tick()

func _on_Player_damage_received(new_health):
	$HUD.update_health(new_health)
