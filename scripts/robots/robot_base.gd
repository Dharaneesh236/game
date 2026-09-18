class_name RobotBase
extends CharacterBody3D

# Base Companion Robot for RoboVerse: The Last Signal

enum State {
	OFFLINE,
	FOLLOWING,
	COMMANDED,
	PERFORMING_ACTION,
	RETURNING
}

@export var robot_id: String = "PETALO"
@export var robot_name: String = "Petalo"
@export var follow_distance: float = 2.6
@export var move_speed: float = 4.8
@export var rotation_speed: float = 8.0

@onready var visual_root: Node3D = $VisualRoot
@onready var status_light: OmniLight3D = $VisualRoot/StatusLight
@onready var spark_timer: Timer = $SparkTimer

var current_state: State = State.OFFLINE
var command_target_pos: Vector3 = Vector3.ZERO
var target_action_callback: Callable
var gravity: float = 12.0
var command_timer: float = 0.0

func _ready() -> void:
	add_to_group("robots")
	GameState.robot_command_requested.connect(_on_command_requested)
	GameState.robot_repaired.connect(_on_robot_repaired)
	
	if GameState.robots.has(robot_id) and GameState.robots[robot_id]["repaired"]:
		set_state(State.FOLLOWING)
		var interact = get_node_or_null("Interactable")
		if interact:
			interact.is_active = false
	else:
		set_state(State.OFFLINE)

	if spark_timer:
		spark_timer.timeout.connect(_on_spark_timeout)

func set_state(new_state: State) -> void:
	current_state = new_state
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree():
		return
	if current_state == State.OFFLINE:
		if status_light:
			status_light.light_color = Color(0.9, 0.2, 0.1) # Red warning
			status_light.light_energy = 0.5
		if spark_timer and not spark_timer.is_stopped():
			spark_timer.start(randf_range(1.5, 3.5))
	else:
		if status_light:
			var active_col = GameState.robots.get(robot_id, {}).get("color", Color(0.2, 0.9, 1.0))
			status_light.light_color = active_col
			status_light.light_energy = 2.0
		if spark_timer:
			spark_timer.stop()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.OFFLINE:
			velocity.x = move_toward(velocity.x, 0, delta * 10.0)
			velocity.z = move_toward(velocity.z, 0, delta * 10.0)

		State.FOLLOWING:
			_process_following(delta)

		State.COMMANDED:
			_process_commanded(delta)

		State.RETURNING:
			_process_returning(delta)

		State.PERFORMING_ACTION:
			velocity.x = 0
			velocity.z = 0

	move_and_slide()

func _process_following(delta: float) -> void:
	var player = GameState.player_ref
	if not is_instance_valid(player):
		return

	var to_player = player.global_position - global_position
	to_player.y = 0
	var dist = to_player.length()

	if dist > follow_distance:
		var dir = to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		var target_angle = atan2(-dir.x, -dir.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, delta * rotation_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * 15.0)
		velocity.z = move_toward(velocity.z, 0, delta * 15.0)

func _process_commanded(delta: float) -> void:
	command_timer += delta
	var to_target = command_target_pos - global_position
	to_target.y = 0
	var dist = to_target.length()

	if dist > 2.5 and command_timer < 1.4:
		var dir = to_target.normalized()
		velocity.x = dir.x * (move_speed * 1.3)
		velocity.z = dir.z * (move_speed * 1.3)
		var target_angle = atan2(-dir.x, -dir.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, delta * rotation_speed)
	else:
		velocity.x = 0
		velocity.z = 0
		command_timer = 0.0
		set_state(State.PERFORMING_ACTION)
		perform_special_ability()

func _process_returning(delta: float) -> void:
	var player = GameState.player_ref
	if not is_instance_valid(player):
		set_state(State.FOLLOWING)
		return

	var to_player = player.global_position - global_position
	to_player.y = 0
	if to_player.length() <= follow_distance:
		set_state(State.FOLLOWING)
	else:
		var dir = to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, atan2(-dir.x, -dir.z), delta * rotation_speed)

func bring_to_player_and_activate(player_pos: Vector3, player_forward: Vector3, target_pos: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.OFFLINE:
		repair_robot()

	# Calculate offset beside explorer (custom flank position per robot)
	var side_vec = player_forward.cross(Vector3.UP).normalized()
	var side_mult = 1.6
	if robot_id == "QUACKY":
		side_mult = -1.6
	elif robot_id == "TOLLY":
		side_mult = 2.4
	elif robot_id == "TIKO":
		side_mult = -2.4

	var arrive_pos = player_pos + side_vec * side_mult + player_forward * 1.0
	arrive_pos.y = player_pos.y

	# Always bring companion directly to player's flank
	global_position = arrive_pos
	velocity = Vector3.ZERO

	# Turn visual orientation toward target or explorer facing
	var look_dir = player_forward
	if target_pos != Vector3.ZERO and target_pos.distance_to(global_position) > 0.5:
		look_dir = (target_pos - global_position).normalized()
		look_dir.y = 0
	if look_dir.length_squared() > 0.01:
		visual_root.rotation.y = atan2(-look_dir.x, -look_dir.z)

	AudioSynth.play_robot_chirp(850.0)
	set_state(State.PERFORMING_ACTION)
	perform_special_ability()

func perform_special_ability() -> void:
	# Overridden in specific robot scripts
	await get_tree().create_timer(1.0).timeout
	set_state(State.FOLLOWING)

func repair_robot() -> void:
	GameState.mark_robot_repaired(robot_id)
	set_state(State.FOLLOWING)

func _on_command_requested(target_robot: String, target_pos: Vector3) -> void:
	if target_robot.to_upper() == robot_id.to_upper():
		if current_state == State.PERFORMING_ACTION:
			return
		var player = GameState.player_ref
		if is_instance_valid(player):
			var pf = -player.visual_root.global_transform.basis.z if player.visual_root else Vector3.FORWARD
			bring_to_player_and_activate(player.global_position, pf, target_pos)
		else:
			command_target_pos = target_pos
			command_timer = 0.0
			set_state(State.PERFORMING_ACTION)
			perform_special_ability()

func _on_robot_repaired(target_name: String) -> void:
	if target_name.to_upper() == robot_id.to_upper():
		set_state(State.FOLLOWING)

func _on_spark_timeout() -> void:
	if current_state == State.OFFLINE:
		AudioSynth.play_spark()
		if spark_timer:
			spark_timer.start(randf_range(2.0, 4.5))
