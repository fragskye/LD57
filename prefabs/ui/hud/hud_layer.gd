class_name HUDLayer extends CanvasLayer

const PLAYER_SCORE: PackedScene = preload("res://prefabs/ui/hud/player_score.tscn")

@onready var hud_menu: Control = %HUDMenu
@onready var player_scores: Control = %PlayerScores

func _ready() -> void:
	EventBus.players_initialized.connect(_on_players_initialized)
	EventBus.player_turn_started.connect(_on_player_turn_started)

func _on_players_initialized() -> void:
	for i: int in Global.player_count:
		var player_score: PlayerScore = PLAYER_SCORE.instantiate()
		player_scores.add_child(player_score)
		player_score.player_data = Global.players[i]
		player_score.player_data.score_changed.connect(_on_player_data_score_changed)
	_sort_player_scores()

func _on_player_turn_started(player_data: PlayerData) -> void:
	for node: Node in player_scores.get_children():
		var player_score: PlayerScore = node as PlayerScore
		player_score.active_turn = player_score.player_data.id == player_data.id

func _on_player_data_score_changed(new_score: int) -> void:
	_sort_player_scores()

func _sort_player_scores() -> void:
	var sorted_nodes: Array[Node] = player_scores.get_children()
	
	sorted_nodes.sort_custom(func(a: Node, b: Node) -> bool:
		var a_score: PlayerScore = a as PlayerScore
		var b_score: PlayerScore = b as PlayerScore
		return a_score.player_data.score - a_score.player_data.id > b_score.player_data.score - b_score.player_data.id
	)
	
	for node: Node in player_scores.get_children():
		player_scores.remove_child(node)
	
	var y: float = 0.0
	for i: int in sorted_nodes.size():
		var player_score: PlayerScore = sorted_nodes[i] as PlayerScore
		player_scores.add_child(player_score)
		var scalar: float = 1.0 if (i == 0) else (0.8 - float(i - 1) * 0.05)
		player_score.scale = Vector2.ONE * scalar
		player_score.position.y = y
		y += player_score.size.y * player_score.scale.y + 16
