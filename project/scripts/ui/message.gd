extends Control

signal finished

@export var lines: Array[String] = []

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var click_sound: AudioStreamPlayer = $Click
@onready var ping_sound: AudioStreamPlayer = $Ping
@onready var panel: Control = $Panel

var current_line: int = 0
var active: bool = false
var can_advance: bool = false
var panel_tween: Tween

func _ready() -> void:
	visible = false
	panel.visible = false
	start_dialogue(lines)
	
func start_dialogue(new_lines: Array[String]) -> void:
	lines = new_lines
	current_line = 0
	active = true
	visible = true

	_show_line()

func _show_line() -> void:
	panel.visible = false
	can_advance = false

	if panel_tween:
		panel_tween.kill()

	if current_line >= lines.size():
		_finish()
		return

	label.text = lines[current_line]
	animation_player.play("show_line")

	if !active:
		return

	await get_tree().create_timer(2.0).timeout

	ping_sound.play()
	_start_panel_effect()
	can_advance = true

func _start_panel_effect() -> void:
	panel.visible = true
	panel.modulate.a = 0.0

	if panel_tween:
		panel_tween.kill()

	panel_tween = create_tween()

	panel_tween.tween_property(panel, "modulate:a", 1.0, 0.4)
	panel_tween.tween_property(panel, "modulate:a", 0.3, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	panel_tween.tween_property(panel, "modulate:a", 1.0, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	panel_tween.set_loops()

func _finish() -> void:
	active = false
	can_advance = false
	visible = false
	label.text = ""

	finished.emit()

func _input(event: InputEvent) -> void:
	if !active or !can_advance:
		return

	if event is InputEventMouseButton and event.pressed:
		if panel_tween:
			panel_tween.kill()

		panel.visible = false
		click_sound.play()

		current_line += 1
		_show_line()
