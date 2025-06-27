# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Area2D

var is_dragging = false
var offset = Vector2.ZERO

func _ready():
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			offset = global_position - get_global_mouse_position()
		else:
			is_dragging = false

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() + offset
