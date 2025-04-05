class_name Main extends Node3D

@onready var throw_minigame: ThrowMinigame = %ThrowMinigame

static var throw_minigame_difficulty: int = 2

func _process(delta: float) -> void:
	throw_minigame.difficulty_index = throw_minigame_difficulty

func _on_throw_minigame_power_result(power: float) -> void:
	InputManager.switch_input_state(InputManager.InputState.BATTERY_CAMERA)
