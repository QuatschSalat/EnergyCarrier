extends Node2D

onready var level := $Level
onready var frame := $Frame

var current_capacity := 30
var max_value := 200

# Called when the node enters the scene tree for the first time.
func _ready():
	update_level_bar()

func update_level_bar() -> void:
	level.rect_size.x = (float(current_capacity) / max_value) * frame.rect_size.x

func init_values(max_capacity, capacity) -> void:
	max_value = max_capacity
	current_capacity = capacity
	update_level_bar()

func set_max_value(capacity: int) ->void:
	max_value = capacity
	update_level_bar()

func set_capacity(capacity: int) -> void:
	current_capacity = capacity
	update_level_bar()
