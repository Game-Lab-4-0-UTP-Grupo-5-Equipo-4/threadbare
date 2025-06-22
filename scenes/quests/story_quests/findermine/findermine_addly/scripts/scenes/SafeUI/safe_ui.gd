extends Control

@export var correct_code: String = "17012510233"
var current_input: String = ""

func _on_number_pressed(number: String) -> void:
	print("Se presionó:", number)
	if current_input.length() < 11:
		current_input += number
		$Panel/DisplayLabel.text = current_input

func _ready() -> void:
	_connect_buttons()

func _connect_buttons() -> void:
	for i in range(10):
		var button = $Panel.get_node(str(i))  # Los botones deben llamarse "0", "1", etc.
		button.pressed.connect(_on_number_pressed.bind(str(i)))

	$Panel/ConfirmButton.pressed.connect(_on_confirm_button_pressed)
	$Panel/CancelButton.pressed.connect(_on_cancel_button_pressed)


func _on_confirm_button_pressed() -> void:
	if current_input == correct_code:
		$Panel/ConfirmLabel.text = "✅ Correcto"
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/2_findermine_combat/findermine_combat.tscn")
	else:
		$Panel/ConfirmLabel.text = "❌ Incorrecto"
		current_input = ""
		await get_tree().create_timer(1.2).timeout
		$Panel/DisplayLabel.text = ""

func _on_cancel_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/1_findermine_stealth/findermine_stealth.tscn")
