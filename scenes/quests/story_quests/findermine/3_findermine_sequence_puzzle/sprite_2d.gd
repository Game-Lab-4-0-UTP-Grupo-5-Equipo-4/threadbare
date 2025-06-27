extends Sprite2D

var is_dragging = false
var initial_position: Vector2

func _ready():
	initial_position = position

func _process(delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		position = get_parent().to_local(mouse_pos) - texture.get_size() / 2

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if not is_dragging:
			# Verificar si está en la posición correcta (lo haremos luego)
			var puzzle_node = get_parent()
			if puzzle_node.has_method("check_piece_position"):
				puzzle_node.check_piece_position(self)
