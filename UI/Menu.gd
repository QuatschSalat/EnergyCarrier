extends Node2D

var next_scene = preload("res://EnergyCarrierTileMap.tscn")

func _ready():
	update_status()
	update_music()

func update_status() -> void:
	$SoundStatus.text = "On" if Global.sound_on else "Off"
	$SoundStatus.modulate = Color("#7effb0") if Global.sound_on else Color("#ff7d7d")
	
	$MusicStatus.text = "On" if Global.music_on else "Off"
	$MusicStatus.modulate = Color("#7effb0") if Global.music_on else Color("#ff7d7d")

func update_music() -> void:
	if Global.music_on:
		$BackgroundMusic.play()
	else:
		$BackgroundMusic.stop()

func _on_Button_pressed():
	get_tree().change_scene_to(next_scene)

func _on_SoundSwitch_pressed():
	Global.sound_on = !Global.sound_on
	update_status()

func _on_MusicSwitch_pressed():
	Global.music_on = !Global.music_on
	update_status()
	update_music()
