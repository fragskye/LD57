class_name ButtonMashing
extends CanvasLayer

signal on_successful_keymash()

@onready var label : Label = $TextureRect/Label
@onready var rect : TextureRect = $TextureRect

@export var max_mashes : int = 5

var _random_keys : Array[String] = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']
var _random_key_idx : int = 0

var _is_active : bool = false
var _active_tween : Tween = null
var _current_mashes : int = 0

func _ready() -> void:
	disable()

func enable() -> void:
	show()
	_current_mashes = 0
	_is_active = true
	_randomize_key()

func disable() -> void:
	hide()
	_is_active = false

func _unhandled_key_input(event: InputEvent) -> void:
	if !_is_active:
		return
	
	if event is not InputEventKey:
		return
	
	var key_event : InputEventKey = event
	var key : String = key_event.as_text_key_label().to_upper()
	
	if key != _random_keys[_random_key_idx]:
		return
	
	on_successful_keymash.emit()
	_current_mashes = _current_mashes + 1
	_randomize_key()
	
	if _active_tween != null:
		_active_tween.stop()
	rect.scale = Vector2(1.3, 1.3)
	_active_tween = get_tree().create_tween()
	_active_tween.tween_property(rect, "scale", Vector2.ONE, 1)
	
	if _current_mashes >= max_mashes:
		disable()

func _randomize_key() -> void:
	_random_key_idx = randi_range(0, _random_keys.size() - 1)
	label.text = _random_keys[_random_key_idx]
