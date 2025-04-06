class_name GameEnvironment extends Node3D

@onready var terrain_3d: Terrain3D = %Terrain3D
@onready var beach: Node3D = %Beach
@onready var ocean: Node3D = %Ocean
@onready var underwater: Node3D = %Underwater

func _ready() -> void:
	Global.environment = self
