extends Area2D

export var capacity: int = 5000
export var current_capacity := 1000

onready var capacity_bar := $CapacityBar

# Called when the node enters the scene tree for the first time.
func _ready():
	capacity_bar.init_values(capacity, current_capacity)


func add_capacity(size: int) -> int:
	var return_capa := 0
	current_capacity += size
	if current_capacity > capacity:
		return_capa = current_capacity - capacity
		current_capacity = capacity
	if capacity_bar != null:
		capacity_bar.set_capacity(current_capacity)
	
	return return_capa

func consume_charging_power(needed_capacity) -> int:
	
	if current_capacity > needed_capacity:
		current_capacity -= needed_capacity
		capacity_bar.set_capacity(current_capacity)
	else:
		needed_capacity = current_capacity
		current_capacity = 0
		capacity_bar.set_capacity(current_capacity)
	
	return needed_capacity
