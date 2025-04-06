class_name CarBattery
extends RigidBody3D

## Minimum depth under the water for the depth score to begin accumulating
@export var depth_score_minimum : float = -50

## How many units of depth translates to one unit of score
@export var depth_score_step : float = 2.5 

## How much velocity is required for collision score to begin accumulating
@export var collision_score_minimum : float = 2.5

## How many units of velocity translates to one unit of score
@export var collision_score_step : float = 2.5

var current_score : int = 0

var _depth_score : int = 0
var _collision_score : int = 0

func _ready() -> void:
	body_entered.connect(_on_collision)

func _process(delta: float) -> void:
	if (global_position.y < depth_score_minimum):
		var depth : float = abs(global_position.y - depth_score_minimum)
		_depth_score = ceili(depth / depth_score_step)
	else:
		_depth_score = 0
	
	current_score = _depth_score + _collision_score

func _on_collision(body: Node) -> void:
	if (linear_velocity.length() < collision_score_minimum):
		return
	
	var this_collision_score : float = ceili((linear_velocity.length() - collision_score_minimum) / collision_score_step)
	
	_collision_score += this_collision_score
