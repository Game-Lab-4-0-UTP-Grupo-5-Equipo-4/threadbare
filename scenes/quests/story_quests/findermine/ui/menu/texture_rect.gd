extends TextureRect

func _process(delta):
	position += (get_global_mouse_position()/3*delta)-position
