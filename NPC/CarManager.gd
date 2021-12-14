extends Node

var spawn_time_multiplier = 2

onready var car_yellow = $CarYellow
onready var car_red = $CarRed
onready var car_green = $CarGreen
onready var ui_node = get_node("Player/Camera2D/UI")
onready var car_spawn_timer = $CarSpawnTimer
onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	print("ui_node: ", ui_node.game_time)
	car_spawn_timer.wait_time = 4
	car_spawn_timer.start()
	create_new_car()

#func _input(event):
#	if event is InputEventKey and event.pressed:
#		match event.scancode:
#			KEY_SPACE:
#				create_new_car()
#				pass

func create_new_car() -> void:
	if player.game_over == true:
		return

	var rand_int = randi() % 3
	var tmp_car = null
	if rand_int == 0:
		tmp_car = car_yellow.duplicate()
	elif rand_int == 1:
		tmp_car = car_red.duplicate()
	elif rand_int == 2:
		tmp_car = car_green.duplicate()

	if tmp_car != null:
#		print("new car: ", tmp_car)
		add_child(tmp_car)
		tmp_car.use_path_to_charger()


func _on_CarSpawnTimer_timeout():
	if player.game_over == true:
		car_spawn_timer.stop()
		return

#	print("create car in ", car_spawn_timer.wait_time, " seconds")
	create_new_car()
	if ui_node != null:
		if ui_node.game_time > 210:
			car_spawn_timer.wait_time = 3.7
		elif ui_node.game_time > 180:
			car_spawn_timer.wait_time = 3.4
		elif ui_node.game_time > 150:
			car_spawn_timer.wait_time = 3
		elif ui_node.game_time > 120:
			car_spawn_timer.wait_time = 2.7
		elif ui_node.game_time > 90:
			car_spawn_timer.wait_time = 2.4
		elif ui_node.game_time > 60:
			car_spawn_timer.wait_time = 2
		elif ui_node.game_time <= 60:
			car_spawn_timer.wait_time = 1.8
		car_spawn_timer.wait_time *= spawn_time_multiplier
		car_spawn_timer.start()
