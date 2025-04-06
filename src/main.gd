class_name Main extends Node3D

@onready var environment: GameEnvironment = %Environment
@onready var throw_minigame: ThrowMinigame = %ThrowMinigame
@onready var tumbling_battery: TumblingBattery = %TumblingBattery

@export var cpu_count: int = 0
@export var cpu_list: Array[CPUData] = []

var current_player: int = 0
var current_player_data: PlayerData:
	get():
		return Global.players[current_player]

func _ready() -> void:
	Global.main = self
	Global.player_count = 1 + cpu_count
	Global.players.push_back(PlayerData.new(0, "YOU"))
	var unused_cpus: Array[CPUData] = cpu_list.duplicate()
	for i: int in cpu_count:
		var player_data: PlayerData = PlayerData.new(i + 1, "CPU%d" % (i + 1))
		var cpu_index: int = randi_range(0, unused_cpus.size() - 1)
		player_data.cpu = unused_cpus[cpu_index]
		unused_cpus.remove_at(cpu_index)
		Global.players.push_back(player_data)
	EventBus.player_turn_started.emit(Global.players[0])
	EventBus.throw_area_entered.connect(_on_throw_area_entered)

func _on_throw_minigame_power_result(power: float) -> void:
	tumbling_battery.reset()
	tumbling_battery.power = power
	InputManager.switch_input_state(InputManager.InputState.BATTERY_CAMERA)

func _on_tumbling_battery_score_result(score: int) -> void:
	Global.players[current_player].score += score
	current_player = (current_player + 1) % Global.player_count
	EventBus.player_turn_started.emit(Global.players[current_player])
	if current_player_data.cpu == null:
		Engine.time_scale = 1.0
		InputManager.switch_input_state(InputManager.InputState.THIRD_PERSON)
	else:
		throw_minigame.reset()
		InputManager.switch_input_state(InputManager.InputState.THROW_MINIGAME)

func _on_throw_area_entered() -> void:
	throw_minigame.reset()
	InputManager.switch_input_state(InputManager.InputState.THROW_MINIGAME)
