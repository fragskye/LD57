class_name Main extends Node3D

func _on_throw_minigame_power_result(power: float) -> void:
	InputManager.switch_input_state(InputManager.InputState.BATTERY_CAMERA)
