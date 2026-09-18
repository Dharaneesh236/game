class_name PetaloRobot
extends RobotBase

# Petalo: Light & Signalling Robot
# Emits bright light, reveals hidden signal nodes, activates photosensitive sensors

@onready var beacon_light: SpotLight3D = $VisualRoot/BeaconLight
@onready var high_omni: OmniLight3D = $VisualRoot/HighOmni
@onready var reveal_area: Area3D = $VisualRoot/RevealArea

var is_signalling: bool = false

func _ready() -> void:
	robot_id = "PETALO"
	robot_name = "Petalo"
	super._ready()

func perform_special_ability() -> void:
	AudioSynth.play_robot_chirp(950.0)
	is_signalling = true
	if beacon_light:
		beacon_light.visible = true
		beacon_light.light_energy = 8.0
		beacon_light.spot_range = 45.0
	if high_omni:
		high_omni.visible = true
		high_omni.light_energy = 7.0
		high_omni.omni_range = 35.0

	# 1. Direct scan for all signal nodes within broad illumination range (60 meters)
	var revealed_any = false
	for node in get_tree().get_nodes_in_group("signal_nodes"):
		if node is SignalNode:
			var dist = global_position.distance_to(node.global_position)
			if dist < 60.0:
				if not node.is_revealed:
					node.reveal_node()
					revealed_any = true
				if not node.is_active:
					node.activate_optical_switch()
					revealed_any = true

	# 2. Check all optical & electric barriers in facility to bypass/deactivate them
	for bar in get_tree().get_nodes_in_group("optical_barriers"):
		if bar.has_method("bypass_barrier"):
			bar.bypass_barrier()
			revealed_any = true
		elif bar.has_method("deactivate_barrier"):
			bar.deactivate_barrier()
			revealed_any = true

	for bar in get_tree().get_nodes_in_group("electric_barriers"):
		if bar.has_method("deactivate_barrier") and bar.is_active:
			bar.deactivate_barrier()
			revealed_any = true

	# 3. Check overlapping areas for optical barriers or interactables
	if reveal_area:
		for area in reveal_area.get_overlapping_areas():
			var target = area
			if not target.has_method("reveal_node") and area.get_parent() and area.get_parent().has_method("reveal_node"):
				target = area.get_parent()
			if target.has_method("reveal_node"):
				target.reveal_node()
				revealed_any = true
			if target.has_method("activate_optical_switch"):
				target.activate_optical_switch()
				revealed_any = true
			if target.has_method("bypass_barrier"):
				target.bypass_barrier()
				revealed_any = true
			if target.has_method("deactivate_barrier"):
				target.deactivate_barrier()
				revealed_any = true

	AudioSynth.play_repair_success()
	GameState.show_dialogue("Petalo", "Optical beam synchronized! Hidden node frequencies unlocked & barriers bypassed.")

	await get_tree().create_timer(1.8).timeout
	
	if beacon_light:
		beacon_light.visible = false
	if high_omni:
		high_omni.light_energy = 3.0
	is_signalling = false
	set_state(State.FOLLOWING)

func _process(delta: float) -> void:
	# Subtle hover bobbing animation for Petalo
	if current_state != State.OFFLINE and visual_root:
		visual_root.position.y = 0.6 + sin(Time.get_ticks_msec() * 0.004) * 0.08
