extends KinematicBody2D

class_name CarNPC

enum STATE {
	IDLE,
	TO_CHARGER,
	PARKING_IN,
	CHARGING,
	PARKING_OUT,
	PATH_OUT
}

export var speed := 120
export var capacity := 80
export var current_capacity := 50.0
export var charging_speed := 10
export var consumption := 0.1

onready var capacity_bar := $CapacityBar

onready var car_left := $CarLeft
onready var car_right := $CarRight
onready var car_up := $CarUp
onready var car_down := $CarDown
onready var collision_h := $CollisionH
onready var collision_v := $CollisionV
onready var park_timer := $ParkTimer
onready var honk_timer := $HonkTimer
onready var collision_traffic := $CollisionTrafficArea/CollisionTraffic
onready var traffic_collsion_v := $TrafficCollisionArea/v
onready var traffic_collsion_h := $TrafficCollisionArea/h
onready var drive_sound := $DriveSound
onready var honk := $Honk

onready var path_to_charger = get_node("../PathToCharger")
onready var parking_path = get_node("../ParkingPath")
onready var path_out = get_node("../PathOut")
onready var ui_node = get_node("../Player/Camera2D/UI")

var state = STATE.IDLE
var current_direction = "right"
var velocity := Vector2.ZERO
var current_path = null
var current_path_array = null
var directions = ["right", "right", "down", "left", "left", "left", "up", "right", "right"]
var park_pos = -1
var traffic = false

# Called when the node enters the scene tree for the first time.
func _ready():
	capacity_bar.init_values(capacity, current_capacity)
	honk_timer.wait_time = randi() % 5 + 1
	change_direction(direction2str(position))

func use_path_to_charger() -> void:
	if path_to_charger and path_to_charger is Node2D:
		var a_path = path_to_charger.get_child(randi() % path_to_charger.get_child_count())
		if a_path and a_path is Path2D:
			state = STATE.TO_CHARGER
			current_path = a_path
			current_path_array = a_path.curve.tessellate()
			spawn_car_at_path()

func use_parking_path_in() -> void:
	if park_timer != null and not park_timer.is_stopped():
		return

	if parking_path is Node2D:
		var parking_in = parking_path.get_node("In")
		park_pos = randi() % parking_in.get_child_count()
		var charger = get_node("../Charger" + str(park_pos))
		park_timer.stop()
		if charger and not charger.active:
			charger.update_indicator(true)
			parking_in = parking_in.get_child(park_pos)
			if parking_in and parking_in is Path2D:
				state = STATE.PARKING_IN
				current_path = parking_in
				current_path_array = parking_in.curve.tessellate()
				spawn_car_at_path()
		else:
			park_timer.start()

func use_parking_path_out() -> void:
	park_timer.stop()
	if parking_path is Node2D:
		var in_path_pos_in_parent = current_path.get_position_in_parent()
		var parking_out = parking_path.get_node("Out")
		parking_out = parking_out.get_child(in_path_pos_in_parent)
		if parking_out and parking_out is Path2D:
			state = STATE.PARKING_OUT
			current_path = parking_out
			current_path_array = parking_out.curve.tessellate()
			spawn_car_at_path()

func use_path_out() -> void:
	if path_out and path_out is Node2D:
		var a_path = path_out.get_child(randi() % path_out.get_child_count())
		if a_path and a_path is Path2D:
			var charger = get_node("../Charger" + str(park_pos))
			if charger and charger.active:
				charger.update_indicator(false)
				park_pos = -1
			state = STATE.PATH_OUT
			current_path = a_path
			current_path_array = a_path.curve.tessellate()
			spawn_car_at_path()

func spawn_car_at_path() -> void:
	position = get_next_point()

func get_next_point():
	if current_path_array != null and current_path_array.size() >= 2:
		drive_sound.play()
		var first_point = current_path_array[0]
		var second_point = current_path_array[1]
		var direction = first_point.direction_to(second_point)
		current_path_array.remove(0)
		return first_point
	elif state == STATE.TO_CHARGER:
		drive_sound.play()
		use_parking_path_in()
	elif state == STATE.PARKING_IN:
		drive_sound.stop()
		state = STATE.CHARGING
	elif state == STATE.CHARGING:
		drive_sound.play()
		use_parking_path_out()
	elif state == STATE.PARKING_OUT:
		drive_sound.play()
		use_path_out()
	elif state == STATE.PATH_OUT:
		drive_sound.stop()
		remove_car()

func remove_car() -> void:
	ui_node.add_points(20)
	get_parent().remove_child(self)
	queue_free()

func _physics_process(delta: float) -> void:
	if traffic == true:
		return
	
	if state == STATE.IDLE:
		return

	var move_direction := Vector2.ZERO
	if state != STATE.CHARGING and current_path_array != null:
		var target_position = current_path_array[0]
		if current_capacity > consumption and position.distance_to(target_position) > 1:
			var direction = position.direction_to(target_position)
			velocity = direction * speed
			velocity = move_and_slide(velocity, direction)
			current_capacity -= consumption
			update_capacity_bar()
			change_direction(direction2str(direction))
		elif position.distance_to(target_position) <= 1:
			get_next_point()

func direction2str(direction):
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	return directions[index] if index < directions.size() else current_direction

func change_direction(direction) -> void:
	if current_direction != direction:
		if state == STATE.TO_CHARGER and direction == "down":
			print("!!! HERE IS THE BUG !!!")
		current_direction = direction
		car_left.visible = false
		car_right.visible = false
		car_up.visible = false
		car_down.visible = false
		collision_h.disabled = true
		collision_v.disabled = true
		traffic_collsion_v.disabled = true
		traffic_collsion_h.disabled = true
		match direction:
			"left":
				car_left.visible = true
				collision_h.disabled = false
				collision_traffic.position = Vector2(-14.1, 8)
				traffic_collsion_h.disabled = false
				# collision_traffic_back.position = Vector2(14, 8)
			"right":
				car_right.visible = true
				collision_h.disabled = false
				collision_traffic.position = Vector2(14.1, 8)
				traffic_collsion_h.disabled = false
				# collision_traffic_back.position = Vector2(-14, 8)
			"up":
				car_up.visible = true
				collision_v.disabled = false
				collision_traffic.position = Vector2(0, -5.6)
				traffic_collsion_v.disabled = false
				# collision_traffic_back.position = Vector2(0, 18)
			"down":
				car_down.visible = true
				collision_v.disabled = false
				collision_traffic.position = Vector2(0, 18.6)
				traffic_collsion_v.disabled = false
				# collision_traffic_back.position = Vector2(0, -6)

func update_capacity_bar() -> void:
	if capacity_bar != null:
		capacity_bar.set_capacity(current_capacity)

func charge(added: int) -> void:
	current_capacity = round(current_capacity) + added
	update_capacity_bar()
	if current_capacity >= capacity:
		get_next_point()

func _on_ParkTimer_timeout():
#	use_parking_path_in()
	pass

func _on_HonkTimer_timeout():
	honk.play()
	
	honk_timer.wait_time = randi() % 5 + 1
	if traffic:
		honk_timer.start()

func _on_CollisionTrafficArea_area_entered(area):
	print("_on_CollisionTrafficArea_area_entered: ", self.name, " -> ", area.name)
	if area != null and area.name == "TrafficCollisionArea":
		traffic = true
		drive_sound.stop()
		if honk_timer.is_stopped():
			honk_timer.start()
			

func _on_CollisionTrafficArea_area_exited(area):
	print("_on_CollisionTrafficArea_area_exited: ", self.name, " -> ", area.name)
	if area != null and area.name == "TrafficCollisionArea":
		traffic = false
		drive_sound.play()
		if not honk_timer.is_stopped():
			honk_timer.stop()


