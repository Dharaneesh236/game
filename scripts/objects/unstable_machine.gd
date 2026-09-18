class_name UnstableMachine
extends Node3D

# Unstable Equipment Hazard System for RoboVerse

signal stabilized(machine_ref: UnstableMachine)

@export var is_active_hazard: bool = true
@export var rotation_speed: float = 3.5
@export var machine_name: String = "Malfunctioning Generator"

@onready var rotor: Node3D = $Rotor
@onready var hazard_area: Area3D = $Rotor/HazardArea
@onready var warning_light: OmniLight3D = $WarningLight
@onready var interactable: Interactable = $Interactable

var is_stabilized: bool = false
var current_rot_speed: float = 3.5

func _ready() -> void:
	current_rot_speed = rotation_speed
	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_body_entered)
	if interactable:
		interactable.interacted.connect(_on_stabilize_interacted)
		interactable.prompt_message = "[E] Stabilize " + machine_name

func _process(delta: float) -> void:
	if not is_stabilized:
		if rotor:
			rotor.rotate_y(current_rot_speed * delta)
		# Flashing warning light
		if warning_light:
			warning_light.light_energy = 1.5 + sin(Time.get_ticks_msec() * 0.01) * 1.2
	else:
		# Slow down to stop
		if current_rot_speed > 0.01:
			current_rot_speed = move_toward(current_rot_speed, 0.0, delta * 2.0)
			if rotor:
				rotor.rotate_y(current_rot_speed * delta)

func stabilize_machine() -> void:
	if is_stabilized:
		return
	is_stabilized = true
	is_active_hazard = false
	if interactable:
		interactable.is_active = false
	if warning_light:
		warning_light.light_color = Color(0.2, 1.0, 0.4) # Stable green
		warning_light.light_energy = 2.0
	AudioSynth.play_repair_success()
	GameState.show_dialogue("System", machine_name + " stabilized. Electrical feedback neutralized.")
	stabilized.emit(self)

func _on_hazard_body_entered(body: Node3D) -> void:
	if not is_active_hazard or is_stabilized:
		return
	if body.is_in_group("player"):
		AudioSynth.play_hazard_zap()
		# Slight pushback vector
		var push_dir = (body.global_position - global_position).normalized()
		push_dir.y = 0.2
		if body is CharacterBody3D:
			body.velocity = push_dir * 9.0
		if body.has_method("take_damage"):
			body.take_damage(15.0, machine_name)

func _on_stabilize_interacted(interactor: Node) -> void:
	stabilize_machine()
