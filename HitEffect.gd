extends Tween

func play_damage_animation():
	var sprite = get_parent().get_node("Sprite")
	interpolate_property(
		sprite, "modulate",
		Color.red, Color(1, 1, 1, 1),
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	start()
