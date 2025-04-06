class_name GameEnvironment extends Node3D

@onready var terrain_3d: Terrain3D = %Terrain3D

func _ready() -> void:
	Global.environment = self
