extends Node

export (PackedScene) var Enemy
var pathfinder

func _unhandled_input(event):
	if event.is_action_pressed("toggle_show_paths"):
		Debug.show_paths = !Debug.show_paths
	if event.is_action_pressed("toggle_show_visibility_range"):
		Debug.show_visibility_range = !Debug.show_visibility_range
	if event.is_action_pressed("toggle_show_visibility_rays"):
		Debug.show_visibility_rays = !Debug.show_visibility_rays

func _ready():
	pathfinder = Pathfinder.new($TileMap)
	var enemy = Enemy.instance()
	add_child(enemy)
	enemy.start($EnemyStartPosition.position, pathfinder)
	$Player.start($StartPosition.position)

func _on_Player_action_completed():
	var tree = get_tree()
	tree.call_group("condition:burning", "damage_received", 10)
	tree.call_group("effects", "tick")
	tree.call_group("enemies", "tick")
	$Player.tick()

func _on_Player_damage_received(new_health):
	$HUD.update_health(new_health)
