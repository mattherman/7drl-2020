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
	create_enemy($EnemyStartPosition.position)
	create_enemy($EnemyStartPosition2.position)
	create_enemy($EnemyStartPosition3.position)
	$Player.start($StartPosition.position)
	
func create_enemy(pos):
	var enemy = Enemy.instance()
	enemy.connect("damage_received", self, "_on_Enemy_damage_received")
	enemy.connect("alerted", self, "_on_Enemy_alerted")
	enemy.connect("killed", self, "_on_Enemy_killed")
	add_child(enemy)
	enemy.start(pos, pathfinder)

func _on_Player_action_completed():
	var tree = get_tree()
	tree.call_group("condition:burning", "damage_received", 10, "condition", "burned")
	tree.call_group("effects", "tick")
	tree.call_group("enemies", "tick")
	$Player.tick()

func _on_Player_damage_received(prev_health, current_health, type, description):
	$HUD.update_health(current_health)
	var damage = prev_health - current_health
	if type == "melee":
		print("The %s hits you for %s damage" % [description, damage])
	elif type == "condition":
		print("You are %s for %s damage" % [description, damage])
	else:
		print("You receive %s damage" % [damage])

func _on_Player_killed():
	print("You have been killed")

func _on_Enemy_damage_received(prev_health, current_health, name, type, description):
	var damage = prev_health - current_health
	if type == "melee":
		print("You strike the %s for %s damage" % [name, damage])
	elif type == "condition":
		print("The %s is %s for %s damage" % [name, description, damage])
	else:
		print("The %s receives %s damage" % [name, damage])
		
func _on_Enemy_alerted(name):
	print("The %s sees you" % name)
	
func _on_Enemy_killed(name):
	print("You killed the %s" % name)
