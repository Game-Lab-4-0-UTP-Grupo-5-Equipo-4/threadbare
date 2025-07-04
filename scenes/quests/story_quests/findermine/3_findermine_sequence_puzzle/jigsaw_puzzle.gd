# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Node

# Configuración del puzzle
@export var completion_glow_color: Color = Color(1, 1, 0.5, 0.8)
@export var completion_glow_duration: float = 2.0
@export var snap_distance: float = 30.0

# Configuración del área de colocación aleatoria - AQUÍ PUEDES AJUSTAR
@export var shuffle_area_center: Vector2 = Vector2(980, 960)  # Centro del área (ajustado)
@export var shuffle_area_size: Vector2 = Vector2(300, 200)   # Tamaño más pequeño
@export var min_distance_from_correct: float = 60.0          # Distancia mínima reducida

# Referencias a las piezas - DENTRO del Node2D que está en JigsawPuzzle
@onready var pieces = [
	$Node2D/PuzzlePiece, $Node2D/PuzzlePiece2, $Node2D/PuzzlePiece3, $Node2D/PuzzlePiece4,
	$Node2D/PuzzlePiece5, $Node2D/PuzzlePiece6, $Node2D/PuzzlePiece7, $Node2D/PuzzlePiece8,
	$Node2D/PuzzlePiece9, $Node2D/PuzzlePiece10, $Node2D/PuzzlePiece11, $Node2D/PuzzlePiece12,
	$Node2D/PuzzlePiece13, $Node2D/PuzzlePiece14, $Node2D/PuzzlePiece15, $Node2D/PuzzlePiece16
]

# Variables de control
var correct_positions := {}
var pieces_in_place := 0
var pieces_under_cursor := {}
var active_piece = null

# Nodos de referencia
@onready var complete_mirror: Sprite2D = $CompleteMirror
@onready var glow_effect: ColorRect = $CanvasLayer/GlowEffect
@onready var animated_d2: AnimatedSprite2D = $Animated_D2

func _ready():
	await get_tree().process_frame
	setup_pieces()
	debug_shuffle_area()  # Agregar esta línea para ver info
	shuffle_pieces()
	setup_glow_effect()
	setup_animated_sprite()
	
func setup_animated_sprite():
	if animated_d2:
		# Ocultar el AnimatedSprite2D al inicio
		animated_d2.visible = false
		print("AnimatedSprite2D configurado (oculto)")
	else:
		print("Advertencia: Animated_D2 no encontrado")

func setup_pieces():
	print("Configurando ", pieces.size(), " piezas...")
	for piece in pieces:
		if piece == null:
			print("Advertencia: Una pieza no se encontró")
			continue
			
		# Guardar posiciones correctas (las posiciones actuales son las correctas)
		correct_positions[piece.name] = piece.position
		piece.final_position = piece.position
		piece.is_correct = false
		
		# Conectar señales de la pieza
		if piece.has_signal("piece_mouse_entered"):
			piece.piece_mouse_entered.connect(_on_piece_mouse_entered)
		if piece.has_signal("piece_mouse_exited"):
			piece.piece_mouse_exited.connect(_on_piece_mouse_exited)
		if piece.has_signal("piece_clicked"):
			piece.piece_clicked.connect(_on_piece_clicked)
		if piece.has_signal("piece_released"):
			piece.piece_released.connect(_on_piece_released)
		
		print("Pieza configurada: ", piece.name, " en posición correcta: ", piece.position)

func setup_glow_effect():
	if glow_effect:
		glow_effect.color = Color.TRANSPARENT
		glow_effect.visible = false
		# Asegurar que cubra toda la pantalla
		glow_effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		print("Efecto de brillo configurado")
	else:
		print("Advertencia: GlowEffect no encontrado")

# ESTA ES LA FUNCIÓN QUE "REVOLTEA" LAS PIEZAS
func shuffle_pieces():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	print("Mezclando piezas en área limitada...")
	print("Área de mezcla - Centro: ", shuffle_area_center, " Tamaño: ", shuffle_area_size)
	
	# Calcular los límites del área - AQUÍ SE DEFINE DÓNDE APARECEN
	var area_min = shuffle_area_center - shuffle_area_size / 2
	var area_max = shuffle_area_center + shuffle_area_size / 2
	
	print("Límites del área - Min: ", area_min, " Max: ", area_max)
	
	for piece in pieces:
		if piece == null:
			continue
		
		var attempts = 0
		var new_position: Vector2
		
		# Intentar encontrar una posición válida (máximo 50 intentos en lugar de 20)
		while attempts < 50:
			# Generar posición aleatoria dentro del área
			var random_x = rng.randf_range(area_min.x, area_max.x)
			var random_y = rng.randf_range(area_min.y, area_max.y)
			new_position = Vector2(random_x, random_y)
			
			# Verificar que esté suficientemente lejos de la posición correcta
			var distance_to_correct = new_position.distance_to(piece.final_position)
			
			if distance_to_correct >= min_distance_from_correct:
				break
			
			attempts += 1
		
		# Si no encontramos una posición válida, usar una posición segura
		if attempts >= 50:
			print("Advertencia: No se pudo encontrar posición válida para ", piece.name)
			# Posición de respaldo dentro del área pero más cerca del centro
			var safe_offset = Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30))
			new_position = shuffle_area_center + safe_offset
		
		piece.position = new_position
		piece.z_index = rng.randi_range(1, 10)
		
		print("Pieza ", piece.name, " colocada en: ", piece.position, " (distancia de correcta: ", piece.position.distance_to(piece.final_position), ")")

func check_piece_position(piece):
	if piece == null or piece.is_correct:
		return
		
	var target_position = correct_positions.get(piece.name)
	if target_position == null:
		print("Advertencia: No se encontró posición correcta para ", piece.name)
		return
	
	var distance = piece.position.distance_to(target_position)
	print("Verificando pieza ", piece.name, " - Distancia: ", distance, " (límite: ", snap_distance, ")")
	
	if distance < snap_distance:
		# Encajar la pieza
		piece.position = target_position
		piece.is_dragging = false
		
		# Marcar como correcta
		piece.is_correct = true
		pieces_in_place += 1
		piece.z_index = 0  # Piezas correctas van al fondo
		
		print("¡Pieza ", piece.name, " colocada correctamente! (", pieces_in_place, "/", pieces.size(), ")")
		
		# Efecto visual opcional para la pieza colocada
		_piece_snap_effect(piece)
		
		check_puzzle_complete()

func _piece_snap_effect(piece):
	# Pequeño efecto visual cuando una pieza se coloca correctamente
	var original_scale = piece.scale
	var tween = create_tween()
	tween.tween_property(piece, "scale", original_scale * 1.1, 0.1)
	tween.tween_property(piece, "scale", original_scale, 0.1)

func check_puzzle_complete():
	if pieces_in_place >= pieces.size():
		print("¡Rompecabezas completado!")
		trigger_completion_effect()

func trigger_completion_effect():
	# PASO 1: Ocultar CompleteMirror inmediatamente cuando empieza el brillo
	if complete_mirror:
		print("Ocultando CompleteMirror")
		complete_mirror.visible = false
	
	# PASO 2: Mostrar efecto de brillo
	if glow_effect:
		glow_effect.visible = true
		var tween = create_tween()
		tween.tween_property(glow_effect, "color", completion_glow_color, completion_glow_duration/2)
		tween.tween_property(glow_effect, "color", Color.TRANSPARENT, completion_glow_duration/2)
		tween.tween_callback(func(): 
			glow_effect.visible = false
			show_animated_sprite()  # PASO 3: Mostrar AnimatedSprite2D después del brillo
		)

func show_animated_sprite():
	if animated_d2:
		print("Mostrando AnimatedSprite2D después del brillo")
		animated_d2.visible = true
		
		# Reproducir la animación
		if animated_d2.sprite_frames and animated_d2.sprite_frames.has_animation("default"):
			animated_d2.play("default")
		else:
			animated_d2.play()  # Reproducir la animación por defecto
		
		# Efecto de aparición suave
		animated_d2.modulate = Color.TRANSPARENT
		var appear_tween = create_tween()
		appear_tween.tween_property(animated_d2, "modulate", Color.WHITE, 0.5)
		
		# PASO 4: Esperar a que termine la animación + 5 segundos antes de cambiar escena
		wait_for_animation_and_change_scene()
	else:
		print("Error: No se pudo mostrar Animated_D2 - nodo no encontrado")
		# Si no hay animación, cambiar escena después de 5 segundos
		await get_tree().create_timer(5.0).timeout
		change_to_outro()

func wait_for_animation_and_change_scene():
	# Conectar a la señal de finalización de animación si existe
	if animated_d2.has_signal("animation_finished"):
		# Esperar a que termine la animación
		await animated_d2.animation_finished
		print("Animación terminada, esperando 5 segundos adicionales...")
	else:
		# Si no hay señal, calcular duración aproximada de la animación
		var animation_duration = 0.0
		if animated_d2.sprite_frames and animated_d2.sprite_frames.has_animation("default"):
			var frame_count = animated_d2.sprite_frames.get_frame_count("default")
			var fps = animated_d2.sprite_frames.get_animation_speed("default")
			animation_duration = frame_count / fps
			print("Duración calculada de animación: ", animation_duration, " segundos")
		else:
			# Duración por defecto si no se puede calcular
			animation_duration = 3.0
			print("Usando duración por defecto de animación: ", animation_duration, " segundos")
		
		await get_tree().create_timer(animation_duration).timeout
		print("Tiempo de animación completado, esperando 5 segundos adicionales...")
	
	# Esperar 5 segundos adicionales después de que termine la animación
	await get_tree().create_timer(5.0).timeout
	change_to_outro()

func change_to_outro():
	print("Cambiando a la escena outro...")
	get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/4_findermine_outro/findermine_outro.tscn")

# Funciones de señales de las piezas
func _on_piece_mouse_entered(piece):
	if piece and not piece.is_correct:
		pieces_under_cursor[piece.get_instance_id()] = piece

func _on_piece_mouse_exited(piece):
	if piece:
		pieces_under_cursor.erase(piece.get_instance_id())

func _on_piece_clicked(piece):
	if piece and not piece.is_correct:
		active_piece = piece
		_put_on_top(piece)
		piece.start_dragging()

func _on_piece_released(piece):
	if piece and piece == active_piece:
		piece.stop_dragging()
		check_piece_position(piece)
		active_piece = null

func _get_top_piece():
	var top_z = -99
	var top_p = null
	for p in pieces_under_cursor.values():
		if p.z_index > top_z:
			top_z = p.z_index
			top_p = p
	return top_p

func _put_on_top(piece):
	if piece == null:
		return
		
	var max_z = 0
	for other_piece in pieces:
		if other_piece != null and other_piece != piece and other_piece.z_index > max_z:
			max_z = other_piece.z_index
	piece.z_index = max_z + 1

# Función para debug - imprime información del área
func debug_shuffle_area():
	print("=== DEBUG ÁREA DE MEZCLA ===")
	print("Centro: ", shuffle_area_center)
	print("Tamaño: ", shuffle_area_size)
	print("Área mínima: ", shuffle_area_center - shuffle_area_size / 2)
	print("Área máxima: ", shuffle_area_center + shuffle_area_size / 2)
	print("Distancia mínima de posición correcta: ", min_distance_from_correct)
	print("===============================")
