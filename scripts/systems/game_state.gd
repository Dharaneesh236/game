extends Node

# Global GameState Autoload for RoboVerse: The Last Signal

signal objective_updated(mission_title: String, objective_text: String, progress_pct: float)
signal robot_repaired(robot_name: String)
signal robot_command_requested(robot_name: String, target_pos: Vector3)
signal dialogue_prompted(speaker: String, text: String, duration: float)
signal building_changed(building_index: int)
signal signal_restored_complete()
signal companion_switched(robot_name: String)
signal repair_minigame_requested(target_name: String, callback: Callable)

enum Building {
	WELCOME_CENTRE = 0,
	KNOWLEDGE_CENTRE = 1,
	CODING_AI_HUB = 2,
	INNOVATION_TOWER = 3,
	TESTING_ARENA = 4
}

var current_building: int = Building.WELCOME_CENTRE
var current_mission_title: String = "THE LAST SIGNAL"
var current_objective: String = "Find the source of the emergency signal."
var progress_percentage: float = 0.0

# Robot states
var robots = {
	"PETALO": {"repaired": false, "name": "Petalo", "role": "Light & Signalling", "color": Color(0.2, 0.9, 1.0)},
	"QUACKY": {"repaired": false, "name": "Quacky", "role": "Scout & Delivery", "color": Color(1.0, 0.8, 0.2)},
	"TOLLY": {"repaired": false, "name": "Tolly", "role": "Access & Gate", "color": Color(0.9, 0.3, 0.9)},
	"TIKO": {"repaired": false, "name": "Tiko", "role": "Heavy Manipulation", "color": Color(0.3, 0.9, 0.4)}
}

var active_companion: String = "PETALO"

# Environmental puzzle flags
var welcome_centre_nodes_activated: int = 0
var welcome_centre_gate_opened: bool = false
var knowledge_centre_route_aligned: bool = false
var coding_hub_module_recovered: bool = false
var coding_hub_nodes_activated: Array = []
var innovation_tower_elevator_powered: bool = false
var innovation_tower_bridge_aligned: bool = false
var innovation_tower_gate_unlocked: bool = false
var arena_power_ready: bool = false
var arena_robots_positioned: int = 0
var last_signal_activated: bool = false

var player_ref: Node = null
var camera_controller_ref: Node3D = null

# Sequential progression gatekeeping
var facility_completed: Array[bool] = [false, false, false, false, false]
var max_unlocked_building: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_companion_actions()

func _setup_companion_actions() -> void:
	var mappings = {
		"command_petalo": [KEY_1, KEY_Z, KEY_KP_1],
		"command_quacky": [KEY_2, KEY_X, KEY_KP_2],
		"command_tolly": [KEY_3, KEY_C, KEY_KP_3],
		"command_tiko": [KEY_4, KEY_V, KEY_KP_4]
	}
	for action in mappings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in mappings[action]:
				var ev = InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)

func set_objective(title: String, objective: String, progress: float) -> void:
	current_mission_title = title
	current_objective = objective
	progress_percentage = clamp(progress, 0.0, 100.0)
	objective_updated.emit(current_mission_title, current_objective, progress_percentage)

func mark_robot_repaired(robot_name: String) -> void:
	robot_name = robot_name.to_upper()
	if robots.has(robot_name):
		robots[robot_name]["repaired"] = true
		active_companion = robot_name
		robot_repaired.emit(robot_name)
		companion_switched.emit(robot_name)
		AudioSynth.play_repair_success()
		show_dialogue(robots[robot_name]["name"], "Systems restored! Standing by for orders.")

func switch_active_companion(robot_name: String) -> bool:
	robot_name = robot_name.to_upper()
	if robots.has(robot_name) and robots[robot_name]["repaired"]:
		active_companion = robot_name
		companion_switched.emit(robot_name)
		robot_repaired.emit(robot_name)
		return true
	return false

func mark_facility_completed(b_idx: int) -> void:
	if b_idx >= 0 and b_idx < facility_completed.size():
		facility_completed[b_idx] = true
		if b_idx + 1 > max_unlocked_building:
			max_unlocked_building = clamp(b_idx + 1, 0, 4)

func can_access_building(b_idx: int) -> bool:
	return b_idx <= max_unlocked_building

func shake_camera(intensity: float = 0.35, duration: float = 2.0) -> void:
	if camera_controller_ref and camera_controller_ref.has_method("trigger_shake"):
		camera_controller_ref.trigger_shake(intensity, duration)

func show_dialogue(speaker: String, text: String, duration: float = 4.0) -> void:
	dialogue_prompted.emit(speaker, text, duration)
	AudioSynth.play_robot_chirp()

func change_building(new_building_idx: int) -> void:
	current_building = new_building_idx
	building_changed.emit(current_building)

func trigger_final_signal() -> void:
	last_signal_activated = true
	mark_facility_completed(Building.TESTING_ARENA)
	progress_percentage = 100.0
	objective_updated.emit("SIGNAL RESTORED", "ROBOVERSE NETWORK ONLINE", 100.0)
	signal_restored_complete.emit()
	AudioSynth.play_beam_activation()

