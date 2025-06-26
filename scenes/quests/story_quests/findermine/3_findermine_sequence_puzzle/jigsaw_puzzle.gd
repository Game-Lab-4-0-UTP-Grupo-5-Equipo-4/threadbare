# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Node2D

@onready var pieces = [$Node2D/PuzzlePiece, $Node2D/PuzzlePiece2, $Node2D/PuzzlePiece3,
$Node2D/PuzzlePiece4, $Node2D/PuzzlePiece5, $Node2D/PuzzlePiece6,
$Node2D/PuzzlePiece7, $Node2D/PuzzlePiece8, $Node2D/PuzzlePiece9,
$Node2D/PuzzlePiece10, $Node2D/PuzzlePiece11, $Node2D/PuzzlePiece12,
$Node2D/PuzzlePiece13, $Node2D/PuzzlePiece14, $Node2D/PuzzlePiece15,
$Node2D/PuzzlePiece16 ]  # Añade todos los nodos
var correct_positions := {}
var pieces_in_place := 0

func _ready():
	for piece in pieces:
		correct_positions[piece.name] = piece.position
		# Opcional: Conecta señales si usas comunicación entre nodos
		# piece.connect("piece_placed", _on_piece_placed)

func check_piece_position(piece):
	var target_position = correct_positions.get(piece.name)
	if target_position and piece.position.distance_to(target_position) < 30:
		piece.position = target_position
		piece.is_dragging = false
		piece.set_process(false)
		check_puzzle_complete()

func check_puzzle_complete():
	pieces_in_place += 1
	if pieces_in_place == pieces.size():
		print("¡Rompecabezas completado!")
		get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/4_findermine_outro/findermine_outro.tscn")
