class_name Player extends CharacterBody3D

@onready var player_camera: Camera3D = %Camera
@onready var camera_rig: PlayerCameraRig = %PlayerCameraRig

@export var move_speed: float = 5.0

@export var move_smoothing_accel: float = 0.9
@export var move_smoothing_decel: float = 0.9

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)

func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.THIRD_PERSON:
		return
	
	if Input.is_action_just_pressed("pause"):
		InputManager.push_input_state(InputManager.InputState.MENU)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction: Vector3 = _get_input_direction()
	if direction:
		velocity.x = Util.temporal_lerp(velocity.x, direction.x * move_speed, 1.0 - move_smoothing_accel, delta)
		velocity.z = Util.temporal_lerp(velocity.z, direction.z * move_speed, 1.0 - move_smoothing_accel, delta)
	else:
		velocity.x = Util.temporal_lerp(velocity.x, 0.0, 1.0 - move_smoothing_decel, delta)
		velocity.z = Util.temporal_lerp(velocity.z, 0.0, 1.0 - move_smoothing_decel, delta)
	
	move_and_slide()

func _get_input_direction() -> Vector3:
	if InputManager.get_input_state() != InputManager.InputState.THIRD_PERSON:
		return Vector3.ZERO
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (camera_rig.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0.0
	direction = direction.normalized()
	return direction

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	match new_state:
		InputManager.InputState.THIRD_PERSON:
			show()
			player_camera.make_current()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		InputManager.InputState.THROW_MINIGAME:
			hide()
			process_mode = Node.PROCESS_MODE_DISABLED
