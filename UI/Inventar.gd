extends Node2D

onready var battery_one := $BatterieOne
onready var battery_two := $BatterieTwo

var items = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	update_inventory_ui()
	pass # Replace with function body.

func update_inventory_ui() -> void:
	if items == 0:
		battery_one.visible = false
		battery_two.visible = false
	elif items == 1:
		battery_one.visible = true
		battery_two.visible = false
	elif items == 2:
		battery_one.visible = true
		battery_two.visible = true

func add_item() -> void:
	if items < 2:
		items += 1
		update_inventory_ui()

func remove_item() -> void:
	if items > 0:
		items -= 1
		update_inventory_ui()
