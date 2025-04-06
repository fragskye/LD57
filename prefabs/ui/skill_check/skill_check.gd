class_name SkillCheck extends Control

signal target_hit
signal target_missed
signal target_complete
signal bar_entered_target

const EXTRA_CHECK: float = 30.0

@export var circle_color: Color = Color.WHITE
@export var target_color: Color = Color.WHITE
@export var target_disabled_color: Color = Color.WHITE
@export var bar_color: Color = Color.WHITE
@export var circle_radius: float = 512.0
@export var circle_width: float = 8.0
@export var target_width: float = 64.0
@export var bar_length: float = 32.0
@export var bar_width: float = 8.0

@export var bar_spin_speed: float = 0.0
var bar_angle: float = 0.0
var target_angle: float = 0.0
@export var target_arc_length: float = 0.0
var target_disabled: bool = false
@export var miss_margin: float = 5.0
var can_miss_early: bool = true

@export var next_target_angle_offset: float = 90.0
@export var next_target_arc_length: float = 30.0

var _last_bar_over_target: bool = false

func _ready() -> void:
	reset()

func reset() -> void:
	bar_angle = 0.0
	randomize_target()

func _process(delta: float) -> void:
	bar_angle = wrapf(bar_angle + bar_spin_speed * delta, 0.0, 360.0)
	var missed_main: bool = bar_angle > target_angle + target_arc_length && bar_angle <= target_angle + target_arc_length + EXTRA_CHECK
	var missed_wrap: bool = target_angle + target_arc_length + EXTRA_CHECK > 360.0 && bar_angle > target_angle + target_arc_length - 360.0 && bar_angle <= target_angle + target_arc_length - 360.0 + EXTRA_CHECK
	if missed_main || missed_wrap:
		if !target_disabled:
			target_disabled = true
			target_missed.emit()
	var complete_main: bool = bar_angle > target_angle + target_arc_length + miss_margin && bar_angle <= target_angle + target_arc_length + miss_margin + EXTRA_CHECK
	var complete_wrap: bool = target_angle + target_arc_length + miss_margin + EXTRA_CHECK > 360.0 && bar_angle > target_angle + target_arc_length - 360.0 + miss_margin && bar_angle <= target_angle + target_arc_length - 360.0 + miss_margin + EXTRA_CHECK
	if complete_main || complete_wrap:
		randomize_target()
		target_complete.emit()
	var bar_over_target: bool = is_bar_over_target()
	if bar_over_target && !_last_bar_over_target:
		bar_entered_target.emit()
	_last_bar_over_target = bar_over_target
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, circle_radius, 0.0, TAU, 256, circle_color, circle_width, true)
	draw_arc(Vector2.ZERO, circle_radius, deg_to_rad(target_angle), deg_to_rad(target_angle + target_arc_length), 256, target_disabled_color if target_disabled else target_color, target_width, true)
	var bar_dir: Vector2 = Vector2(cos(deg_to_rad(bar_angle)), sin(deg_to_rad(bar_angle)))
	draw_line((circle_radius - bar_length * 0.5) * bar_dir, (circle_radius + bar_length * 0.5) * bar_dir, bar_color, bar_width, true)

func randomize_target() -> void:
	target_angle = wrapf(bar_angle + next_target_angle_offset, 0.0, 360.0)
	target_arc_length = next_target_arc_length
	target_disabled = false

func press_bar() -> void:
	if target_disabled:
		return
	
	if is_bar_over_target():
		randomize_target()
		target_hit.emit()
		target_complete.emit()
	elif can_miss_early:
		target_disabled = true
		target_missed.emit()

func is_bar_over_target() -> bool:
	var hit_main: bool = bar_angle >= target_angle && bar_angle <= target_angle + target_arc_length
	var hit_wrap: bool = target_angle + target_arc_length > 360.0 && bar_angle <= target_angle + target_arc_length - 360.0
	return hit_main || hit_wrap
