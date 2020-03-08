extends Area2D

signal target_selected
signal target_canceled

var tile_size = Constants.TILE_SIZE
var inputs = Constants.INPUTS

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

export (int) var cast_radius = 5
var within_range = true
var has_line_of_sight = true
var parent_pos

func _ready():
	position = Vector2(0, 0)
	parent_pos = get_parent().position
	var shape = CircleShape2D.new()
	shape.radius = cast_radius * tile_size
	$Visibility/CollisionShape2D.shape = shape
	
func _draw():
	if Debug.show_spell_range:
		draw_circle(Vector2(), cast_radius * tile_size, vis_color)
		draw_line(Vector2(), origin(), laser_color)
	
func _process(_delta):
	if valid_target():
		$Sprite.modulate = Color(1, 1, 1, 1)
	else:
		$Sprite.modulate = Color.red

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") && valid_target():
		select_target()
	if event.is_action_pressed("ui_cancel"):
		cancel_target()
	else:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)

func select_target():
	emit_signal("target_selected", position)
	queue_free()
	
func cancel_target():
	emit_signal("target_canceled")
	queue_free()

func origin():
	return parent_pos - global_position
	
func valid_target():
	return within_range && has_line_of_sight

func move(dir):
	$CollisionRay.cast_to = inputs[dir] * tile_size
	$CollisionRay.force_raycast_update()
	if !$CollisionRay.is_colliding():
		position += inputs[dir] * tile_size
		$CollisionRay.cast_to = origin()
		$CollisionRay.force_raycast_update()
		has_line_of_sight = !$CollisionRay.is_colliding()
		update()

func _on_Visibility_area_exited(area):
	if area is Player:
		within_range = false

func _on_Visibility_area_entered(area):
	if area is Player:
		within_range = true
