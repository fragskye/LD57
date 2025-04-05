class_name ThrowMinigame extends Node3D

signal power_result(power: float)

@onready var throw_camera: Camera3D = %ThrowCamera
@onready var throw_minigame_layer: CanvasLayer = %ThrowMinigameLayer
@onready var skill_check: SkillCheck = %SkillCheck
@onready var power_bar: ProgressBar = %PowerBar

@export var hit_power_reward: float = 0.1
@export var miss_power_reward: float = 0.1

@export var skill_check_count: int = 30
@export var time_to_max: float = 30.0

@export var start_speed: float = 60.0
@export var end_speed: float = 180.0
@export var start_target_angle_offset_range: Vector2 = Vector2(120.0, 180.0)
@export var end_target_angle_offset_range: Vector2 = Vector2(45.0, 105.0)
@export var start_target_arc_length: float = 45.0
@export var end_target_arc_length: float = 30.0

var npc: bool = false # TODO: Resource controlling AI parameters instead of bool

var power: float = 0.0

var skill_checks_complete: int = 0
var time_passed: float = 0.0

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)

func reset() -> void:
	skill_checks_complete = 0
	time_passed = 0.0

func _process(delta: float) -> void:
	time_passed += delta
	var time_mix: float = minf(1.0, time_passed / time_to_max)
	skill_check.bar_spin_speed = lerpf(start_speed, end_speed, time_mix)
	var target_angle_offset_range: Vector2 = start_target_angle_offset_range.lerp(end_target_angle_offset_range, time_mix)
	skill_check.next_target_angle_offset = randf_range(target_angle_offset_range.x, target_angle_offset_range.y)
	skill_check.next_target_arc_length = lerpf(start_target_arc_length, end_target_arc_length, time_mix)
	
	if !npc:
		if Input.is_action_just_pressed("skill_check"):
			skill_check.press_bar()
	
	power_bar.value = power * 100.0

func _on_skill_check_target_hit() -> void:
	power = clampf(power + hit_power_reward, 0.0, 1.0)

func _on_skill_check_target_missed() -> void:
	power = clampf(power + miss_power_reward, 0.0, 1.0)

func _on_skill_check_target_complete() -> void:
	skill_checks_complete += 1
	if skill_checks_complete >= skill_check_count:
		power_result.emit(power)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.THROW_MINIGAME:
			show()
			throw_camera.make_current()
			throw_minigame_layer.show()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		_:
			hide()
			throw_minigame_layer.hide()
			process_mode = Node.PROCESS_MODE_DISABLED
