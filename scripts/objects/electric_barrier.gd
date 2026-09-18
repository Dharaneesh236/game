class_name ElectricBarrier
extends Node3D

# Electric Arc Barrier Hazard for RoboVerse

signal barrier_deactivated()

@export var is_active: bool = true

@onready var beam_mesh: MeshInstance3D = $BeamMesh
@onready var hazard_area: Area3D = $HazardArea
@onready var barrier_light: OmniLight3D = $BarrierLight
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	add_to_group("electric_barriers")
	add_to_group("optical_barriers")
	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_body_entered)
	if interactable:
		interactable.interacted.connect(_on_interacted)

func bypass_barrier() -> void:
	deactivate_barrier()

func _process(delta: float) -> void:
	if is_active and barrier_light:
		# Pulsing electric arc glow
		barrier_light.light_energy = 2.0 + sin(Time.get_ticks_msec() * 0.02) * 1.5

func deactivate_barrier() -> void:
	if not is_active:
		return
	is_active = false
	if beam_mesh:
		beam_mesh.visible = false
	if barrier_light:
		barrier_light.light_color = Color(0.2, 1.0, 0.4)
		barrier_light.light_energy = 0.8
	if interactable:
		interactable.is_active = false
	AudioSynth.play_repair_success()
	GameState.show_dialogue("System", "High-voltage arc barrier neutralized.")
	barrier_deactivated.emit()

func activate_optical_switch() -> void:
	deactivate_barrier()

func _on_hazard_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	if body.is_in_group("player"):
		AudioSynth.play_hazard_zap()
		var push = (body.global_position - global_position).normalized()
		push.y = 0.3
		if body is CharacterBody3D:
			body.velocity = push * 10.0
		if body.has_method("take_damage"):
			body.take_damage(20.0, "High-Voltage Electric Barrier")

func _on_interacted(interactor: Node) -> void:
	deactivate_barrier()
