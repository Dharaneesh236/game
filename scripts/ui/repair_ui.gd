class_name RepairUI
extends Control

# Futuristic Robot Repair Minigame Interface

signal repair_completed()

@onready var title_label: Label = $Panel/TitleLabel
@onready var robot_label: Label = $Panel/RobotNameLabel
@onready var status_label: Label = $Panel/StatusLabel
@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var connect_btn: Button = $Panel/ConnectButton
@onready var cancel_btn: Button = $Panel/CancelButton
@onready var pulse_indicator: ColorRect = $Panel/PulseIndicator

var target_robot_id: String = ""
var on_success_callback: Callable
var is_repairing: bool = false
var repair_progress: float = 0.0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	connect_btn.pressed.connect(_on_connect_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	GameState.repair_minigame_requested.connect(open_repair)

func open_repair(robot_id: String, callback: Callable) -> void:
	target_robot_id = robot_id
	on_success_callback = callback
	is_repairing = false
	repair_progress = 0.0
	progress_bar.value = 0.0

	var r_name = GameState.robots.get(robot_id, {}).get("name", robot_id)
	robot_label.text = "UNIT: " + r_name.to_upper()
	status_label.text = "FAULT DETECTED: Primary Power Conduit Disconnected"
	connect_btn.text = "ALIGN & CONNECT POWER COUPLER"
	connect_btn.disabled = false
	
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	AudioSynth.play_ui_click(1.0)

func _process(delta: float) -> void:
	if not visible:
		return
	if is_repairing:
		repair_progress += delta * 1.8
		progress_bar.value = clamp(repair_progress * 100.0, 0.0, 100.0)
		pulse_indicator.color = Color(0.0, 1.0, 0.8, 0.4 + sin(Time.get_ticks_msec() * 0.02) * 0.4)
		if repair_progress >= 1.0:
			is_repairing = false
			_finish_repair()

func _on_connect_pressed() -> void:
	if is_repairing:
		return
	is_repairing = true
	connect_btn.disabled = true
	status_label.text = "SYNCHRONIZING POWER FLOW... [PLEASE STAND BY]"
	AudioSynth.play_spark()
	AudioSynth.play_beam_activation()

func _finish_repair() -> void:
	status_label.text = "POWER RESTORED. CORE SYSTEMS ONLINE."
	AudioSynth.play_repair_success()
	GameState.mark_robot_repaired(target_robot_id)
	if on_success_callback.is_valid():
		on_success_callback.call()
	repair_completed.emit()
	
	await get_tree().create_timer(1.2).timeout
	close()

func _on_cancel_pressed() -> void:
	close()

func close() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	AudioSynth.play_ui_click(0.8)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		close()
		get_viewport().set_input_as_handled()
