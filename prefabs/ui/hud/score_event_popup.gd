class_name ScoreEventPopup extends Control

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var name_label: Label = %NameLabel
@onready var score_label: Label = %ScoreLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	animation_player.play("score_event_popup")

func set_data(name: String, score: int) -> void:
	name_label.text = name
	score_label.text = "+%d" % score
