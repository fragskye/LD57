class_name PlayerScore extends PanelContainer

@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_score: Label = %PlayerScore

@export var active_turn: bool = false:
	set(value):
		var old_value: bool = active_turn
		active_turn = value
		if active_turn && !old_value:
			add_theme_stylebox_override("panel", active_stylebox)
		elif !active_turn && old_value:
			remove_theme_stylebox_override("panel")

@export var active_stylebox: StyleBox = null

var player_data: PlayerData = null:
	set(value):
		if player_data != null:
			player_data.score_changed.disconnect(_on_player_data_score_changed)
		player_data = value
		if player_data == null:
			player_name.text = ""
			player_score.text = "0 points"
		else:
			player_name.text = player_data.name
			player_score.text = "%d points" % player_data.score
			player_data.score_changed.connect(_on_player_data_score_changed)

func _on_player_data_score_changed(new_score: int) -> void:
	player_score.text = str(new_score)
