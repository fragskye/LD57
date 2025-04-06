class_name HUDLayer extends CanvasLayer

@onready var hud_menu: Control = %HUDMenu
@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_score: Label = %PlayerScore

var _played_data: PlayerData = null

func _ready() -> void:
	EventBus.player_turn_started.connect(_on_player_turn_started)

func _on_player_turn_started(player_data: PlayerData) -> void:
	if _played_data != null:
		_played_data.score_changed.disconnect(_on_player_data_score_changed)
	player_name.text = player_data.name
	player_score.text = str(player_data.score)
	_played_data = player_data
	_played_data.score_changed.connect(_on_player_data_score_changed)

func _on_player_data_score_changed(new_score: int) -> void:
	player_score.text = str(new_score)
