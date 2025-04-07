extends Node

enum InputState { MENU, THIRD_PERSON, GATHER_BATTERY, THROW_MINIGAME, BATTERY_CAMERA, CUTSCENE }

signal input_state_changed(old_state: InputState, new_state: InputState)

const DEFAULT_INPUT_STATE: InputState = InputState.GATHER_BATTERY

var input_state_stack: Array[InputState] = []

func _ready() -> void:
	input_state_stack.push_back(DEFAULT_INPUT_STATE)
	input_state_changed.connect(_on_input_state_changed)
	input_state_changed.emit(DEFAULT_INPUT_STATE, DEFAULT_INPUT_STATE)
	input_state_changed.emit(DEFAULT_INPUT_STATE, DEFAULT_INPUT_STATE)
	await get_tree().process_frame
	input_state_changed.emit(DEFAULT_INPUT_STATE, DEFAULT_INPUT_STATE)

func _on_input_state_changed(_old_state: InputState, new_state: InputState) -> void:
	match new_state:
		InputState.THIRD_PERSON:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		InputState.BATTERY_CAMERA:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func get_input_state() -> InputState:
	if input_state_stack.is_empty():
		return DEFAULT_INPUT_STATE
	return input_state_stack[input_state_stack.size() - 1]

func push_input_state(state: InputState) -> void:
	var old_state: InputState = get_input_state()
	input_state_stack.push_back(state)
	input_state_changed.emit(old_state, get_input_state())

func pop_input_state() -> void:
	var old_state: InputState = get_input_state()
	input_state_stack.pop_back()
	if input_state_stack.is_empty():
		input_state_stack.push_back(DEFAULT_INPUT_STATE)
	input_state_changed.emit(old_state, get_input_state())

func switch_input_state(state: InputState) -> void:
	var old_state: InputState = get_input_state()
	input_state_stack.pop_back()
	input_state_stack.push_back(state)
	input_state_changed.emit(old_state, get_input_state())
