class_name PlayerData extends Resource

signal score_changed(new_score: int)

@export var id: int = 0
@export var name: String = ""
@export var score: int = 0:
	set(value):
		score = value
		score_changed.emit(value)
@export var cpu: CPUData = null

func _init(_id: int, _name: String) -> void:
	id = _id
	name = _name
	score = 0
