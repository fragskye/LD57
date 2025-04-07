class_name ResultsLayer
extends CanvasLayer

const PLAYER_SCORE: PackedScene = preload("res://prefabs/ui/hud/player_score.tscn")

# too lazy to give these guys descriptive names in editor, whoops
@onready var winner_label : Label = $Label
@onready var player_scores : Control = $VBoxContainer
@onready var restart_button : Button = $Button

func _ready() -> void:
	InputManager.input_state_changed.connect(_on_input_state_changed)
	restart_button.pressed.connect(_on_restart_pressed)

func enable() -> void:
	show()
	
	if (player_scores.get_children().size() == 0):
		for i: int in Global.player_count:
			var player_score: PlayerScore = PLAYER_SCORE.instantiate()
			player_scores.add_child(player_score)
			player_score.player_data = Global.players[i]

	_sort_player_scores()

func disable() -> void:
	hide()

func _sort_player_scores() -> void:
	var sorted_nodes: Array[Node] = player_scores.get_children()
	
	sorted_nodes.sort_custom(func(a: Node, b: Node) -> bool:
		var a_score: PlayerScore = a as PlayerScore
		var b_score: PlayerScore = b as PlayerScore
		return a_score.player_data.score - a_score.player_data.id > b_score.player_data.score - b_score.player_data.id
	)
	
	for node: Node in player_scores.get_children():
		player_scores.remove_child(node)
	
	for i: int in sorted_nodes.size():
		var player_score: PlayerScore = sorted_nodes[i] as PlayerScore
		player_scores.add_child(player_score)
	
	var winner : PlayerData = (sorted_nodes[0] as PlayerScore).player_data
	
	# player name is "YOU" so its more grammatically correct to say "YOU WIN!"
	if winner.id == 0:
		winner_label.text = "%s WIN!" % winner.name
	else:
		winner_label.text = "%s WINS!" % winner.name
		
func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.RESULTS:
			enable()
			process_mode = Node.PROCESS_MODE_PAUSABLE
		_:
			disable()
			process_mode = Node.PROCESS_MODE_DISABLED

func _on_restart_pressed() -> void:
	get_tree().quit()
