class_name KnowledgeCentre
extends Node3D

# Building 2: Knowledge Centre Controller with Strict Mission Verification

@onready var tiko: TikoRobot = $Tiko
@onready var heavy_obstacle: AnimatableBody3D = $HeavyServerObstacle
@onready var obstacle_interactable: Interactable = $HeavyServerObstacle/Interactable
@onready var node_a: SignalNode = $SignalNodeA
@onready var node_b: SignalNode = $SignalNodeB
@onready var node_c: SignalNode = $SignalNodeC
@onready var exit_gate: SecurityGate = $ExitGate
@onready var transition_pad: LevelTransition = $LevelTransition

var sequence_step: int = 0
var obstacle_cleared: bool = false
var mission_fulfilled: bool = false

func _ready() -> void:
	add_to_group("knowledge_centre")
	GameState.set_objective("KNOWLEDGE CENTRE", "Find and repair Tiko (Heavy Robot) to clear corridor.", 45.0)

	if tiko:
		var interact = tiko.get_node_or_null("Interactable")
		if interact:
			interact.interacted.connect(_on_tiko_repair_interacted)

	if obstacle_interactable:
		obstacle_interactable.interacted.connect(_on_obstacle_interacted)

	if node_a: node_a.node_activated.connect(func(_n): _check_node_step(1))
	if node_b: node_b.node_activated.connect(func(_n): _check_node_step(2))
	if node_c: node_c.node_activated.connect(func(_n): _check_node_step(3))

func is_mission_complete() -> bool:
	var tiko_ok = GameState.robots["TIKO"]["repaired"]
	var obst_ok = obstacle_cleared
	var seq_ok = (sequence_step == 3)
	return tiko_ok and obst_ok and seq_ok

func get_mission_status_text() -> String:
	var missing: Array[String] = []
	if not GameState.robots["TIKO"]["repaired"]:
		missing.append("Repair Tiko")
	if not obstacle_cleared:
		missing.append("Relocate Fallen Server Obstacle")
	if sequence_step < 3:
		missing.append("Align Nodes: Alpha -> Beta -> Gamma (%d/3)" % sequence_step)
	
	if missing.is_empty():
		return "All objectives complete! Exit gate is open."
	return "Remaining: " + ", ".join(missing)

func _check_and_unlock_facility() -> void:
	if mission_fulfilled:
		return
	if is_mission_complete():
		mission_fulfilled = true
		GameState.knowledge_centre_route_aligned = true
		GameState.mark_facility_completed(1)
		GameState.set_objective("KNOWLEDGE CENTRE RESTORED", "Facility 2 Complete! Route Restored 65%. Proceed to Coding Hub.", 65.0)
		GameState.show_dialogue("System", "SIGNAL ROUTE RESTORED — 65%. Central communication bridge online.")
		AudioSynth.play_repair_success()
		if exit_gate:
			exit_gate.is_locked = false
			exit_gate.open_gate()
		if transition_pad:
			transition_pad.activate_transition()

func _on_tiko_repair_interacted(interactor: Node) -> void:
	if not GameState.robots["TIKO"]["repaired"]:
		GameState.repair_minigame_requested.emit("TIKO", func():
			tiko.repair_robot()
			GameState.set_objective("KNOWLEDGE CENTRE", "Use Tiko [4] (or [V]) to clear the fallen heavy server rack.", 52.0)
			GameState.show_dialogue("Tiko", "Hydraulics operational. Press [4] (or [V]) to clear heavy physical obstructions.")
			_check_and_unlock_facility()
		)

func _on_obstacle_interacted(interactor: Node) -> void:
	if GameState.robots["TIKO"]["repaired"]:
		GameState.robot_command_requested.emit("TIKO", heavy_obstacle.global_position)
		await get_tree().create_timer(1.2).timeout
		apply_heavy_push()
	else:
		GameState.show_dialogue("Explorer", "This server unit is far too heavy to push alone. I need Tiko's strength.")

func apply_heavy_push() -> void:
	if obstacle_cleared:
		return
	obstacle_cleared = true
	var tw = create_tween()
	tw.tween_property(heavy_obstacle, "position:x", heavy_obstacle.position.x - 4.5, 1.8)
	AudioSynth.play_gate()
	if obstacle_interactable:
		obstacle_interactable.is_active = false
	GameState.show_dialogue("Tiko", "Server rack relocated. Data archive corridor is open.")
	GameState.set_objective("KNOWLEDGE CENTRE", "Connect the optical signal nodes: Alpha -> Beta -> Gamma.", 58.0)
	_check_and_unlock_facility()

func _check_node_step(step: int) -> void:
	if step == sequence_step + 1:
		sequence_step = step
		AudioSynth.play_ui_click(1.4)
		if sequence_step == 3:
			_check_and_unlock_facility()
	else:
		AudioSynth.play_airlock_denied()
		GameState.show_dialogue("Petalo", "Signal frequency mismatch! Sequence reset: Connect Alpha -> Beta -> Gamma.")
		sequence_step = 0
		_reset_sequence_nodes()

func _reset_sequence_nodes() -> void:
	var nodes = [node_a, node_b, node_c]
	for n in nodes:
		if n:
			n.is_active = false
			if n.interactable:
				n.interactable.is_active = true
			n._update_visuals()

