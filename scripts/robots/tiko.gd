class_name TikoRobot
extends RobotBase

# Tiko: Heavy Physical Manipulation Robot
# Pushes heavy objects, lifts barriers, aligns mechanical bridge catwalks

@onready var arm_left: Node3D = get_node_or_null("VisualRoot/ProngLeft")
@onready var arm_right: Node3D = get_node_or_null("VisualRoot/ProngRight")

func _ready() -> void:
	robot_id = "TIKO"
	robot_name = "Tiko"
	follow_distance = 3.0
	move_speed = 4.2
	super._ready()

func perform_special_ability() -> void:
	AudioSynth.play_robot_chirp(420.0)
	AudioSynth.play_hazard_zap()
	GameState.shake_camera(0.25, 0.5)

	var action_performed = false

	# 1. Knowledge Centre Server Obstacle Check
	for b in get_tree().get_nodes_in_group("knowledge_centre"):
		if b.has_method("apply_heavy_push") and not b.obstacle_cleared:
			b.apply_heavy_push()
			action_performed = true
			break

	if not action_performed and get_parent() and get_parent().has_method("apply_heavy_push"):
		if not get_parent().obstacle_cleared:
			get_parent().apply_heavy_push()
			action_performed = true

	# 2. Innovation Tower Catwalk Bridge Check
	for tower in get_tree().get_nodes_in_group("innovation_tower"):
		if tower.has_method("align_bridge") and not tower.bridge_aligned:
			tower.align_bridge()
			action_performed = true
			break

	if not action_performed and get_parent() and get_parent().has_method("align_bridge"):
		if not get_parent().bridge_aligned:
			get_parent().align_bridge()
			action_performed = true

	# 3. Direct space state query
	if not action_performed:
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
			if not target.has_method("apply_heavy_push") and collider.get_parent() and collider.get_parent().has_method("apply_heavy_push"):
				target = collider.get_parent()
			if target.has_method("apply_heavy_push"):
				target.apply_heavy_push()
				action_performed = true
				break
			
			if not target.has_method("align_bridge") and collider.get_parent() and collider.get_parent().has_method("align_bridge"):
				target = collider.get_parent()
			if target.has_method("align_bridge"):
				target.align_bridge()
				action_performed = true
				break

	# Mechanical hydraulic ram arm extension
	if arm_left and arm_right:
		arm_left.position.z -= 0.6
		arm_right.position.z -= 0.6

	await get_tree().create_timer(1.2).timeout

	if arm_left and arm_right:
		arm_left.position.z += 0.6
		arm_right.position.z += 0.6

	AudioSynth.play_repair_success()
	if action_performed:
		GameState.show_dialogue("Tiko", "Obstruction cleared! Path and structural connections are secured.")
	else:
		GameState.show_dialogue("Tiko", "2000kN Hydraulic Ram engaged! Ready for heavy physical manipulation.")
	set_state(State.FOLLOWING)
