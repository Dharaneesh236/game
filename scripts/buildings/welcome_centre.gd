class_name WelcomeCentre
extends Node3D

# Building 1: Welcome Centre Controller with Strict Mission Verification

@onready var petalo: PetaloRobot = $Petalo
@onready var exit_gate: SecurityGate = $ExitGate
@onready var generator: UnstableMachine = $UnstableGenerator
@onready var cable_1: PowerCable = $PowerCable1
@onready var node_1: SignalNode = $SignalNode1
@onready var node_2: SignalNode = $SignalNode2
@onready var node_3: SignalNode = $SignalNode3
@onready var ceiling_lights: Node3D = $CeilingLights
@onready var transition_pad: LevelTransition = $LevelTransition

var nodes_active: int = 0
var mission_fulfilled: bool = false

func _ready() -> void:
	add_to_group("welcome_centre")
	GameState.set_objective("WELCOME CENTRE", "Find and repair Petalo (Light Robot).", 5.0)
	
	if petalo:
		var interact = petalo.get_node_or_null("Interactable")
		if interact:
			interact.interacted.connect(_on_petalo_repair_interacted)

	if node_1: node_1.node_activated.connect(_on_node_activated)
	if node_2: node_2.node_activated.connect(_on_node_activated)
	if node_3: node_3.node_activated.connect(_on_node_activated)
	if generator: generator.stabilized.connect(_on_generator_stabilized)
	if cable_1: cable_1.cable_connected.connect(_on_cable_connected)
	if exit_gate: exit_gate.gate_opened.connect(_on_exit_gate_opened)

func is_mission_complete() -> bool:
	var petalo_ok = GameState.robots["PETALO"]["repaired"]
	var nodes_ok = (nodes_active >= 3)
	var gen_ok = (generator != null and generator.is_stabilized)
	return petalo_ok and nodes_ok and gen_ok

func get_mission_status_text() -> String:
	var missing: Array[String] = []
	if not GameState.robots["PETALO"]["repaired"]:
		missing.append("Repair Petalo")
	if nodes_active < 3:
		missing.append("Activate Power Nodes (%d/3)" % nodes_active)
	if generator and not generator.is_stabilized:
		missing.append("Stabilize Generator Substation")
	
	if missing.is_empty():
		return "All objectives complete! Exit gate is open."
	return "Remaining: " + ", ".join(missing)

func _check_and_unlock_facility() -> void:
	if mission_fulfilled:
		return
	if is_mission_complete():
		mission_fulfilled = true
		GameState.mark_facility_completed(0)
		GameState.set_objective("WELCOME CENTRE RESTORED", "Facility 1 Complete! Walk through the Security Gate into Knowledge Centre.", 45.0)
		GameState.show_dialogue("Facility AI", "WELCOME CENTRE 100% OPERATIONAL. Security blast gate disengaged.")
		AudioSynth.play_repair_success()
		if exit_gate:
			exit_gate.is_locked = false
			exit_gate.open_gate()
		if transition_pad:
			transition_pad.activate_transition()

func _on_petalo_repair_interacted(interactor: Node) -> void:
	if not GameState.robots["PETALO"]["repaired"]:
		GameState.repair_minigame_requested.emit("PETALO", func():
			petalo.repair_robot()
			GameState.set_objective("WELCOME CENTRE", "Use Petalo [1] to reveal and activate 3 hidden power nodes.", 15.0)
			GameState.show_dialogue("Petalo", "My lantern is operational! Press [1] (or [Z]) to command me to illuminate dark sectors.")
			_check_and_unlock_facility()
		)

func _on_cable_connected(c: PowerCable) -> void:
	GameState.show_dialogue("System", "Power cable connected to local substation.")
	AudioSynth.play_spark()

func _on_node_activated(node: SignalNode) -> void:
	nodes_active += 1
	var pct = 15.0 + (nodes_active * 8.0)
	GameState.set_objective("WELCOME CENTRE", "Nodes activated: " + str(nodes_active) + "/3. Stabilize generator.", pct)
	
	if nodes_active >= 3:
		if ceiling_lights:
			for light in ceiling_lights.get_children():
				if light is OmniLight3D:
					light.light_energy = 2.5
		GameState.show_dialogue("Petalo", "All optical power nodes online! Generator power is surging.")
		GameState.set_objective("WELCOME CENTRE", "Stabilize the malfunctioning generator to unlock the exit gate.", 35.0)
	
	_check_and_unlock_facility()

func _on_generator_stabilized(m: UnstableMachine) -> void:
	GameState.set_objective("WELCOME CENTRE", "Facility power stable! Proceed through the Security Gate.", 40.0)
	_check_and_unlock_facility()

func _on_exit_gate_opened() -> void:
	if transition_pad and is_mission_complete():
		transition_pad.activate_transition()
