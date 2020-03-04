extends CanvasLayer

func _ready():
	pass # Replace with function body.

func update_health(health):
	$HealthLabel.text = str(health)
