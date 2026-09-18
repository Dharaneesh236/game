class_name PowerCable
extends Node3D

# Reusable Electrical Cable System for RoboVerse

signal cable_connected(cable_ref: PowerCable)

@export var is_connected: bool = false
@export var connected_machine_path: NodePath
@export var cable_color: Color = Color(0.0, 0.85, 1.0)

@onready var cable_mesh: MeshInstance3D = $CableMesh
@onready var spark_particles: OmniLight3D = $SparkLight
@onready var interactable: Interactable = $Interactable

var pulse_time: float = 0.0

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_on_interacted)
	_update_state()

func _process(delta: float) -> void:
	if is_connected and cable_mesh:
		# Pulsing glow effect when powered
		pulse_time += delta * 4.0
		var energy = 1.8 + sin(pulse_time) * 0.6
		if cable_mesh.material_override is StandardMaterial3D:
			cable_mesh.material_override.emission_energy_multiplier = energy

func _update_state() -> void:
	if is_connected:
		if interactable:
			interactable.is_active = false
		if spark_particles:
			spark_particles.light_energy = 2.0
			spark_particles.light_color = cable_color
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.1, 0.12)
		mat.emission_enabled = true
		mat.emission = cable_color
		mat.emission_energy_multiplier = 2.0
		if cable_mesh:
			cable_mesh.material_override = mat
	else:
		if interactable:
			interactable.is_active = true
			interactable.prompt_message = "[E] Connect Power Conduit"
		if spark_particles:
			spark_particles.light_energy = 0.4
			spark_particles.light_color = Color(1.0, 0.5, 0.1)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.15, 0.15, 0.15)
		mat.emission_enabled = false
		if cable_mesh:
			cable_mesh.material_override = mat

func connect_cable() -> void:
	if is_connected:
		return
	is_connected = true
	_update_state()
	AudioSynth.play_repair_success()
	cable_connected.emit(self)
	
	if connected_machine_path:
		var machine = get_node_or_null(connected_machine_path)
		if machine and machine.has_method("power_on"):
			machine.power_on()

func _on_interacted(interactor: Node) -> void:
	connect_cable()
