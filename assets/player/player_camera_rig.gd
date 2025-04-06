class_name PlayerCameraRig extends Node3D

@onready var camera: Camera3D = %Camera

@export var look_sensitivity: float = 1.0
@export var camera_min_distance: float = 0.5
@export var camera_max_distance: float = 3.0
@export var camera_soft_margin: float = 0.5
@export var camera_hard_margin: float = 0.1
@export var camera_smoothing: float = 0.9
@export_flags_3d_physics var camera_collision_mask: int = 0
@export var camera_collision_shape: Shape3D = null

var pitch: float = 0.0
var yaw: float = 0.0
var roll: float = 0.0
var camera_distance: float = 0.0

func _ready() -> void:
	pitch = rotation_degrees.x
	yaw = rotation_degrees.y
	roll = rotation_degrees.z
	camera_distance = camera_max_distance

func _process(delta: float) -> void:
	if (!is_instance_valid(camera)):
		return
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = camera_collision_shape
	query.transform = Transform3D(Basis.IDENTITY, global_position)
	var motion_max_distance: float = camera_max_distance + camera_soft_margin + camera_hard_margin
	query.motion = global_basis * Vector3(0.0, 0.0, motion_max_distance)
	query.collision_mask = camera_collision_mask
	var result: PackedFloat32Array = space_state.cast_motion(query)
	
	var ray_distance: float = result[0] * motion_max_distance - camera_hard_margin
	if ray_distance < camera_distance:
		camera_distance = maxf(camera_min_distance, ray_distance)
	elif ray_distance - camera_soft_margin < camera_distance:
		camera_distance = Util.temporal_lerp(camera_distance, maxf(camera_min_distance, ray_distance - camera_soft_margin), 1.0 - camera_smoothing, delta)
	else:
		camera_distance = Util.temporal_lerp(camera_distance, clampf(ray_distance - camera_soft_margin, camera_min_distance, camera_max_distance), 1.0 - camera_smoothing, delta)
	camera.position.z = camera_distance

func _unhandled_input(event: InputEvent) -> void:
	var input_state : InputManager.InputState = InputManager.get_input_state()
	if input_state != InputManager.InputState.THIRD_PERSON && input_state != InputManager.InputState.BATTERY_CAMERA:
		return
	
	if event is InputEventMouseMotion:
		var event_mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		pitch -= event_mouse_motion.screen_relative.y * 0.1 * look_sensitivity
		yaw -= event_mouse_motion.screen_relative.x * 0.1 * look_sensitivity
		normalize_angles()
		update_angles()

func normalize_angles() -> void:
	pitch = clampf(pitch, -89.0, 89.0)
	yaw = wrapf(yaw, -360.0, 360.0)

func update_angles() -> void:
	basis = Basis.IDENTITY
	rotate_object_local(Vector3.UP, deg_to_rad(yaw))
	rotate_object_local(Vector3.RIGHT, deg_to_rad(pitch))
	rotate_object_local(Vector3.FORWARD, deg_to_rad(roll))
