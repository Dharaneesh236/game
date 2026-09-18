class_name TestingArena
extends Node3D

# Building 5: Testing Arena Controller & Grand Finale Orchestrator

@onready var master_console_interact: Interactable = $MasterConsole/Interactable
@onready var spire: StaticBody3D = $CentralSignalTower
@onready var tower_beam: MeshInstance3D = $CentralSignalTower/SkyBeam
@onready var tower_beam_outer: MeshInstance3D = $CentralSignalTower/SkyBeamOuter
@onready var tower_light: OmniLight3D = $CentralSignalTower/TowerLight
@onready var shockwave_ring: MeshInstance3D = $CentralSignalTower/ShockwaveRing
@onready var floor_circuits: Node3D = $FloorCircuits

@onready var pylon_south: Node3D = $RelayPylonSouth
@onready var pylon_east: Node3D = $RelayPylonEast
@onready var pylon_north: Node3D = $RelayPylonNorth
@onready var pylon_west: Node3D = $RelayPylonWest

@onready var victory_ui: CanvasLayer = $VictoryUI
@onready var replay_btn: Button = $VictoryUI/Panel/VBox/ButtonHBox/ReplayButton
@onready var roam_btn: Button = $VictoryUI/Panel/VBox/ButtonHBox/FreeRoamButton

var robot_scenes = {
	"PETALO": preload("res://scenes/robots/Petalo.tscn"),
	"QUACKY": preload("res://scenes/robots/Quacky.tscn"),
	"TOLLY": preload("res://scenes/robots/Tolly.tscn"),
	"TIKO": preload("res://scenes/robots/Tiko.tscn")
}

var sequence_triggered: bool = false
var companions_in_arena: Dictionary = {}

func _ready() -> void:
	GameState.set_objective("FINAL OBJECTIVE", "Approach Master Console & Activate The Last Signal.", 94.0)

	# Initial beam states
	if tower_beam: tower_beam.visible = false
	if tower_beam_outer: tower_beam_outer.visible = false
	if shockwave_ring: shockwave_ring.visible = false

	_set_pylon_beam_visible(pylon_south, false)
	_set_pylon_beam_visible(pylon_east, false)
	_set_pylon_beam_visible(pylon_north, false)
	_set_pylon_beam_visible(pylon_west, false)

	if master_console_interact:
		master_console_interact.interacted.connect(_on_console_interacted)

	if victory_ui:
		victory_ui.visible = false

	if replay_btn:
		replay_btn.pressed.connect(_reset_and_replay)
	if roam_btn:
		roam_btn.pressed.connect(_free_roam)

	# Ensure all 4 robots are active and present in the arena
	_ensure_all_robots_present()

func _unhandled_input(event: InputEvent) -> void:
	if victory_ui and victory_ui.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_R:
				_reset_and_replay()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ESCAPE:
				_free_roam()
				get_viewport().set_input_as_handled()

func _ensure_all_robots_present() -> void:
	var r_ids = ["PETALO", "QUACKY", "TOLLY", "TIKO"]
	for rid in r_ids:
		GameState.robots[rid]["repaired"] = true

		var found_bot: RobotBase = null
		# Check arena children or parent children
		for child in get_children():
			if child is RobotBase and child.robot_id == rid:
				found_bot = child
				break
		if not found_bot and get_parent():
			for child in get_parent().get_children():
				if child is RobotBase and child.robot_id == rid:
					found_bot = child
					break

		if not found_bot:
			var inst: RobotBase = robot_scenes[rid].instantiate()
			add_child(inst)
			inst.global_position = Vector3(randf_range(-3.0, 3.0), 0.5, randf_range(2.0, 6.0))
			inst.set_state(RobotBase.State.FOLLOWING)
			found_bot = inst

		companions_in_arena[rid] = found_bot

func _set_pylon_beam_visible(pylon: Node3D, vis: bool) -> void:
	if not pylon:
		return
	var beam = pylon.get_node_or_null("BeamMesh")
	if beam:
		beam.visible = vis
	var light = pylon.get_node_or_null("PylonLight")
	if light:
		light.light_energy = 5.0 if vis else 0.0

func _on_console_interacted(interactor: Node) -> void:
	if sequence_triggered:
		return
	sequence_triggered = true
	if master_console_interact:
		master_console_interact.is_active = false
	_run_grand_climax()

func _run_grand_climax() -> void:
	# PHASE 1: Squad Rally & Relay Station Positioning
	GameState.set_objective("TRANSMISSION ACTIVE", "CONVERGING FUNOBOTZ ELEMENTAL RELAY PYLONS...", 95.0)
	GameState.show_dialogue("Explorer", "All Funobotz, take your stations at the 4 Elemental Relay Pylons!")
	AudioSynth.play_ui_click(1.2)
	GameState.shake_camera(0.2, 1.2)

	_move_companion_to("PETALO", pylon_south.get_node("StationMarker").global_position)
	_move_companion_to("QUACKY", pylon_east.get_node("StationMarker").global_position)
	_move_companion_to("TOLLY", pylon_north.get_node("StationMarker").global_position)
	_move_companion_to("TIKO", pylon_west.get_node("StationMarker").global_position)

	await get_tree().create_timer(1.2).timeout

	# PHASE 2A: Petalo Channels Solar Beam (South)
	_set_pylon_beam_visible(pylon_south, true)
	AudioSynth.play_elemental_beam(0)
	GameState.show_dialogue("Petalo", "Solar Beacon online! Channeling 440MHz carrier wave into the Spire!")
	if tower_light: tower_light.light_energy = 8.0
	GameState.shake_camera(0.2, 0.8)
	await get_tree().create_timer(1.2).timeout

	# PHASE 2B: Quacky Channels Logic Beam (East)
	_set_pylon_beam_visible(pylon_east, true)
	AudioSynth.play_elemental_beam(1)
	GameState.show_dialogue("Quacky", "AI Logic Matrix synchronized! Calibrating galaxy routing tables!")
	if tower_light: tower_light.light_energy = 14.0
	GameState.shake_camera(0.25, 0.8)
	await get_tree().create_timer(1.2).timeout

	# PHASE 2C: Tolly Channels Decryption Pulse Wave (North)
	_set_pylon_beam_visible(pylon_north, true)
	AudioSynth.play_elemental_beam(2)
	GameState.show_dialogue("Tolly", "Security decryption engaged! All broadcast limiters and firewalls neutralized!")
	if tower_light: tower_light.light_energy = 20.0
	GameState.shake_camera(0.3, 0.8)
	await get_tree().create_timer(1.2).timeout

	# PHASE 2D: Tiko Channels Kinetic Power Surge (West)
	_set_pylon_beam_visible(pylon_west, true)
	AudioSynth.play_elemental_beam(3)
	GameState.show_dialogue("Tiko", "Maximum hydraulic reactor power surging! Primary power conduits locked!")
	if tower_light: tower_light.light_energy = 26.0
	GameState.shake_camera(0.35, 1.0)
	await get_tree().create_timer(1.0).timeout

	# PHASE 3: Spire Overcharge, Ground Shockwave & Bass Swell
	GameState.set_objective("CRITICAL OVERCHARGE", "CENTRAL SIGNAL TOWER REACHING MAXIMUM POWER...", 98.0)
	GameState.show_dialogue("Central Spire", "CRITICAL OVERCHARGE REACHED. RELEASING THE LAST SIGNAL...")
	AudioSynth.play_overcharge_rumble()
	GameState.shake_camera(0.5, 3.2)

	if shockwave_ring:
		shockwave_ring.visible = true
		shockwave_ring.scale = Vector3(1.0, 1.0, 1.0)
		var sw_tw = create_tween()
		sw_tw.tween_property(shockwave_ring, "scale", Vector3(26.0, 1.0, 26.0), 2.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(2.0).timeout

	# PHASE 4: Colossal Sky Beam Launch & Aurora Sky Transition
	if tower_beam: tower_beam.visible = true
	if tower_beam_outer: tower_beam_outer.visible = true
	if tower_light:
		var tw = create_tween()
		tw.tween_property(tower_light, "light_energy", 40.0, 1.5)

	AudioSynth.play_grand_fanfare()
	GameState.trigger_final_signal()
	GameState.set_objective("SIGNAL RESTORED", "ROBOVERSE NETWORK ONLINE — GALAXY BROADCAST ACTIVE!", 100.0)

	await get_tree().create_timer(2.6).timeout

	# PHASE 5: Grand Victory UI Presentation
	if victory_ui:
		victory_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	AudioSynth.play_repair_success()

func _move_companion_to(rid: String, target_pos: Vector3) -> void:
	if companions_in_arena.has(rid) and is_instance_valid(companions_in_arena[rid]):
		var bot: RobotBase = companions_in_arena[rid]
		bot.set_state(RobotBase.State.PERFORMING_ACTION)
		var tw = create_tween()
		tw.tween_property(bot, "global_position", target_pos, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# Face towards tower
		var tower_pos = Vector3(0, 0, -16)
		bot.look_at(Vector3(tower_pos.x, bot.global_position.y, tower_pos.z), Vector3.UP)

func _free_roam() -> void:
	if victory_ui:
		victory_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	AudioSynth.play_ui_click(1.1)

func _reset_and_replay() -> void:
	if victory_ui:
		victory_ui.visible = false
	sequence_triggered = false
	
	if tower_beam: tower_beam.visible = false
	if tower_beam_outer: tower_beam_outer.visible = false
	if shockwave_ring: shockwave_ring.visible = false
	if tower_light: tower_light.light_energy = 5.0

	_set_pylon_beam_visible(pylon_south, false)
	_set_pylon_beam_visible(pylon_east, false)
	_set_pylon_beam_visible(pylon_north, false)
	_set_pylon_beam_visible(pylon_west, false)

	_run_grand_climax()
