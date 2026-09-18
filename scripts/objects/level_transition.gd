class_name LevelTransition
extends Area3D

# Facility Level Transition Trigger with Strict Sequential Progression

@export var target_building: int = 1
@export var is_active: bool = false
@export var prompt_message: String = "Proceed to Next Building"

var has_triggered: bool = false
var last_denied_time: float = -10.0

@onready var pad_mesh: MeshInstance3D = get_node_or_null("PortalPad")
@onready var portal_light: OmniLight3D = get_node_or_null("PortalLight")

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_update_visuals()

func _update_visuals() -> void:
	if is_active:
		if pad_mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.0, 0.95, 1.0, 0.8)
			mat.emission_enabled = true
			mat.emission = Color(0.0, 1.0, 0.8)
			mat.emission_energy_multiplier = 3.5
			pad_mesh.material_override = mat
		if portal_light:
			portal_light.light_color = Color(0.0, 1.0, 0.85)
			portal_light.light_energy = 3.5
	else:
		if pad_mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.9, 0.1, 0.1, 0.6)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.15, 0.15)
			mat.emission_energy_multiplier = 2.0
			pad_mesh.material_override = mat
		if portal_light:
			portal_light.light_color = Color(1.0, 0.2, 0.2)
			portal_light.light_energy = 2.0

func activate_transition() -> void:
	if is_active:
		return
	is_active = true
	_update_visuals()
	AudioSynth.play_airlock_unlocked()

	# Pulse effect on unlock
	if portal_light:
		var tw = create_tween()
		tw.tween_property(portal_light, "light_energy", 6.0, 0.4)
		tw.tween_property(portal_light, "light_energy", 3.5, 0.6)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if not is_active:
		# Deny access with auditory warning, feedback dialogue, and gentle pushback
		var now = Time.get_ticks_msec() / 1000.0
		if now - last_denied_time > 1.5:
			last_denied_time = now
			AudioSynth.play_airlock_denied()
			
			var parent = get_parent()
			var reason = "Complete all facility mission objectives first!"
			if parent and parent.has_method("get_mission_status_text"):
				reason = parent.get_mission_status_text()
			
			GameState.show_dialogue("Facility Air-Lock", "AIR-LOCK LOCKED: " + reason)

		# Repel player backward so they cannot walk through locked gate
		if body is CharacterBody3D:
			var push_dir = (body.global_position - global_position)
			push_dir.y = 0
			if push_dir.length_squared() < 0.05:
				push_dir = Vector3(0, 0, 1)
			else:
				push_dir = push_dir.normalized()
			body.global_position += push_dir * 1.8
		return

	if has_triggered:
		return

	has_triggered = true
	AudioSynth.play_gate()
	AudioSynth.play_repair_success()

	# Mark current facility index completed
	var current_idx = target_building - 1
	GameState.mark_facility_completed(current_idx)

	var b_name = "Knowledge Centre"
	match target_building:
		1: b_name = "Knowledge Centre"
		2: b_name = "Coding & AI Hub"
		3: b_name = "Innovation Tower"
		4: b_name = "Testing Arena"

	GameState.show_dialogue("Facility Air-Lock", "Access Granted. Entering " + b_name + "...")
	await get_tree().create_timer(0.6).timeout
	GameState.change_building(target_building)
