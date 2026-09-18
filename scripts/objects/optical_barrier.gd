class_name OpticalBarrier
extends Node3D

# Optical Laser Tripwire / Sensor Grid Hazard for RoboVerse
# Emits synchronized optical laser tripwires that detect intrusion.
# Can be bypassed via optical prism alignment console or Petalo illumination.

signal barrier_deactivated()

@export var is_active: bool = true
@export var barrier_width: float = 6.0

@onready var beam_mesh_upper: MeshInstance3D = $BeamMeshUpper
@onready var beam_mesh_lower: MeshInstance3D = $BeamMeshLower
@onready var hazard_area: Area3D = $HazardArea
@onready var optical_light: OmniLight3D = $OpticalLight
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_body_entered)
	if interactable:
		interactable.interacted.connect(_on_interacted)

func _process(delta: float) -> void:
	if is_active and optical_light:
		# Rapid pulse for laser tripwire shimmer
		var pulse = 2.2 + sin(Time.get_ticks_msec() * 0.016) * 1.4
		optical_light.light_energy = pulse

func deactivate_barrier() -> void:
	if not is_active:
		return
	is_active = false
	if beam_mesh_upper:
		beam_mesh_upper.visible = false
	if beam_mesh_lower:
		beam_mesh_lower.visible = false
	if optical_light:
		optical_light.light_color = Color(0.2, 1.0, 0.5)
		optical_light.light_energy = 1.0
	if interactable:
		interactable.is_active = false
	AudioSynth.play_repair_success()
	GameState.show_dialogue("Optical Grid", "Laser tripwires refracted. Passage safely secured.")
	barrier_deactivated.emit()

func bypass_with_petalo() -> void:
	deactivate_barrier()

func _on_hazard_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	if body.is_in_group("player"):
		AudioSynth.play_hazard_zap()
		var push = (body.global_position - global_position).normalized()
		push.y = 0.25
		if body is CharacterBody3D:
			body.velocity = push * 9.5
		if body.has_method("take_damage"):
			body.take_damage(15.0, "Optical Laser Grid")
		else:
			GameState.show_dialogue("Security Grid", "Warning! Optical intrusion detected. Tripwire energized.")

func _on_interacted(interactor: Node) -> void:
	deactivate_barrier()
