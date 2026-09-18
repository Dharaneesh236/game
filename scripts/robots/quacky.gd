class_name QuackyRobot
extends RobotBase

# Quacky: Scout & Delivery Robot
# Navigates narrow maintenance ducts, retrieves small energy modules, reports hazards

@onready var carrying_slot: Node3D = $VisualRoot/CarryingSlot

var is_carrying_item: bool = false
var carried_item_name: String = ""

func _ready() -> void:
	robot_id = "QUACKY"
	robot_name = "Quacky"
	follow_distance = 1.8
	move_speed = 5.2
	super._ready()

func perform_special_ability() -> void:
	AudioSynth.play_robot_chirp(1100.0)
	
	if status_light:
		status_light.light_energy = 5.0
		status_light.light_color = Color(1.0, 0.85, 0.2)

	var action_done = false
	var parent_b = get_parent()
	
	# 1. Delivery Check: If already carrying module, deliver to AI Mainframe
	if is_carrying_item:
		for hub in get_tree().get_nodes_in_group("coding_hub"):
			if hub.has_node("AIMainframe") and hub.has_method("_on_ai_terminal_interacted"):
				hub._on_ai_terminal_interacted(self)
				action_done = true
				break
		if not action_done and parent_b and parent_b.has_node("AIMainframe") and parent_b.has_method("_on_ai_terminal_interacted"):
			parent_b._on_ai_terminal_interacted(self)
			action_done = true

	# 2. Retrieval Check: If not carrying module, retrieve from Maintenance Duct
	if not action_done and not is_carrying_item:
		for hub in get_tree().get_nodes_in_group("coding_hub"):
			if hub.has_method("retrieve_module") and not hub.module_retrieved:
				hub.retrieve_module()
				action_done = true
				break
				
		if not action_done and parent_b and parent_b.has_method("retrieve_module"):
			if not parent_b.module_retrieved:
				parent_b.retrieve_module()
				action_done = true

	# 3. Area shape query for any local interactable ducts or objects
	if not action_done:
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
			if not target.has_method("retrieve_module") and collider.get_parent() and collider.get_parent().has_method("retrieve_module"):
				target = collider.get_parent()
			if target.has_method("retrieve_module"):
				target.retrieve_module()
				action_done = true
				break

	# Visual quick scout thrust forward and back
	if visual_root:
		var tw = create_tween()
		tw.tween_property(visual_root, "position:z", -1.2, 0.2)
		tw.tween_property(visual_root, "position:z", 0.0, 0.3)

	await get_tree().create_timer(1.2).timeout
	if status_light:
		status_light.light_energy = 2.0

	if is_carrying_item:
		AudioSynth.play_repair_success()
		GameState.show_dialogue("Quacky", "AI Core secured! Press [2] (or [X]) or approach mainframe to deliver.")
	elif action_done:
		AudioSynth.play_repair_success()
		GameState.show_dialogue("Quacky", "Core delivery complete! Mainframe online.")
	else:
		AudioSynth.play_ui_click(1.4)
		GameState.show_dialogue("Quacky", "High-speed Scout Thruster engaged! Sector surveyed, ready for delivery.")
	set_state(State.FOLLOWING)

func attach_carried_module(item_name: String) -> void:
	is_carrying_item = true
	carried_item_name = item_name
	if carrying_slot:
		carrying_slot.visible = true
	AudioSynth.play_ui_click(1.5)

func deliver_item() -> String:
	if is_carrying_item:
		var item = carried_item_name
		is_carrying_item = false
		carried_item_name = ""
		if carrying_slot:
			carrying_slot.visible = false
		return item
	return ""
