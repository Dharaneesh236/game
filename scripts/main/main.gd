class_name MainGame
extends Node3D

# Main Game Controller for RoboVerse: The Last Signal

@onready var player: Player = $Player
@onready var camera_controller: Node3D = $ThirdPersonCamera
@onready var buildings_container: Node3D = $BuildingsContainer
@onready var opening_cinematic: OpeningCinematic = $OpeningCinematic
@onready var hud: HUD = $UI/HUD
@onready var repair_ui: RepairUI = $UI/RepairUI
@onready var pause_menu: PauseMenu = $UI/PauseMenu

# Building Scenes
var building_scenes = [
	preload("res://scenes/buildings/WelcomeCentre.tscn"),
	preload("res://scenes/buildings/KnowledgeCentre.tscn"),
	preload("res://scenes/buildings/CodingAIHub.tscn"),
	preload("res://scenes/buildings/InnovationTower.tscn"),
	preload("res://scenes/buildings/TestingArena.tscn")
]

# Helper Robot Companion Scenes
var robot_scenes = {
	"PETALO": preload("res://scenes/robots/Petalo.tscn"),
	"QUACKY": preload("res://scenes/robots/Quacky.tscn"),
	"TOLLY": preload("res://scenes/robots/Tolly.tscn"),
	"TIKO": preload("res://scenes/robots/Tiko.tscn")
}

var current_building_node: Node3D = null

func _ready() -> void:
	GameState.building_changed.connect(_on_building_changed)

	# Link player and third-person camera
	if player and camera_controller:
		player.set_camera_controller(camera_controller)
		if camera_controller.has_method("set_target"):
			camera_controller.set_target(player)
		GameState.camera_controller_ref = camera_controller
		GameState.player_ref = player

	# Load initial building (Welcome Centre)
	_load_building(0)

	# Connect opening cinematic
	if opening_cinematic:
		player.set_physics_process(false)
		opening_cinematic.cinematic_finished.connect(_on_opening_finished)
	else:
		_start_gameplay()

func _on_opening_finished() -> void:
	_start_gameplay()

func _start_gameplay() -> void:
	if player:
		player.set_physics_process(true)
	if camera_controller:
		var cam = camera_controller.get_node_or_null("SpringArm3D/Camera3D")
		if cam is Camera3D:
			cam.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameState.set_objective("WELCOME CENTRE", "Find and repair Petalo (Light Robot).", 5.0)
	GameState.show_dialogue("Explorer", "I've arrived at the RoboVerse Welcome Centre. Need to find a working service robot.")

func _on_building_changed(building_idx: int) -> void:
	_load_building(building_idx)

func _load_building(idx: int) -> void:
	if idx < 0 or idx >= building_scenes.size():
		return

	if current_building_node and is_instance_valid(current_building_node):
		current_building_node.queue_free()

	current_building_node = building_scenes[idx].instantiate()
	buildings_container.add_child(current_building_node)

	# Reset player position to facility entrance
	if player:
		player.global_position = Vector3(0, 1.0, 14.0)
		player.velocity = Vector3.ZERO

	# Sync already-repaired squad companions into the new building
	_sync_repaired_companions()

func _sync_repaired_companions() -> void:
	if not player or not current_building_node:
		return

	var squad_ids = ["PETALO", "QUACKY", "TOLLY", "TIKO"]
	var offsets = [
		Vector3(-1.8, 0, 1.8),
		Vector3(1.8, 0, 1.8),
		Vector3(-2.8, 0, 3.0),
		Vector3(2.8, 0, 3.0)
	]

	for i in range(squad_ids.size()):
		var rid = squad_ids[i]
		if GameState.robots.has(rid) and GameState.robots[rid]["repaired"]:
			# Check if already present in building
			var existing_bot: RobotBase = null
			for child in current_building_node.get_children():
				if child is RobotBase and child.robot_id == rid:
					existing_bot = child
					break

			if existing_bot:
				existing_bot.global_position = player.global_position + offsets[i]
				existing_bot.set_state(RobotBase.State.FOLLOWING)
			elif robot_scenes.has(rid):
				var bot_inst: RobotBase = robot_scenes[rid].instantiate()
				current_building_node.add_child(bot_inst)
				bot_inst.global_position = player.global_position + offsets[i]
				bot_inst.set_state(RobotBase.State.FOLLOWING)
