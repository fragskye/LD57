class_name CameraFollowPoint3D
extends Node3D

@export var rigidbody : RigidBody3D
@export var predictionAmount : float
@export var look_sensitivity: float = 1.0

var pitch: float = 0.0
var yaw: float = 0.0
var roll: float = 0.0

var _last_frame_velocity : Vector3 = Vector3.ZERO
var _curr_frame_velocity : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if predictionAmount == 0 || !is_instance_valid(rigidbody):
		return
	
	_last_frame_velocity = _curr_frame_velocity
	_curr_frame_velocity = rigidbody.linear_velocity
	

# I am aware _physics_process might be a better method
#  however this would work better with physics interpolation
func _process(delta: float) -> void:
	var base_position : Vector3 = rigidbody.global_position
	
	var final_position : Vector3 = base_position
	
	if predictionAmount != 0:
		var velocity : Vector3 = Util.temporal_lerp_v3(_last_frame_velocity, _curr_frame_velocity, 0.1, delta)
		
		# Probably not want to normalize bc we want the strength of prediction to
		#   be determined by how fast we are moving
		final_position = base_position + (predictionAmount * delta * velocity)
	
	global_position = final_position

func _unhandled_input(event: InputEvent) -> void:
	if InputManager.get_input_state() != InputManager.InputState.THIRD_PERSON:
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
