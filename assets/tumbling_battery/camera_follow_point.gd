class_name CameraFollowPoint3D
extends Node3D

@export var rigidbody : RigidBody3D = null
@export var prediction_amount : float = 0.0

@export var position_smoothing : float = 0.0
@export var velocity_smoothing : float = 0.0

var _smoothed_velocity : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if !is_instance_valid(rigidbody):
		return
	
	_smoothed_velocity = Util.temporal_lerp_v3(_smoothed_velocity, rigidbody.linear_velocity, 1.0 - velocity_smoothing, delta)
	
	var target_position : Vector3 = rigidbody.global_position
	
	if prediction_amount != 0:
		# Probably not want to normalize bc we want the strength of prediction to
		#   be determined by how fast we are moving
		target_position += (prediction_amount * _smoothed_velocity)
	
	global_position = Util.temporal_lerp_v3(global_position, target_position, 1.0 - position_smoothing, delta)
