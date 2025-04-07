class_name CarBattery
extends RigidBody3D

@onready var crash_sfx: AudioStreamPlayer3D = %CrashSFX

## Minimum depth under the water for the depth score to begin accumulating
@export var depth_score_minimum : float = -50

## How many units of depth translates to one unit of score
@export var depth_score_step : float = 2.5 

## How much velocity is required for collision score to begin accumulating
@export var collision_score_minimum : float = 2.5

## How many units of velocity translates to one unit of score
@export var collision_score_step : float = 2.5

@export var crash_audio: Array[AudioStream] = []

var current_score : int = 0

var _depth_score : int = 0
var _collision_score : int = 0

var _collision_normal: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_collision)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		_collision_normal = state.get_contact_local_normal(0)

func _process(delta: float) -> void:
	if (global_position.y < depth_score_minimum):
		var depth : float = abs(global_position.y - depth_score_minimum)
		_depth_score = ceili(depth / depth_score_step)
	else:
		_depth_score = 0
	
	current_score = _depth_score + _collision_score

func _on_collision(body: Node) -> void:
	var impact_velocity: float = lerpf(linear_velocity.length(), absf(linear_velocity.dot(_collision_normal)), 0.5)
	
	if (impact_velocity < collision_score_minimum):
		return
	
	var crash_intensity: float = clampf(remap(impact_velocity, 2.0, 30.0, 0.0, 1.0), 0.0, 1.0)
	crash_intensity = pow(crash_intensity, 0.9)
	print(impact_velocity)
	print(crash_intensity)
	crash_sfx.stream = crash_audio.pick_random()
	crash_sfx.pitch_scale = randf_range(0.9, 1.1)
	crash_sfx.volume_linear = remap(crash_intensity, 0.0, 1.0, 0.1, 0.9)
	crash_sfx.play()
	
	var this_collision_score : float = ceili((impact_velocity - collision_score_minimum) / collision_score_step)
	
	_collision_score += this_collision_score
