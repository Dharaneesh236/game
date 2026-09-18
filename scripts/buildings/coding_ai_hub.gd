class_name CodingAIHub
extends Node3D

# Building 3: Coding & AI Hub Controller with Strict Mission Verification

@onready var quacky: QuackyRobot = $Quacky
@onready var duct_interactable: Interactable = $MaintenanceDuct/Interactable
@onready var ai_terminal_interactable: Interactable = $AIMainframe/Interactable
@onready var exit_gate: SecurityGate = $ExitGate
@onready var transition_pad: LevelTransition = $LevelTransition

var module_retrieved: bool = false
var ai_restored: bool = false
var mission_fulfilled: bool = false

func _ready() -> void:
	add_to_group("coding_hub")
	GameState.set_objective("CODING & AI HUB", "Find and repair Quacky (Scout Robot).", 65.0)

	if quacky:
		var interact = quacky.get_node_or_null("Interactable")
		if interact:
			interact.interacted.connect(_on_quacky_repair_interacted)


	if duct_interactable:
		duct_interactable.interacted.connect(_on_duct_interacted)

	if ai_terminal_interactable:
		ai_terminal_interactable.interacted.connect(_on_ai_terminal_interacted)

func is_mission_complete() -> bool:
	var quacky_ok = GameState.robots["QUACKY"]["repaired"]
	var mod_ok = module_retrieved
	var ai_ok = ai_restored
	return quacky_ok and mod_ok and ai_ok

func get_mission_status_text() -> String:
	var missing: Array[String] = []
	if not GameState.robots["QUACKY"]["repaired"]:
		missing.append("Repair Quacky")
	if not module_retrieved:
		missing.append("Scout Duct for AI Core")
	if not ai_restored:
		missing.append("Reboot Central AI Mainframe")
	
	if missing.is_empty():
		return "All objectives complete! Exit gate is open."
	return "Remaining: " + ", ".join(missing)

func _check_and_unlock_facility() -> void:
	if mission_fulfilled:
		return
	if is_mission_complete():
		mission_fulfilled = true
		GameState.mark_facility_completed(2)
		GameState.set_objective("CODING & AI HUB RESTORED", "Facility 3 Complete! AI Network Rebooted. Proceed to Innovation Tower.", 82.0)
		GameState.show_dialogue("AI Core", "Neural matrix synchronized. Innovation Tower access protocol released.")
		AudioSynth.play_repair_success()
		if exit_gate:
			exit_gate.is_locked = false
			exit_gate.open_gate()
		if transition_pad:
			transition_pad.activate_transition()

func _on_quacky_repair_interacted(interactor: Node) -> void:
	if not GameState.robots["QUACKY"]["repaired"]:
		GameState.repair_minigame_requested.emit("QUACKY", func():
			quacky.repair_robot()
			GameState.set_objective("CODING & AI HUB", "Command Quacky [2] (or [X]) to scout narrow maintenance duct for AI Core.", 70.0)
			GameState.show_dialogue("Quacky", "Chassis online! Press [2] (or [X]) to send me into small maintenance ducts.")
			_check_and_unlock_facility()
		)

func _on_duct_interacted(interactor: Node) -> void:
	if not GameState.robots["QUACKY"]["repaired"]:
		GameState.show_dialogue("Explorer", "This duct is too small for me to enter. I need Quacky's scout abilities.")
		return
	if module_retrieved:
		GameState.show_dialogue("Quacky", "Duct already scouted! Deliver the core module to the AI Mainframe.")
		return

	GameState.robot_command_requested.emit("QUACKY", duct_interactable.global_position)
	await get_tree().create_timer(2.0).timeout
	retrieve_module()

func retrieve_module() -> void:
	module_retrieved = true
	GameState.coding_hub_module_recovered = true
	if quacky:
		quacky.attach_carried_module("AI Core Energy Module")
	AudioSynth.play_repair_success()
	GameState.show_dialogue("Quacky", "AI Core Module secured! Returning to player.")
	GameState.set_objective("CODING & AI HUB", "Deliver AI Core Module to Central AI Mainframe.", 76.0)
	_check_and_unlock_facility()

func _on_ai_terminal_interacted(interactor: Node) -> void:
	if not module_retrieved:
		GameState.show_dialogue("AI Mainframe", "CRITICAL ERROR: Primary Logic Core missing. Scout duct to recover core.")
		return
	if ai_restored:
		return

	ai_restored = true
	if quacky:
		quacky.deliver_item()
	AudioSynth.play_beam_activation()
	ai_terminal_interactable.is_active = false
	_check_and_unlock_facility()
