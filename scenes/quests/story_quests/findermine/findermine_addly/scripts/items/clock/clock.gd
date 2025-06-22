extends Node2D

var player_near = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	$LabelHint.visible = false

func _on_body_entered(body):
	player_near = true
	$LabelHint.visible = true

func _on_body_exited(body):
	player_near = false
	$LabelHint.visible = false

func _process(delta):
	if player_near and Input.is_action_just_pressed("ui_accept"):
		var popup = get_tree().root.get_node("StealthTemplateLevel/CanvasLayer/RelojPopUp")
		popup.visible = true
