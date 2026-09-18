class_name SignalNode
extends Node3D

# Optical / Power Signal Node for RoboVerse

signal node_activated(node_ref: SignalNode)

@export var node_identifier: String = "NODE_1"
@export var is_initially_hidden: bool = false
@export var is_active: bool = false
@export var light_color: Color = Color(0.0, 0.9, 1.0)

@onready var pylon_mesh: MeshInstance3D = $PylonMesh
@onready var core_mesh: MeshInstance3D = $CoreMesh
@onready var beam_light: OmniLight3D = $BeamLight
@onready var interactable: Interactable = $Interactable

var is_revealed: bool = false

func _ready() -> void:
	add_to_group("signal_nodes")
	
	if interactable:
		interactable.interacted.connect(_on_interacted)
		interactable.prompt_message = "[E] Activate Signal Node (" + node_identifier + ")"

	if is_initially_hidden and not is_active:
		is_revealed = false
		visible = false
		if interactable:
			interactable.is_active = false
	else:
		is_revealed = true
		visible = true
		_update_visuals()

func _process(_delta: float) -> void:
	# Proximity check: If Petalo is nearby and repaired, her lantern reveals this node
	if is_initially_hidden and not is_revealed and not is_active:
		if GameState.robots.get("PETALO", {}).get("repaired", false):
			var petalo = get_tree().get_first_node_in_group("robots")
			# Check all robots for Petalo
			for bot in get_tree().get_nodes_in_group("robots"):
				if bot is PetaloRobot and bot.current_state != RobotBase.State.OFFLINE:
					var dist = global_position.distance_to(bot.global_position)
					if dist < 12.0:
						reveal_node()
						break
			# Also check player proximity if Petalo is active companion
			if GameState.active_companion == "PETALO" and GameState.player_ref:
				if global_position.distance_to(GameState.player_ref.global_position) < 10.0:
					reveal_node()

func reveal_node() -> void:
	if is_revealed:
		return
	is_revealed = true
	visible = true
	_update_visuals()
	
	if interactable:
		interactable.is_active = not is_active
	
	AudioSynth.play_robot_chirp(950.0)
	if beam_light:
		beam_light.light_energy = 4.5
		var tw = create_tween()
		tw.tween_property(beam_light, "light_energy", 1.8, 1.0)
	
	GameState.show_dialogue("Petalo", "Hidden optical frequency locked! Optical node revealed: " + node_identifier)

func activate_optical_switch() -> void:
	reveal_node()
	if not is_active:
		activate_node()

func activate_node() -> void:
	if is_active:
		return
	is_active = true
	is_revealed = true
	visible = true
	if interactable:
		interactable.is_active = false
	AudioSynth.play_repair_success()
	_update_visuals()
	node_activated.emit(self)

func _update_visuals() -> void:
	var mat = StandardMaterial3D.new()
	if is_active:
		mat.albedo_color = light_color
		mat.emission_enabled = true
		mat.emission = light_color
		mat.emission_energy_multiplier = 4.5
		if beam_light:
			beam_light.light_color = light_color
			beam_light.light_energy = 3.5
	else:
		mat.albedo_color = Color(0.2, 0.3, 0.38)
		mat.emission_enabled = true
		mat.emission = Color(0.2, 0.6, 0.8)
		mat.emission_energy_multiplier = 1.0
		if beam_light:
			beam_light.light_color = Color(0.2, 0.6, 0.8)
			beam_light.light_energy = 1.2
	if core_mesh:
		core_mesh.material_override = mat

func _on_interacted(interactor: Node) -> void:
	activate_node()
