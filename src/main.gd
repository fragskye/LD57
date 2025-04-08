class_name Main extends Node3D

@onready var environment: GameEnvironment = %Environment
@onready var gather_battery: GatherBattery = %GatherBattery
@onready var throw_minigame: ThrowMinigame = %ThrowMinigame
@onready var tumbling_battery: TumblingBattery = %TumblingBattery
@onready var start_camera: Camera3D = %StartCamera
@onready var start_layer: CanvasLayer = %StartLayer

@export var cpu_count: int = 0
@export var cpu_list: Array[CPUData] = []

var current_player: int = 0
var current_player_data: PlayerData:
	get():
		return Global.players[current_player]
		
var _max_rounds : int = 3
var _curr_round : int = 0

func get_current_round() -> int:
	return _curr_round + 1

func _ready() -> void:
	Global.main = self
	Global.player_count = 1 + cpu_count
	Global.players.push_back(PlayerData.new(0, "YOU"))
	var unused_cpus: Array[CPUData] = cpu_list.duplicate()
	for i: int in cpu_count:
		var player_data: PlayerData = PlayerData.new(i + 1, "CPU %d" % (i + 1))
		var cpu_index: int = randi_range(0, unused_cpus.size() - 1)
		player_data.cpu = unused_cpus[cpu_index]
		unused_cpus.remove_at(cpu_index)
		Global.players.push_back(player_data)
	InputManager.input_state_changed.connect(_on_input_state_changed)
	EventBus.players_initialized.emit()
	
	start_camera.make_current()
	environment.terrain_3d.set_camera(start_camera)

func _on_gather_battery_gathered() -> void:
	throw_minigame.reset()
	InputManager.switch_input_state(InputManager.InputState.THROW_MINIGAME)

func _on_throw_minigame_power_result(power: float) -> void:
	tumbling_battery.reset()
	tumbling_battery.power = power
	InputManager.switch_input_state(InputManager.InputState.BATTERY_CAMERA)
	environment.beach.hide()

func _on_tumbling_battery_score_result(score: int) -> void:
	environment.beach.show()
	Global.players[current_player].score += score
	current_player = (current_player + 1) % Global.player_count
	
	# We know we've done one successful loop around every player when this is back to 0.
	if current_player == 0:
		_curr_round = _curr_round + 1
		if _curr_round == _max_rounds:
			Engine.time_scale = 1.0
			InputManager.switch_input_state(InputManager.InputState.RESULTS)
			return
	
	EventBus.player_turn_started.emit(Global.players[current_player])
	if current_player_data.cpu == null:
		Engine.time_scale = 1.0
		gather_battery.reset()
		InputManager.switch_input_state(InputManager.InputState.GATHER_BATTERY)
	else:
		throw_minigame.reset()
		InputManager.switch_input_state(InputManager.InputState.THROW_MINIGAME)

func _on_throw_area_entered() -> void:
	throw_minigame.reset()
	InputManager.switch_input_state(InputManager.InputState.THROW_MINIGAME)

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	if old_state == InputManager.InputState.MENU || new_state == InputManager.InputState.MENU:
		return
	
	match new_state:
		InputManager.InputState.LEVEL_LOAD:
			gather_battery.reset()
			InputManager.switch_input_state(InputManager.InputState.GATHER_BATTERY)

func _on_play_button_pressed() -> void:
	start_layer.hide()
	start_layer.process_mode = Node.PROCESS_MODE_DISABLED
	gather_battery.reset()
	InputManager.switch_input_state(InputManager.InputState.GATHER_BATTERY)
	EventBus.player_turn_started.emit(Global.players[0])
