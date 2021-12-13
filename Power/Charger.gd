extends Node2D

const Colors = {
	On  = Color("#33d933"),
	Off = Color("#d93333")
}


export var active := false
export var charging_speed := 100

onready var indicator := $Indicator
onready var parkking_lot := $ParkingLot
onready var charge_timer := $Timer
onready var power_distributer := get_node("../PowerDistributor")

var charge_tick := 1
var current_car : CarNPC = null
var current_charging_speed = charging_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	update_indicator(active)
	
	charge_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	charge_timer.wait_time = charge_tick
	
func update_indicator(status: bool) -> void:
	active = status
	indicator.color = Colors.On if active else Colors.Off


func _on_ParkingLot_area_entered(area):
#	update_indicator(true)
	print("_on_ParkingLot_area_entered area: ", area)

	var carNPC = area.get_parent()
	if carNPC and carNPC is CarNPC:
		current_car = carNPC
		
		if (current_car.charging_speed < charging_speed):
			current_charging_speed = current_car.charging_speed
			
		charge_timer.start()


func _on_ParkingLot_area_exited(area):
#	update_indicator(false)
	charge_timer.stop()
	current_car = null
	current_charging_speed = charging_speed


func _on_Timer_timeout():
	if current_car != null and power_distributer != null:
		if current_car.current_capacity < current_car.capacity:
			var car_left_over = current_car.capacity - current_car.current_capacity
			if car_left_over < current_charging_speed:
				current_car.charge(power_distributer.consume_charging_power(car_left_over))
			else:
				current_car.charge(power_distributer.consume_charging_power(current_charging_speed))
