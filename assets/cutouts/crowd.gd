class_name Crowd extends Node3D

@onready var sprite_transform: Node3D = %SpriteTransform
@onready var sprite_3d: Sprite3D = %Sprite3D

@export var cheer_texture: Texture2D = null

var standing_texture: Texture2D = null

func _ready() -> void:
	standing_texture = sprite_3d.texture
	EventBus.crowd_cheer.connect(_on_crowd_cheer)

func _on_crowd_cheer() -> void:
	sprite_3d.texture = cheer_texture
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite_transform, "position", Vector3(0.0, 1.0, 0.0), 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(sprite_transform, "position", Vector3.ZERO, 1.0)
	tween.tween_interval(0.25)
	await tween.finished
	sprite_3d.texture = standing_texture
