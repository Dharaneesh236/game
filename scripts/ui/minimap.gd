class_name MiniMap
extends Control

# Real-time Holographic Radar / Mini-map for RoboVerse HUD

@export var radar_radius_meters: float = 25.0
@export var radar_size_pixels: float = 75.0

var sweep_angle: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(radar_size_pixels * 2.0 + 20.0, radar_size_pixels * 2.0 + 35.0)

func _process(delta: float) -> void:
	sweep_angle += delta * 2.5
	if sweep_angle > TAU:
		sweep_angle -= TAU
	queue_redraw()

func _draw() -> void:
	var center = Vector2(radar_size_pixels + 10.0, radar_size_pixels + 10.0)
	var radius = radar_size_pixels
	var scale_factor = radius / radar_radius_meters

	# 1. Dark radar background
	draw_circle(center, radius, Color(0.02, 0.06, 0.12, 0.85))
	
	# 2. Outer border ring
	draw_arc(center, radius, 0, TAU, 48, Color(0.0, 0.85, 1.0, 0.9), 2.0)

	# 3. Concentric range rings (10m and 20m)
	draw_arc(center, radius * 0.45, 0, TAU, 32, Color(0.0, 0.85, 1.0, 0.25), 1.0)
	draw_arc(center, radius * 0.8, 0, TAU, 36, Color(0.0, 0.85, 1.0, 0.25), 1.0)

	# 4. Crosshair axes
	draw_line(center - Vector2(radius, 0), center + Vector2(radius, 0), Color(0.0, 0.85, 1.0, 0.2), 1.0)
	draw_line(center - Vector2(0, radius), center + Vector2(0, radius), Color(0.0, 0.85, 1.0, 0.2), 1.0)

	# 5. Radar sweep beam
	var sweep_dir = Vector2(cos(sweep_angle), sin(sweep_angle))
	draw_line(center, center + sweep_dir * radius, Color(0.0, 1.0, 0.8, 0.4), 1.5)

	# 6. Compass Cardinal Labels
	draw_string(ThemeDB.fallback_font, center - Vector2(4, radius - 12), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.0, 0.9, 1.0, 0.7))
	draw_string(ThemeDB.fallback_font, center + Vector2(-4, radius - 4), "S", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.0, 0.9, 1.0, 0.5))

	var player = GameState.player_ref
	if not is_instance_valid(player):
		return

	var player_pos = player.global_position

	# 7. Draw Objective / Interactive POI markers
	# Look for gates, generators, consoles
	for gate in get_tree().get_nodes_in_group("gates"):
		if is_instance_valid(gate):
			_draw_blip(center, player_pos, gate.global_position, scale_factor, radius, Color(1.0, 0.85, 0.1, 0.95), 4.5)

	for machine in get_tree().get_nodes_in_group("unstable_machines"):
		if is_instance_valid(machine):
			_draw_blip(center, player_pos, machine.global_position, scale_factor, radius, Color(1.0, 0.35, 0.1, 0.95), 4.0)

	# 8. Draw Companion Robots on Radar
	for robot in get_tree().get_nodes_in_group("robots"):
		if is_instance_valid(robot):
			var r_id = robot.get("robot_id") if "robot_id" in robot else "PETALO"
			var col = GameState.robots.get(r_id, {}).get("color", Color(0.2, 0.9, 1.0))
			_draw_blip(center, player_pos, robot.global_position, scale_factor, radius, col, 4.0)

	# 9. Draw Player icon at center (Cyan arrow pointing in facing direction)
	var facing_angle = 0.0
	if player.visual_root:
		facing_angle = player.visual_root.rotation.y

	# Draw player directional triangle
	var forward = Vector2(sin(facing_angle), -cos(facing_angle))
	var right = Vector2(-forward.y, forward.x)
	var tip = center + forward * 8.0
	var left_pt = center - forward * 5.0 - right * 5.0
	var right_pt = center - forward * 5.0 + right * 5.0

	draw_colored_polygon(PackedVector2Array([tip, left_pt, right_pt]), Color(0.0, 1.0, 0.9, 1.0))

	# Facility label under radar
	var b_name = "WELCOME CENTRE"
	match GameState.current_building:
		GameState.Building.WELCOME_CENTRE: b_name = "WELCOME CENTRE"
		GameState.Building.KNOWLEDGE_CENTRE: b_name = "KNOWLEDGE CENTRE"
		GameState.Building.CODING_AI_HUB: b_name = "CODING & AI HUB"
		GameState.Building.INNOVATION_TOWER: b_name = "INNOVATION TOWER"
		GameState.Building.TESTING_ARENA: b_name = "TESTING ARENA"

	draw_string(ThemeDB.fallback_font, Vector2(center.x - 55, radius * 2.0 + 26), "RADAR // " + b_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0, 0.85, 1, 0.8))

func _draw_blip(center: Vector2, player_pos: Vector3, target_pos: Vector3, scale_f: float, max_r: float, color: Color, dot_radius: float) -> void:
	var diff = target_pos - player_pos
	# In Godot 3D, -Z is forward, +X is right
	var map_offset = Vector2(diff.x * scale_f, diff.z * scale_f)
	if map_offset.length() > max_r - dot_radius:
		map_offset = map_offset.normalized() * (max_r - dot_radius)
	draw_circle(center + map_offset, dot_radius, color)
