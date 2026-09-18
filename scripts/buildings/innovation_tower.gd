class_name InnovationTower
extends Node3D

# Building 4: Innovation Tower Controller with Strict Mission Verification & Bidirectional Elevator

@onready var tolly: TollyRobot = $Tolly
@onready var elevator: AnimatableBody3D = $ElevatorPlatform
@onready var elevator_interact: Interactable = $ElevatorPlatform/Interactable
@onready var ground_call_interact: Interactable = get_node_or_null("GroundCallTerminal/Interactable")
@onready var upper_call_interact: Interactable = get_node_or_null("UpperCallTerminal/Interactable")
@onready var ground_status_light: OmniLight3D = get_node_or_null("GroundCallTerminal/StatusLight")
@onready var upper_status_light: OmniLight3D = get_node_or_null("UpperCallTerminal/StatusLight")

@onready var bridge_section: AnimatableBody3D = $CatwalkBridge
@onready var bridge_interact: Interactable = $CatwalkBridge/Interactable
@onready var upper_security_gate: SecurityGate = $UpperSecurityGate
@onready var transition_pad: LevelTransition = $LevelTransition

var elevator_target_y: float = 0.2
var elevator_speed: float = 2.8
var elevator_at_top: bool = false
var is_elevator_moving: bool = false
var has_ascended_elevator: bool = false
var bridge_aligned: bool = false
var mission_fulfilled: bool = false

func _ready() -> void:
	add_to_group("innovation_tower")
	GameState.set_objective("INNOVATION TOWER", "Find and repair Tolly (Access Robot).", 82.0)

	if elevator:
		elevator.sync_to_physics = false

	if tolly:
		var interact = tolly.get_node_or_null("Interactable")
		if interact:
			interact.interacted.connect(_on_tolly_repair_interacted)

	if elevator_interact:
		elevator_interact.interacted.connect(_on_elevator_platform_interacted)

	if ground_call_interact:
		ground_call_interact.interacted.connect(func(_interactor): call_elevator_down())

	if upper_call_interact:
		upper_call_interact.interacted.connect(func(_interactor): call_elevator_up())

	if bridge_interact:
		bridge_interact.interacted.connect(_on_bridge_interacted)

	if upper_security_gate:
		upper_security_gate.gate_opened.connect(_on_upper_gate_unlocked)

	_update_elevator_ui()

func _physics_process(delta: float) -> void:
	if elevator:
		var cur_y = elevator.position.y
		if abs(cur_y - elevator_target_y) > 0.02:
			is_elevator_moving = true
			elevator.position.y = move_toward(cur_y, elevator_target_y, elevator_speed * delta)
			_update_elevator_ui()
		elif is_elevator_moving:
			is_elevator_moving = false
			elevator.position.y = elevator_target_y
			_update_elevator_ui()
			AudioSynth.play_ui_click(1.2)
			if elevator_target_y >= 5.0:
				GameState.show_dialogue("Elevator", "Elevator docked at Upper Catwalk.")
				_check_sync_companions_to_upper_deck()
			else:
				GameState.show_dialogue("Elevator", "Elevator docked at Ground Level.")

func is_mission_complete() -> bool:
	var tolly_ok = GameState.robots["TOLLY"]["repaired"]
	var bridge_ok = bridge_aligned
	var gate_ok = (upper_security_gate != null and upper_security_gate.is_open)
	return tolly_ok and bridge_ok and gate_ok

func get_mission_status_text() -> String:
	var missing: Array[String] = []
	if not GameState.robots["TOLLY"]["repaired"]:
		missing.append("Repair Tolly")
	if not has_ascended_elevator and not elevator_at_top:
		missing.append("Ascend Elevator Platform")
	if not bridge_aligned:
		missing.append("Align Suspended Catwalk Bridge")
	if upper_security_gate and not upper_security_gate.is_open:
		missing.append("Hack Biometric Security Gate")
	
	if missing.is_empty():
		return "All objectives complete! Testing Arena access open."
	return "Remaining: " + ", ".join(missing)

func _check_and_unlock_facility() -> void:
	if mission_fulfilled:
		return
	if is_mission_complete():
		mission_fulfilled = true
		GameState.mark_facility_completed(3)
		GameState.set_objective("INNOVATION TOWER COMPLETE", "Facility 4 Complete! Walk into the Final Testing Arena.", 93.0)
		GameState.show_dialogue("System", "All four regional sectors synchronized! Final Signal Spire accessible.")
		AudioSynth.play_repair_success()
		if transition_pad:
			transition_pad.activate_transition()

func _on_tolly_repair_interacted(interactor: Node) -> void:
	if not GameState.robots["TOLLY"]["repaired"]:
		GameState.repair_minigame_requested.emit("TOLLY", func():
			tolly.repair_robot()
			GameState.set_objective("INNOVATION TOWER", "Ride elevator to upper catwalk. Use Tiko [4] for bridge and Tolly [3] for gate.", 86.0)
			GameState.show_dialogue("Tolly", "Security decryption online! Press [3] (or [C]) to bypass electronic gates.")
			_check_and_unlock_facility()
		)

func call_elevator_down() -> void:
	if elevator and elevator.position.y <= 0.25 and elevator_target_y <= 0.25:
		GameState.show_dialogue("Elevator", "Platform is already docked at Ground Level.")
		return

	elevator_target_y = 0.2
	elevator_at_top = false
	is_elevator_moving = true
	AudioSynth.play_gate()
	GameState.show_dialogue("Elevator", "Elevator descending to Ground Level...")
	_update_elevator_ui()

func call_elevator_up() -> void:
	if elevator and elevator.position.y >= 5.9 and elevator_target_y >= 5.9:
		GameState.show_dialogue("Elevator", "Platform is already docked at Upper Catwalk.")
		return

	elevator_target_y = 6.0
	elevator_at_top = true
	has_ascended_elevator = true
	is_elevator_moving = true
	AudioSynth.play_gate()
	GameState.show_dialogue("Elevator", "Elevator ascending to Upper Catwalk...")
	_update_elevator_ui()

func _on_elevator_platform_interacted(_interactor: Node) -> void:
	if is_elevator_moving:
		return
	if elevator and elevator.position.y >= 5.0:
		call_elevator_down()
	else:
		call_elevator_up()

# Backward compatibility alias for any existing callers
func _on_elevator_interacted(interactor: Node) -> void:
	_on_elevator_platform_interacted(interactor)

func _update_elevator_ui() -> void:
	if is_elevator_moving:
		if elevator_interact: elevator_interact.prompt_message = "Elevator in motion..."
		if ground_call_interact: ground_call_interact.prompt_message = "Elevator in motion..."
		if upper_call_interact: upper_call_interact.prompt_message = "Elevator in motion..."
		if ground_status_light:
			ground_status_light.light_color = Color(1.0, 0.7, 0.1)
			ground_status_light.light_energy = 2.5
		if upper_status_light:
			upper_status_light.light_color = Color(1.0, 0.7, 0.1)
			upper_status_light.light_energy = 2.5
	elif elevator_at_top or (elevator and elevator.position.y >= 5.0):
		if elevator_interact: elevator_interact.prompt_message = "[E] Descend to Ground Level"
		if ground_call_interact: ground_call_interact.prompt_message = "[E] Call Elevator Down"
		if upper_call_interact: upper_call_interact.prompt_message = "[E] Descend Elevator"
		if ground_status_light:
			ground_status_light.light_color = Color(1.0, 0.4, 0.1)
			ground_status_light.light_energy = 2.0
		if upper_status_light:
			upper_status_light.light_color = Color(0.1, 0.9, 1.0)
			upper_status_light.light_energy = 2.0
	else:
		if elevator_interact: elevator_interact.prompt_message = "[E] Ascend to Upper Catwalk"
		if ground_call_interact: ground_call_interact.prompt_message = "[E] Ascend Elevator"
		if upper_call_interact: upper_call_interact.prompt_message = "[E] Call Elevator Up"
		if ground_status_light:
			ground_status_light.light_color = Color(0.1, 0.9, 1.0)
			ground_status_light.light_energy = 2.0
		if upper_status_light:
			upper_status_light.light_color = Color(1.0, 0.4, 0.1)
			upper_status_light.light_energy = 2.0

func _check_sync_companions_to_upper_deck() -> void:
	var player = GameState.player_ref
	if not is_instance_valid(player) or player.global_position.y < 4.5:
		return
	var offset_idx = 0
	var offsets = [Vector3(-1.5, 0, 1.5), Vector3(1.5, 0, 1.5), Vector3(-2.2, 0, 2.5), Vector3(2.2, 0, 2.5)]
	for bot in get_tree().get_nodes_in_group("robots"):
		if is_instance_valid(bot) and bot is RobotBase and bot.current_state != RobotBase.State.OFFLINE:
			if bot.global_position.y < 4.0:
				bot.global_position = player.global_position + offsets[offset_idx % offsets.size()]
				bot.velocity = Vector3.ZERO
				offset_idx += 1

func _on_bridge_interacted(interactor: Node) -> void:
	if GameState.robots["TIKO"]["repaired"]:
		GameState.robot_command_requested.emit("TIKO", bridge_section.global_position)
		await get_tree().create_timer(1.2).timeout
		align_bridge()
	else:
		GameState.show_dialogue("Explorer", "The bridge actuator is jammed. Tiko can realign it.")

func align_bridge() -> void:
	if bridge_aligned:
		return
	bridge_aligned = true
	var tw = create_tween()
	tw.tween_property(bridge_section, "rotation_degrees:y", 0.0, 1.8)
	AudioSynth.play_gate()
	if bridge_interact:
		bridge_interact.is_active = false
	GameState.show_dialogue("Tiko", "Bridge hydraulic alignment complete. Upper walkway accessible.")
	GameState.set_objective("INNOVATION TOWER", "Command Tolly to hack the Biometric Security Gate.", 90.0)
	_check_and_unlock_facility()

func _on_upper_gate_unlocked() -> void:
	_check_and_unlock_facility()

