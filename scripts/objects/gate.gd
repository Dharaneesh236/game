class_name SecurityGate
extends Node3D

# Sci-Fi Sliding Security Gate for RoboVerse

signal gate_opened()

@export var is_open: bool = false
@export var is_locked: bool = true
@export var requires_tolly: bool = false
@export var open_distance: float = 2.4

@onready var door_left: AnimatableBody3D = $DoorLeft
@onready var door_right: AnimatableBody3D = $DoorRight
@onready var status_light: OmniLight3D = $StatusLight
@onready var interactable: Interactable = $Interactable

var left_closed_pos: Vector3
var right_closed_pos: Vector3
var target_open_ratio: float = 0.0
var current_open_ratio: float = 0.0

func _ready() -> void:
	add_to_group("security_gates")
	if door_left:
		left_closed_pos = door_left.position
	if door_right:
		right_closed_pos = door_right.position

	if interactable:
		interactable.interacted.connect(_on_interacted)

	_update_visuals()

func _process(delta: float) -> void:
	target_open_ratio = 1.0 if is_open else 0.0
	if abs(current_open_ratio - target_open_ratio) > 0.005:
		current_open_ratio = move_toward(current_open_ratio, target_open_ratio, delta * 2.0)
		if door_left:
			door_left.position.x = left_closed_pos.x - (current_open_ratio * open_distance)
		if door_right:
			door_right.position.x = right_closed_pos.x + (current_open_ratio * open_distance)

func open_gate() -> void:
	if is_open:
		return
	is_open = true
	is_locked = false
	AudioSynth.play_gate()
	_update_visuals()
	gate_opened.emit()

func unlock_gate() -> void:
	# Called by Tolly access robot
	open_gate()

func _update_visuals() -> void:
	if status_light:
		if is_open or not is_locked:
			status_light.light_color = Color(0.2, 1.0, 0.4) # Green
			status_light.light_energy = 2.0
		else:
			status_light.light_color = Color(1.0, 0.2, 0.2) # Red
			status_light.light_energy = 1.8

	if interactable:
		if is_open:
			interactable.is_active = false
		elif is_locked and requires_tolly:
			interactable.prompt_message = "[E] Command Tolly to Unlock Gate"
		else:
			interactable.prompt_message = "[E] Open Security Gate"

func _on_interacted(interactor: Node) -> void:
	if is_locked and requires_tolly:
		if GameState.robots["TOLLY"]["repaired"]:
			GameState.robot_command_requested.emit("TOLLY", global_position)
			await get_tree().create_timer(1.4).timeout
			unlock_gate()
		else:
			GameState.show_dialogue("Security", "Gate locked. Requires Tolly Access Protocol.")
	elif not is_locked:
		open_gate()
	else:
		GameState.show_dialogue("System", "Gate offline. Restore facility power first.")

