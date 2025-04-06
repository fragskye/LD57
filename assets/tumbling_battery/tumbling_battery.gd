class_name TumblingBattery
extends Node3D

@onready var car_battery : PackedScene = preload("res://assets/BeachItems/CarBattery/battery_1.tscn")
@onready var camera_follow : CameraFollowPoint3D = $CameraFollowPoint

@export var camera : Camera3D

signal score_result(score: int)

func _ready() -> void:
	# TODO: Pull force from throwing minigame
	InputManager.input_state_changed.connect(_on_input_state_changed)

func _spawn_car_battery() -> void:
	var battery : RigidBody3D = car_battery.instantiate()
	add_child(battery)
	battery.position = Vector3.ZERO
	battery.apply_impulse(Vector3(0, 0, -250))
	camera_follow.rigidbody = battery
	
	# TODO: Wait until after its finished
	score_result.emit(100)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.BATTERY_CAMERA:
			show()
			camera.make_current()
			_spawn_car_battery()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		_:
			hide()
			process_mode = Node.PROCESS_MODE_DISABLED
