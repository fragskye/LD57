class_name ThrowMinigame extends Node3D

signal power_result(power: float)

const BATTERY_1: PackedScene = preload("res://assets/BeachItems/CarBattery/battery_1.tscn")

@onready var throw_camera: Camera3D = %ThrowCamera
@onready var car_battery_girl: Node3D = %CarBatteryGirl
@onready var cutscene_camera: Camera3D = %CutsceneCamera
@onready var throw_minigame_layer: CanvasLayer = %ThrowMinigameLayer
@onready var skill_check: SkillCheck = %SkillCheck
@onready var power_bar: ProgressBar = %PowerBar

@export var hit_power_reward: float = 0.1
@export var miss_power_reward: float = 0.1

@export var skill_check_count: int = 30
@export var time_to_max: float = 30.0

@export var difficulties: Array[ThrowMinigameDifficulty] = []
@export var cpu_difficulty_index: int = 0

var difficulty: ThrowMinigameDifficulty:
	get():
		if cpu != null:
			return difficulties[cpu_difficulty_index]
		return difficulties[Global.throw_minigame_difficulty]

var cpu: CPUData = null

var power: float = 0.0
var skill_checks_complete: int = 0
var time_passed: float = 0.0

var cutscene: bool = false

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)
	EventBus.player_turn_started.connect(_on_player_turn_started)

func reset() -> void:
	power = 0.0
	skill_checks_complete = 0
	time_passed = 0.0
	skill_check.reset()
	cutscene = false
	if cpu != null:
		Engine.time_scale = 3.0

func _process(delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.THROW_MINIGAME:
		return
	
	if Input.is_action_just_pressed("pause"):
		InputManager.push_input_state(InputManager.InputState.MENU)
	
	if cutscene:
		return
	
	time_passed += delta
	var time_mix: float = minf(1.0, time_passed / time_to_max)
	skill_check.bar_spin_speed = lerpf(difficulty.start_speed, difficulty.end_speed, time_mix)
	var target_angle_offset_range: Vector2 = difficulty.start_target_angle_offset_range.lerp(difficulty.end_target_angle_offset_range, time_mix)
	skill_check.next_target_angle_offset = randf_range(target_angle_offset_range.x, target_angle_offset_range.y)
	skill_check.next_target_arc_length = lerpf(difficulty.start_target_arc_length, difficulty.end_target_arc_length, time_mix)
	skill_check.can_miss_early = difficulty.can_miss_early
	car_battery_girl.rotation_degrees.y = -skill_check.bar_angle + 90.0
	
	if cpu == null:
		if Input.is_action_just_pressed("skill_check"):
			skill_check.press_bar()
	
	power_bar.value = power * 100.0

func _on_skill_check_bar_entered_target() -> void:
	if cutscene:
		return
	
	if cpu != null:
		var time_mix: float = minf(1.0, time_passed / time_to_max)
		if cpu.throw_minigame_get_success(time_mix):
			var delay: float = cpu.throw_minigame_get_delay(time_mix)
			await get_tree().create_timer(delay).timeout
			skill_check.press_bar()

func _on_skill_check_target_hit() -> void:
	var scalar: float = 4.0 if Global.throw_minigame_fast else 1.0
	power = clampf(power + scalar * hit_power_reward, 0.0, 1.0)

func _on_skill_check_target_missed() -> void:
	var scalar: float = 4.0 if Global.throw_minigame_fast else 1.0
	power = clampf(power + scalar * miss_power_reward, 0.0, 1.0)

func _on_skill_check_target_complete() -> void:
	if cutscene:
		return
	
	skill_checks_complete += 1
	var scalar: float = 0.25 if Global.throw_minigame_fast else 1.0
	if skill_checks_complete >= scalar * skill_check_count:
		Engine.time_scale = 1.0
		
		car_battery_girl.rotation_degrees.y = 180.0
		cutscene = true
		
		cutscene_camera.make_current()
		Global.environment.terrain_3d.set_camera(cutscene_camera)
		throw_minigame_layer.hide()
		var battery: CarBattery = BATTERY_1.instantiate()
		add_child(battery)
		battery.global_position = car_battery_girl.global_position + Vector3(0.0, 1.0, 0.0)
		battery.linear_velocity = remap(power, 0.0, 1.0, 0.7, 1.7) * Vector3(0.0, 10.0, -25.0)
		
		await get_tree().create_timer(3.0).timeout
		
		battery.queue_free()
		power_result.emit(power)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.THROW_MINIGAME:
			show()
			throw_camera.make_current()
			Global.environment.terrain_3d.set_camera(throw_camera)
			throw_minigame_layer.show()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		_:
			hide()
			throw_minigame_layer.hide()
			process_mode = Node.PROCESS_MODE_DISABLED

func _on_player_turn_started(player_data: PlayerData) -> void:
	cpu = player_data.cpu
