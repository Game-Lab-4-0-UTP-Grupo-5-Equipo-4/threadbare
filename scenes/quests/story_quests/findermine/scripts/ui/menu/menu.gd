extends Control

func _on_bt_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/0_findermine_intro/findermine_intro.tscn")

func _on_bt_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/quests/story_quests/findermine/ui/options/Options.tscn")

func _on_bt_out_pressed() -> void:
	get_tree().quit()
