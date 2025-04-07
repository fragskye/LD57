extends CanvasLayer

const SCORE_EVENT_POPUP: PackedScene = preload("res://prefabs/ui/hud/score_event_popup.tscn")

@onready var notification_shadow: ColorRect = %NotificationShadow
@onready var notification_menu: Control = %NotificationMenu
@onready var score_event_popup_list: VBoxContainer = %ScoreEventPopupList

func _ready() -> void:
	EventBus.score_event.connect(_on_score_event)
	EventBus.players_initialized.connect(_on_players_initialized)
	EventBus.player_turn_started.connect(_on_player_turn_started)

func _on_players_initialized() -> void:
	pass

func _on_player_turn_started(player_data: PlayerData) -> void:
	pass

func _process(delta: float) -> void:
	if score_event_popup_list.get_child_count() > 0:
		notification_shadow.show()
	else:
		notification_shadow.hide()

func _on_score_event(name: String, score: int) -> void:
	var score_event_popup: ScoreEventPopup = SCORE_EVENT_POPUP.instantiate()
	score_event_popup_list.add_child(score_event_popup)
	score_event_popup.set_data(name, score)
