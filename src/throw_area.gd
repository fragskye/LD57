class_name ThrowArea extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	EventBus.throw_area_entered.emit()
