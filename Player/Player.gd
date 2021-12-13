extends KinematicBody2D

var step_one = preload("res://Audio/Sounds/footstep_concrete_0.ogg")
var step_two = preload("res://Audio/Sounds/footstep_concrete_1.ogg")
var step_three = preload("res://Audio/Sounds/footstep_concrete_2.ogg")

export var speed := 100

enum STATE {
	IDLE,
	WALK
}

var PLAYER_STATE = STATE.IDLE
var velocity := Vector2.ZERO
var facing = "right"
var directions = ["right", "right", "down", "left", "left", "left", "up", "right"]
var interaction_allowed = false
var reached_area = null
var fill_up_area = null
var lives = 3
var stun = false
var step_sounds = [step_one, step_two, step_three]

var game_over = false

onready var _animated_sprite := $AnimatedSprite
onready var hit_timer := $HitTimer
onready var hint_button := $HintButton
onready var ui_node := $Camera2D/UI
onready var inventar := $Camera2D/UI/Inventar
onready var collision_area := $PlayerArea
onready var collision_shape := $CollisionShape2D
onready var collision_shape_area := $PlayerArea/CollisionShape2D
onready var footsteps := $Footsteps

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("idle_right")
	update_lives()

func _physics_process(delta: float) -> void:
	if stun == true or game_over == true:
		return
		
	var move_direction := Vector2.ZERO
	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	move_direction = move_direction.normalized()
	
	if move_direction != Vector2.ZERO:
		facing = direction2str(move_direction)
		PLAYER_STATE = STATE.WALK
		_animated_sprite.play("walk_" + facing)
	elif PLAYER_STATE != STATE.IDLE:
		PLAYER_STATE = STATE.IDLE
		_animated_sprite.play("idle_" + facing)

	velocity = move_direction * speed
	velocity = move_and_slide(velocity, move_direction)

func _input(event):
	if interaction_allowed and event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_E:
				if reached_area:
					if inventar.items > 0:
						reached_area.add_capacity(100)
						inventar.remove_item()
						$Interaction.play()
				elif fill_up_area:
					if inventar.items < 2:
						inventar.add_item()
						$Interaction.play()

func direction2str(direction):
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	return directions[index]

func play_footsteps() -> void:
	if PLAYER_STATE == STATE.WALK and not footsteps.is_playing():
		footsteps.stop()
		var step_sound = step_sounds[randi() % step_sounds.size()]
		footsteps.stream = step_sound
		footsteps.play()

func update_lives() -> void:
	match lives:
		1:
			hit_timer.wait_time = 4
		2:
			hit_timer.wait_time = 3
		3:
			hit_timer.wait_time = 2
	
	ui_node.update_lives(lives)
	
	if lives == 0:
		game_over = true
		footsteps.stop()

func player_hit_by_car() -> void:
	$HitSound.play()
	footsteps.stop()
	hit_timer.start()
	lives -= 1
	update_lives()
	_animated_sprite.play("idle_up")
	_animated_sprite.flip_v = true
	collision_shape.set_deferred("disabled", true)
	collision_shape_area.set_deferred("disabled", true)
	z_index = 0
	stun = true

func player_stand_up() -> void:
	if lives > 0:
		_animated_sprite.play("idle_down")
		_animated_sprite.flip_v = false
		collision_shape.set_deferred("disabled", false)
		collision_shape_area.set_deferred("disabled", false)
		z_index = 1
		stun = false
	else:
		game_over()

func time_over() -> void:
	game_over = true
	$WinSound.play()
	footsteps.stop()
	ui_node.show_won_screen()
	
func game_over() -> void:
	game_over = true
	$DiePlayer.play()
	footsteps.stop()
	ui_node.show_won_screen()

func _on_Area2D_area_entered(area):
	print("hello: ", area)
	
	if area.has_method("add_capacity"):
		interaction_allowed = true
		reached_area = area
		hint_button.visible = true

	var area_parent = area.get_parent()
	if area_parent != null and area_parent is CarNPC:
		if area_parent.state != CarNPC.STATE.IDLE and area_parent.state != CarNPC.STATE.CHARGING:
			area_parent.honk.play()
			player_hit_by_car()
	elif area is PowerStation:
		interaction_allowed = true
		fill_up_area = area
		hint_button.visible = true

func _on_Area2D_area_exited(area):
	print("ciao: ", area)
	
	interaction_allowed = false
	reached_area = null
	fill_up_area = null
	hint_button.visible = false

func _on_HitTimer_timeout():
	player_stand_up()

func _on_FootstepTimer_timeout():
	play_footsteps()
