extends Sprite2D
class_name PuzzlePiece8

# Variables de control
var is_dragging = false
var initial_position: Vector2
var final_position: Vector2
var is_correct: bool = false
var mouse_offset: Vector2
var mouse_inside: bool = false

# Señales
signal piece_mouse_entered(piece: PuzzlePiece)
signal piece_mouse_exited(piece: PuzzlePiece)
signal piece_clicked(piece: PuzzlePiece)
signal piece_released(piece: PuzzlePiece)

func _ready():
	initial_position = position
	print("PuzzlePiece ", name, " inicializada en posición: ", position)

func _process(delta):
	if is_dragging:
		# Usar el offset para un arrastre más suave
		position = get_global_mouse_position() - mouse_offset
	
	# Detectar mouse sobre la pieza manualmente
	_check_mouse_over()

func _check_mouse_over():
	if is_correct:
		return
		
	var mouse_pos = get_global_mouse_position()
	var sprite_rect = get_rect()
	sprite_rect.position += global_position
	
	var mouse_over = sprite_rect.has_point(mouse_pos)
	
	if mouse_over and not mouse_inside:
		mouse_inside = true
		emit_signal("piece_mouse_entered", self)
	elif not mouse_over and mouse_inside:
		mouse_inside = false
		emit_signal("piece_mouse_exited", self)

func _input(event):
	if is_correct:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var sprite_rect = get_rect()
		sprite_rect.position += global_position
		
		if sprite_rect.has_point(mouse_pos):
			if event.pressed:
				# Calcular offset para arrastre suave
				mouse_offset = get_global_mouse_position() - global_position
				emit_signal("piece_clicked", self)
				print("Pieza ", name, " clickeada")
			else:
				emit_signal("piece_released", self)
				print("Pieza ", name, " soltada")

func start_dragging():
	if not is_correct:
		is_dragging = true
		print("Iniciando arrastre de ", name)

func stop_dragging():
	is_dragging = false
	print("Deteniendo arrastre de ", name)

# Función para resetear la pieza (útil para debugging)
func reset_piece():
	is_correct = false
	is_dragging = false
	position = initial_position
