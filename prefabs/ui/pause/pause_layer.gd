class_name PauseLayer extends CanvasLayer

@onready var pause_menu: Control = %PauseMenu

var _input_state_changed_this_frame: bool = false

func _ready() -> void:
	pause_menu.hide()
	pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
	InputManager.input_state_changed.connect(_on_input_state_changed)

func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.MENU:
		return
	
	if !_input_state_changed_this_frame && Input.is_action_just_pressed("exit"):
		InputManager.pop_input_state()
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	match old_state:
		InputManager.InputState.MENU:
			pause_menu.hide()
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			get_tree().paused = false
	
	match new_state:
		InputManager.InputState.MENU:
			pause_menu.process_mode = Node.PROCESS_MODE_INHERIT
			pause_menu.show()
			get_tree().paused = true

func _on_resume_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.MENU:
		return
	
	InputManager.pop_input_state()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_throw_minigame_difficulty_option_button_item_selected(index: int) -> void:
	Global.throw_minigame_difficulty = index
