class_name Player
extends CharacterBody3D

# 3D Third-Person Character Controller for RoboVerse: The Last Signal

signal health_changed(current: float, max_health: float)

@export var max_health: float = 100.0
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var jump_velocity: float = 5.5
@export var rotation_speed: float = 24.0
@export var gravity: float = 14.0

@onready var visual_root: Node3D = $VisualRoot
@onready var interact_ray: RayCast3D = $InteractRay
@onready var interact_area: Area3D = $InteractArea

var camera_controller: Node3D = null
var current_interactable: Interactable = null
var nearby_interactables: Array[Interactable] = []

var current_health: float = 100.0
var invulnerability_timer: float = 0.0
var is_sprinting: bool = false
var step_timer: float = 0.0

func _ready() -> void:
	GameState.player_ref = self
	if interact_area:
		interact_area.area_entered.connect(_on_interact_area_entered)
		interact_area.area_exited.connect(_on_interact_area_exited)

func set_camera_controller(cam: Node3D) -> void:
	camera_controller = cam

func _process(delta: float) -> void:
	_update_current_interactable()

func _physics_process(delta: float) -> void:
	# Handle Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		AudioSynth.play_ui_click(0.8)

	# Handle Sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else walk_speed

	# Handle WASD input relative to Camera Direction
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var move_direction = Vector3.ZERO
	if camera_controller and camera_controller.has_method("get_camera_forward"):
		var cam_fwd: Vector3 = camera_controller.get_camera_forward()
		var cam_right: Vector3 = camera_controller.get_camera_right()
		move_direction = (cam_fwd * -input_vector.y + cam_right * input_vector.x).normalized()
	else:
		move_direction = Vector3(input_vector.x, 0, input_vector.y).normalized()

	# Orient player to face movement direction when moving
	if move_direction.length_squared() > 0.01:
		var target_angle = atan2(-move_direction.x, -move_direction.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, delta * rotation_speed)
		if interact_ray:
			interact_ray.rotation.y = visual_root.rotation.y

		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed

		# Footstep audio timing
		if is_on_floor():
			step_timer += delta * (1.6 if is_sprinting else 1.0)
			if step_timer > 0.38:
				step_timer = 0.0
				AudioSynth.play_footstep()
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0, current_speed * 10.0 * delta)
		step_timer = 0.0

	move_and_slide()

	# Handle invulnerability timer
	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta

	# Downfall Detection: if player falls off platforms into void
	if global_position.y < -7.0:
		handle_downfall()

	# Handle Interaction Input [E]
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.execute_interaction(self)

	# Handle Universal Companion Command Input [Q]
	if Input.is_action_just_pressed("command_robot"):
		command_character(GameState.active_companion)

	# Handle ActionMap Companion Commands
	if Input.is_action_just_pressed("command_petalo"):
		command_character("PETALO")
	elif Input.is_action_just_pressed("command_quacky"):
		command_character("QUACKY")
	elif Input.is_action_just_pressed("command_tolly"):
		command_character("TOLLY")
	elif Input.is_action_just_pressed("command_tiko"):
		command_character("TIKO")

	# Handle Respawn Input [TAB]
	if Input.is_action_just_pressed("respawn"):
		respawn_to_entrance()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	# Dedicated Key for Petalo: [1], [Z], or [Numpad 1]
	if event.keycode == KEY_1 or event.physical_keycode == KEY_1 or event.keycode == KEY_Z or event.physical_keycode == KEY_Z or event.keycode == KEY_KP_1 or event.physical_keycode == KEY_KP_1:
		command_character("PETALO")
		get_viewport().set_input_as_handled()

	# Dedicated Key for Quacky: [2], [X], or [Numpad 2]
	elif event.keycode == KEY_2 or event.physical_keycode == KEY_2 or event.keycode == KEY_X or event.physical_keycode == KEY_X or event.keycode == KEY_KP_2 or event.physical_keycode == KEY_KP_2:
		command_character("QUACKY")
		get_viewport().set_input_as_handled()

	# Dedicated Key for Tolly: [3], [C], or [Numpad 3]
	elif event.keycode == KEY_3 or event.physical_keycode == KEY_3 or event.keycode == KEY_C or event.physical_keycode == KEY_C or event.keycode == KEY_KP_3 or event.physical_keycode == KEY_KP_3:
		command_character("TOLLY")
		get_viewport().set_input_as_handled()

	# Dedicated Key for Tiko: [4], [V], or [Numpad 4]
	elif event.keycode == KEY_4 or event.physical_keycode == KEY_4 or event.keycode == KEY_V or event.physical_keycode == KEY_V or event.keycode == KEY_KP_4 or event.physical_keycode == KEY_KP_4:
		command_character("TIKO")
		get_viewport().set_input_as_handled()

func command_character(robot_id: String) -> void:
	if not GameState.robots.has(robot_id):
		return

	var rdata = GameState.robots[robot_id]
	var rname = rdata.get("name", robot_id)

	if not rdata.get("repaired", false):
		AudioSynth.play_airlock_denied()
		GameState.show_dialogue("Squad Comm", "%s is OFFLINE! Locate and repair unit first." % rname, 2.0)
		return

	# Switch active companion to this robot so HUD & radar update
	GameState.switch_active_companion(robot_id)

	# Calculate targeted 3D coordinate from crosshair reticle or in front of player
	var target_pos = global_position + visual_root.global_transform.basis.z * -4.0
	var targeted_interactable: Interactable = null

	if camera_controller and camera_controller.has_method("get_aim_target"):
		var hit = camera_controller.get_aim_target(40.0)
		if hit.has("position"):
			target_pos = hit["position"]
			if hit.has("collider"):
				var col = hit["collider"]
				if col is Interactable and col.is_active:
					targeted_interactable = col
					target_pos = col.global_position
				elif col and col.get_parent() and col.get_parent() is Interactable and col.get_parent().is_active:
					targeted_interactable = col.get_parent()
					target_pos = targeted_interactable.global_position
	elif current_interactable:
		target_pos = current_interactable.global_position
		targeted_interactable = current_interactable

	if targeted_interactable:
		current_interactable = targeted_interactable

	# 1. Directly find companion and bring them to player and activate power
	var found_robot: RobotBase = null
	for bot in get_tree().get_nodes_in_group("robots"):
		if bot is RobotBase and bot.robot_id == robot_id:
			found_robot = bot
			break

	# If companion is repaired but not yet present in the current scene tree, spawn immediately
	if not found_robot and rdata.get("repaired", false):
		var bot_scene_path = {
			"PETALO": "res://scenes/robots/Petalo.tscn",
			"QUACKY": "res://scenes/robots/Quacky.tscn",
			"TOLLY": "res://scenes/robots/Tolly.tscn",
			"TIKO": "res://scenes/robots/Tiko.tscn"
		}.get(robot_id, "")
		if bot_scene_path != "":
			var scn = load(bot_scene_path)
			if scn:
				found_robot = scn.instantiate()
				var parent_node = get_parent() if get_parent() else self
				parent_node.add_child(found_robot)
				found_robot.global_position = global_position + Vector3(-1.5, 0, 1.5)
				found_robot.set_state(RobotBase.State.FOLLOWING)

	if found_robot:
		var p_forward = -visual_root.global_transform.basis.z if visual_root else Vector3.FORWARD
		found_robot.bring_to_player_and_activate(global_position, p_forward, target_pos)

	# 2. Emit command signal for all systems
	GameState.robot_command_requested.emit(robot_id, target_pos)

	var sound_pitch = 650.0 + ["PETALO", "QUACKY", "TOLLY", "TIKO"].find(robot_id) * 90.0
	AudioSynth.play_robot_chirp(sound_pitch)

	var action_desc = {
		"PETALO": "Optical Beacon deployed! Revealing hidden nodes & sensors.",
		"QUACKY": "Scout / Retrieval deployed! Navigating maintenance ducts.",
		"TOLLY": "Access Decryption deployed! Hacking electronic blast gates.",
		"TIKO": "Hydraulic Power deployed! Clearing heavy server racks / bridges."
	}.get(robot_id, "Command dispatched!")

	GameState.show_dialogue(rname, action_desc, 2.2)

func take_damage(amount: float, source_name: String = "Hazard") -> void:
	if invulnerability_timer > 0.0:
		return
	invulnerability_timer = 0.8
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	AudioSynth.play_hazard_zap()
	
	if current_health <= 0.0:
		handle_defeat()
	else:
		GameState.show_dialogue("Suit Diagnostic", "WARNING: Suit integrity compromised (-%d HP). Current: %d/%d" % [int(amount), int(current_health), int(max_health)], 2.5)

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)

func handle_defeat() -> void:
	AudioSynth.play_spark()
	GameState.show_dialogue("Emergency System", "CRITICAL SUIT DAMAGE: Emergency life-support recall to facility entrance engaged!")
	respawn_to_entrance()

func handle_downfall() -> void:
	AudioSynth.play_hazard_zap()
	GameState.show_dialogue("Grav-Recall", "Downfall detected! Teleporting explorer back to starting point...")
	respawn_to_entrance()

func respawn_to_entrance() -> void:
	global_position = Vector3(0, 1.0, 14.0)
	velocity = Vector3.ZERO
	current_health = max_health
	health_changed.emit(current_health, max_health)
	AudioSynth.play_ui_click(1.6)
	GameState.show_dialogue("System", "Explorer & companion units respawned at entrance. Health: 100/100.")
	
	# Teleport nearby companions to player
	for robot in get_tree().get_nodes_in_group("robots"):
		if is_instance_valid(robot):
			robot.global_position = global_position + Vector3(randf_range(-1.5, 1.5), 0, randf_range(1.5, 2.5))
			robot.velocity = Vector3.ZERO

func _update_current_interactable() -> void:
	var candidate: Interactable = null
	
	# 1. First check reticle aim from camera within reasonable interaction reach (6.5m)
	if camera_controller and camera_controller.has_method("get_aim_target"):
		var hit = camera_controller.get_aim_target(8.0)
		if hit.has("collider"):
			var col = hit["collider"]
			if col is Interactable and col.is_active:
				if global_position.distance_to(col.global_position) <= 6.5:
					candidate = col
			elif col and col.get_parent() and col.get_parent() is Interactable and col.get_parent().is_active:
				if global_position.distance_to(col.get_parent().global_position) <= 6.5:
					candidate = col.get_parent()
			elif col and col.has_node("Interactable"):
				var c_inter = col.get_node("Interactable")
				if c_inter is Interactable and c_inter.is_active:
					if global_position.distance_to(c_inter.global_position) <= 6.5:
						candidate = c_inter

	# 2. Check raycast in front of player
	if not candidate and interact_ray and interact_ray.is_colliding():
		var col = interact_ray.get_collider()
		if col is Interactable and col.is_active:
			candidate = col
		elif col and col.get_parent() and col.get_parent() is Interactable and col.get_parent().is_active:
			candidate = col.get_parent()
		elif col and col.has_node("Interactable"):
			var c_inter = col.get_node("Interactable")
			if c_inter is Interactable and c_inter.is_active:
				candidate = c_inter

	# 3. If raycast didn't hit, check proximity list
	if not candidate and nearby_interactables.size() > 0:
		for item in nearby_interactables:
			if is_instance_valid(item) and item.is_active:
				candidate = item
				break

	if candidate != current_interactable:
		if current_interactable and is_instance_valid(current_interactable):
			current_interactable.set_highlight(false)
		current_interactable = candidate
		if current_interactable:
			current_interactable.set_highlight(true)

func _issue_robot_command() -> void:
	command_character(GameState.active_companion)

func _on_interact_area_entered(area: Area3D) -> void:
	if area is Interactable and not nearby_interactables.has(area):
		nearby_interactables.append(area)

func _on_interact_area_exited(area: Area3D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)
