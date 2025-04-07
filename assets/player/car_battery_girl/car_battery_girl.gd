class_name CarBatteryGirl extends Node3D

@onready var animation_player: AnimationPlayer = $car_battery_girl/AnimationPlayer

func _ready() -> void:
	reset_pose()

func reset_pose() -> void:
	animation_player.play("RESET")

func spin_pose() -> void:
	pass

func lift_pose() -> void:
	animation_player.play("BEND")

func victory_pose() -> void:
	pass
