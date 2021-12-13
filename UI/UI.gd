extends Node2D

var menu_scene = load("res://Menu.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_node("../..")

onready var points_label := $Points
onready var time_label := $Time
onready var game_timer := $GameTimer
onready var heart_one := $Hearts/One
onready var heart_two := $Hearts/Two
onready var heart_three := $Hearts/Three

onready var won_node := $WonLose
onready var won_points := $WonLose/Points

var sec_elapsed = 0
var game_time = 240
var gained_points = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	points_label.text = "0"
	game_timer.start()
	
	print("player: ", player)

func update_lives(lives) -> void:
	print("UI lives: ", lives)
	
	if lives == 0:
		heart_one.visible = false
	else:
		match lives:
			3:
				heart_one.visible = true
				heart_two.visible = true
				heart_three.visible = true
			2:
				heart_three.visible = false
			1:
				heart_two.visible = false

func add_points(points) -> void:
	if points > 5:
		$PointsAudio.play()
	gained_points += points
	points_label.text = str(gained_points)

func show_won_screen() -> void:
	won_node.visible = true
	won_points.text = "You have " + str(gained_points) + " points"

func _on_GameTimer_timeout():
	add_points(1)
	game_time -= 1
	var seconds = game_time % 60
	var minutes = game_time % 3600 / 60

	time_label.text = str("%02d : %02d" % [minutes, seconds])
	
	if game_time == 0:
		player.time_over()

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Menu_pressed():
	get_tree().change_scene_to(menu_scene)
	pass
