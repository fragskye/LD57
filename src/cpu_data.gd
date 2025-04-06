class_name CPUData extends Resource

@export_group("Throw Minigame", "throw_minigame_")
@export var throw_minigame_start_success_odds: float = 0.0
@export var throw_minigame_end_success_odds: float = 0.0
@export var throw_minigame_start_delay_range: Vector2 = Vector2.ZERO
@export var throw_minigame_end_delay_range: Vector2 = Vector2.ZERO

func throw_minigame_get_success(time_mix: float) -> bool:
	var success_odds: float = lerpf(throw_minigame_start_success_odds, throw_minigame_end_success_odds, time_mix)
	return randf() < success_odds

func throw_minigame_get_delay(time_mix: float) -> float:
	var delay_range: Vector2 = throw_minigame_start_delay_range.lerp(throw_minigame_end_delay_range, time_mix)
	return randf_range(delay_range.x, delay_range.y)
