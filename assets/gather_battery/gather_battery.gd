class_name GatherBattery extends Node3D

signal gathered()

const BATTERY_1: PackedScene = preload("res://assets/BeachItems/CarBattery/battery_1.tscn")

@onready var car_battery_girl: Node3D = %CarBatteryGirl
@onready var cutscene_camera: Camera3D = %CutsceneCamera

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)

func reset() -> void:
	pass

func _process(delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.GATHER_BATTERY:
		return
	
	#if Input.is_action_just_pressed("pause"):
		#InputManager.push_input_state(InputManager.InputState.MENU)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.GATHER_BATTERY:
			show()
			cutscene_camera.make_current()
			Global.environment.terrain_3d.set_camera(cutscene_camera)
			process_mode = Node.PROCESS_MODE_PAUSABLE
			
			await get_tree().create_timer(3.0).timeout
			
			gathered.emit()
		_:
			hide()
			process_mode = Node.PROCESS_MODE_DISABLED
