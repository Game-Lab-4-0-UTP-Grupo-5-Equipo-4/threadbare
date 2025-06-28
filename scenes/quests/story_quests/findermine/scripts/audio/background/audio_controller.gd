# AudioController.gd (configúralo como autoload)
extends Node

@onready var bg_music: AudioStreamPlayer = $bg_music

# Música predeterminada para Findermine
var findermine_default_music: AudioStream = preload("C:/Users/Loayza/OneDrive/Documents/GitHub/threadbare/scenes/quests/story_quests/findermine/sounds/background/fondo-findermine-recortado.mp3")
# Diccionario con músicas específicas para cada minijuego
var minigame_music = {
	
	# Si algún minijuego usa la misma música que otro, simplemente no lo agregues aquí
}

func play_minigame_music(minigame_key: String):
	var music_to_play = minigame_music.get(minigame_key, findermine_default_music)
	if music_to_play != bg_music.stream or not bg_music.playing:
		bg_music.stream = music_to_play
		bg_music.play()

func stop_music():
	bg_music.stop()
