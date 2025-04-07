class_name GatherBattery extends Node3D

signal gathered()

const BATTERY_1: PackedScene = preload("res://assets/BeachItems/CarBattery/battery_1.tscn")

@onready var car_battery_girl: CarBatteryGirl = %CarBatteryGirl
@onready var cutscene_camera: Camera3D = %CutsceneCamera
@onready var held_battery: CarBattery = %HeldBattery
@onready var rummage_sfx: AudioStreamPlayer2D = %RummageSFX

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)

func reset() -> void:
	rummage_sfx.play()
	held_battery.hide()
	car_battery_girl.rummage_pose()
	car_battery_girl.rotation_degrees = Vector3(0.0, -126.7, 0.0)

func _process(delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.GATHER_BATTERY:
		return
	
	if Input.is_action_just_pressed("pause"):
		InputManager.push_input_state(InputManager.InputState.MENU)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.GATHER_BATTERY:
			show()
			cutscene_camera.make_current()
			Global.environment.terrain_3d.set_camera(cutscene_camera)
			process_mode = Node.PROCESS_MODE_PAUSABLE
			
			await get_tree().create_timer(2.0, false).timeout
			held_battery.show()
			car_battery_girl.lift_pose()
			car_battery_girl.rotation_degrees = Vector3(0.0, -42.9, 0.0)
			await get_tree().create_timer(1.0, false).timeout
			
			gathered.emit()
		_:
			hide()
			process_mode = Node.PROCESS_MODE_DISABLED
