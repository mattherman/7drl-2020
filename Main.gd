extends Node

export (PackedScene) var Enemy
var pathfinder

func _unhandled_input(event):
	if event.is_action_pressed("toggle_show_enemy_paths"):
		Debug.show_enemy_paths = !Debug.show_enemy_paths
	if event.is_action_pressed("toggle_show_enemy_visibility"):
		Debug.show_enemy_visibility = !Debug.show_enemy_visibility
	if event.is_action_pressed("toggle_show_spell_range"):
		Debug.show_spell_range = !Debug.show_spell_range

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
	
func log_message(message):
	$HUD.append_log(message)

func _on_Player_damage_received(prev_health, current_health, type, description):
	$HUD.update_health(current_health)
	var damage = prev_health - current_health
	if type == "melee":
		log_message("The %s hits you for %s damage" % [description, damage])
	elif type == "condition":
		log_message("You are %s for %s damage" % [description, damage])
	else:
		log_message("You receive %s damage" % [damage])

func _on_Player_killed():
	log_message("You have been killed")

func _on_Enemy_damage_received(prev_health, current_health, name, type, description):
	var damage = prev_health - current_health
	if type == "melee":
		log_message("You strike the %s for %s damage" % [name, damage])
	elif type == "condition":
		log_message("The %s is %s for %s damage" % [name, description, damage])
	else:
		log_message("The %s receives %s damage" % [name, damage])
		
func _on_Enemy_alerted(name):
	log_message("The %s sees you" % name)
	
func _on_Enemy_killed(name):
	log_message("You killed the %s" % name)
