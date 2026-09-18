class_name OpeningCinematic
extends Node3D

# Cinematic Opening Controller for RoboVerse: The Last Signal

signal cinematic_finished()

@onready var cinematic_cam: Camera3D = $CinematicCam
@onready var blackout: ColorRect = $CanvasLayer/Blackout
@onready var glitch_rect: ColorRect = $CanvasLayer/GlitchRect
@onready var title_label: Label = $CanvasLayer/TitleLabel
@onready var subtitle_label: Label = $CanvasLayer/SubtitleLabel
@onready var transmission_box: Panel = $CanvasLayer/TransmissionBox
@onready var transmission_text: Label = $CanvasLayer/TransmissionBox/Text
@onready var skip_label: Label = $CanvasLayer/SkipLabel

var is_running: bool = true
var elapsed: float = 0.0

func _ready() -> void:
	skip_label.text = "[CLICK], [SPACE] or [ESC] to Skip Prologue"
	transmission_box.visible = false
	glitch_rect.visible = false
	_run_sequence()

func _input(event: InputEvent) -> void:
	if is_running:
		if (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("jump") or event.is_action_pressed("pause") or (event is InputEventKey and event.pressed):
			_skip_cinematic()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if is_running:
		elapsed += delta

func _run_sequence() -> void:
	# 1. Dark screen, low hum
	blackout.color = Color(0, 0, 0, 1.0)
	title_label.text = "ROBOVERSE: THE LAST SIGNAL"
	title_label.modulate.a = 0.0
	
	# Fade in title
	var tw = create_tween()
	tw.tween_property(title_label, "modulate:a", 1.0, 2.5)
	tw.tween_interval(1.5)
	tw.tween_property(title_label, "modulate:a", 0.0, 1.5)
	await tw.finished

	if not is_running: return

	# 2. Distant robotic transmission
	transmission_box.visible = true
	transmission_text.text = "... emergency signal ... detected ...\n... source: Central Signal Tower ..."
	AudioSynth.play_robot_chirp(400.0)
	await get_tree().create_timer(3.0).timeout

	if not is_running: return

	# 3. Screen Glitch & World reveal
	glitch_rect.visible = true
	AudioSynth.play_spark()
	await get_tree().create_timer(0.3).timeout
	glitch_rect.visible = false
	
	# Fade out blackout to reveal world
	var tw2 = create_tween()
	tw2.tween_property(blackout, "color:a", 0.0, 2.0)
	await tw2.finished

	if not is_running: return

	# 4. Power Surge through distant tower
	transmission_text.text = "WARNING: POWER SURGE IN PROGRESS"
	AudioSynth.play_beam_activation()
	await get_tree().create_timer(2.0).timeout

	if not is_running: return

	# 5. Glitch again, player awakening near Landing Area
	glitch_rect.visible = true
	AudioSynth.play_spark()
	await get_tree().create_timer(0.25).timeout
	glitch_rect.visible = false

	transmission_text.text = "INCOMING SIGNAL\nSOURCE: UNKNOWN // DISTANCE: 1.2 KM\n'System failure... central network offline...'"
	await get_tree().create_timer(3.5).timeout

	_finish_cinematic()

func _skip_cinematic() -> void:
	_finish_cinematic()

func _finish_cinematic() -> void:
	if not is_running:
		return
	is_running = false
	cinematic_cam.current = false
	$CanvasLayer.visible = false
	cinematic_finished.emit()
