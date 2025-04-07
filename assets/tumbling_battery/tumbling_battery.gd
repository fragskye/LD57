class_name TumblingBattery
extends Node3D

@onready var car_battery : PackedScene = preload("res://assets/BeachItems/CarBattery/battery_1.tscn")
@onready var camera_follow : CameraFollowPoint3D = $CameraFollowPoint
@onready var vfx_follow: CameraFollowPoint3D = $VFXFollowPoint
@onready var button_mash : ButtonMashing = $ButtonMashing
@onready var underwater_sfx: AudioStreamPlayer2D = %UnderwaterSFX
@onready var splash_sfx: AudioStreamPlayer2D = %SplashSFX

@export var camera : Camera3D
@export var still_time_timeout: float = 1.0

@export var power: float = 0.0
@export var keymash_strength : float = 2.0

@export var max_impulse: Vector3 = Vector3.ZERO

var cpu: CPUData = null

var active_battery : CarBattery = null
var still_time: float = 0.0

var _input_state_changed_this_frame: bool = false

signal score_result(score: int)

func _ready() -> void:
	# TODO: Pull force from throwing minigame
	InputManager.input_state_changed.connect(_on_input_state_changed)
	EventBus.player_turn_started.connect(_on_player_turn_started)
	button_mash.on_successful_keymash.connect(_on_successful_keymash)

func reset() -> void:
	active_battery = null
	still_time = 0.0
	underwater_sfx.play()
	splash_sfx.play()
	if cpu != null:
		Engine.time_scale = 3.0

func _spawn_car_battery() -> void:
	active_battery = car_battery.instantiate()
	add_child(active_battery)
	camera_follow.rigidbody = active_battery
	vfx_follow.rigidbody = active_battery
	active_battery.position = Vector3.ZERO
	# Jolt Physics complains if you apply an impulse before the node has been fully added to the scene tree
	await get_tree().process_frame
	active_battery.get_global_transform_interpolated()
	active_battery.reset_physics_interpolation()
	active_battery.linear_velocity = remap(power, 0.0, 1.0, 0.2, 1.0) * (max_impulse + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)))
	active_battery.angular_velocity = Vector3(randf_range(-45.0, 45.0), randf_range(-45.0, 45.0), randf_range(-45.0, 45.0))
	
	while still_time < still_time_timeout:
		await get_tree().physics_frame
	
	Engine.time_scale = 1.0 
	score_result.emit(active_battery.current_score)

func _process(delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTERY_CAMERA:
		return
	
	if !_input_state_changed_this_frame && Input.is_action_just_pressed("pause"):
		InputManager.push_input_state(InputManager.InputState.MENU)
	
	_input_state_changed_this_frame = false

func _physics_process(delta: float) -> void:
	if active_battery != null:
		if active_battery.linear_velocity.length() < 0.5:
			still_time += delta
		else:
			still_time = 0
		# HACK: quick and dirty bounds check. should be using a world boundary and collision callback
		if active_battery.global_position.y < -600.0:
			Engine.time_scale = 1.0 
			score_result.emit(active_battery.current_score + 1000) # home run bonus!

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.BATTERY_CAMERA:
			show()
			camera.make_current()
			if cpu == null:
				button_mash.enable()
			Global.environment.terrain_3d.set_camera(camera)
			_spawn_car_battery()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		_:
			hide()
			button_mash.disable()
			underwater_sfx.stop()
			process_mode = Node.PROCESS_MODE_DISABLED

func _on_player_turn_started(player_data: PlayerData) -> void:
	cpu = player_data.cpu
	
func _on_successful_keymash() -> void:
	if active_battery == null:
		return
	
	var direction : Vector3 = Vector3(0.0, 0.5, 0.0)
	
	if cpu == null:
		var camera_direction : Vector3 = -camera.global_basis.z
		camera_direction.y = 0.0
		direction += camera_direction.normalized()
	else:
		direction += Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, randf_range(0.0, 360.0))

	active_battery.apply_impulse(keymash_strength * direction)
