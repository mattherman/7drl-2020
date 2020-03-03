extends Area2D

var hidden = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
func start():
	position = Vector2(0, 0)
	show()
	$Flash.start()
	
func stop():
	$Flash.stop()
	hide()

func _on_Flash_timeout():
	if hidden:
		show()
	else:
		hide()
	hidden = !hidden
