class_name TollyRobot
extends RobotBase

# Tolly: Access & Gate Robot
# Controls security terminals, overrides electronic lockouts, opens puzzle barriers

@onready var hack_emitter: OmniLight3D = $VisualRoot/HackEmitter

func _ready() -> void:
	robot_id = "TOLLY"
	robot_name = "Tolly"
	follow_distance = 2.5
	move_speed = 4.6
	super._ready()

func perform_special_ability() -> void:
	AudioSynth.play_robot_chirp(680.0)
	AudioSynth.play_spark()
	
	if hack_emitter:
		hack_emitter.visible = true
		hack_emitter.light_energy = 7.0
		hack_emitter.omni_range = 35.0
		hack_emitter.light_color = Color(0.9, 0.2, 0.95)

	var unlocked_any = false

	# 1. Direct space state query
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 16.0
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = 2
	query.collide_with_areas = true
	var results = space_state.intersect_shape(query)

	for res in results:
		var collider = res.collider
		var target = collider
		if not target.has_method("unlock_gate") and collider.get_parent() and collider.get_parent().has_method("unlock_gate"):
			target = collider.get_parent()
		if target.has_method("unlock_gate"):
			target.unlock_gate()
			unlocked_any = true
		elif target.has_method("override_security"):
			target.override_security()
			unlocked_any = true

	# 2. Check all security gates in group across facility (within 60m)
	for gate in get_tree().get_nodes_in_group("security_gates"):
		if gate is SecurityGate and gate.is_locked:
			var d_tolly = global_position.distance_to(gate.global_position)
			var d_player = 999.0
			if GameState.player_ref:
				d_player = GameState.player_ref.global_position.distance_to(gate.global_position)
			if d_tolly < 60.0 or d_player < 60.0:
				gate.unlock_gate()
				unlocked_any = true

	# 3. Check Innovation Tower for upper_security_gate
	for tower in get_tree().get_nodes_in_group("innovation_tower"):
		var upper_gate = tower.get_node_or_null("UpperSecurityGate")
		if upper_gate is SecurityGate and upper_gate.is_locked:
			upper_gate.unlock_gate()
			unlocked_any = true

	if not unlocked_any and get_parent():
		var upper_gate = get_parent().get_node_or_null("UpperSecurityGate")
		if upper_gate is SecurityGate and upper_gate.is_locked:
			upper_gate.unlock_gate()
			unlocked_any = true

	await get_tree().create_timer(1.2).timeout

	if hack_emitter:
		hack_emitter.visible = false
	AudioSynth.play_repair_success()
	if unlocked_any:
		GameState.show_dialogue("Tolly", "Security override successful! Biometric barriers and gates opened.")
	else:
		GameState.show_dialogue("Tolly", "EMP Decryption Wave deployed! Security frequencies cleared.")
	set_state(State.FOLLOWING)
