extends Node3D

# Third-Person 360-degree Orbit Camera Controller

@export var mouse_sensitivity: float = 0.0035
@export var min_pitch: float = -1.15 # ~ -66 degrees (looking up at player)
@export var max_pitch: float = 0.95  # ~ 54 degrees (looking down at player)
@export var default_distance: float = 4.2
@export var min_distance: float = 1.8
@export var max_distance: float = 6.5
@export var smooth_speed: float = 18.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var target: Node3D = null
var current_yaw: float = 0.0
var current_pitch: float = -0.2

var shake_timer: float = 0.0
var shake_duration_max: float = 1.0
var shake_magnitude: float = 0.0

func _ready() -> void:
	GameState.camera_controller_ref = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if spring_arm:
		spring_arm.spring_length = default_distance

func set_target(node: Node3D) -> void:
	target = node

func trigger_shake(intensity: float = 0.35, duration: float = 2.0) -> void:
	shake_magnitude = intensity
	shake_duration_max = max(duration, 0.01)
	shake_timer = duration

func _input(event: InputEvent) -> void:
	# Click to re-capture mouse if lost focus and not paused
	if event is InputEventMouseButton and event.pressed:
		if not get_tree().paused and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if event is InputEventMouseMotion and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or is_dragging):
		# Full 360-degree horizontal yaw rotation
		current_yaw -= event.relative.x * mouse_sensitivity
		current_yaw = wrapf(current_yaw, -PI, PI)
		
		# Vertical pitch look
		current_pitch -= event.relative.y * mouse_sensitivity
		current_pitch = clamp(current_pitch, min_pitch, max_pitch)
		
		rotation.y = current_yaw
		spring_arm.rotation.x = current_pitch

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clamp(spring_arm.spring_length - 0.4, min_distance, max_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clamp(spring_arm.spring_length + 0.4, min_distance, max_distance)

func _physics_process(delta: float) -> void:
	if target:
		# Smooth follow target position
		var target_pos = target.global_position + Vector3(0, 1.45, 0)
		global_position = global_position.lerp(target_pos, delta * smooth_speed)

	# Handle camera screen shake
	if camera:
		if shake_timer > 0.0:
			shake_timer -= delta
			var factor = clamp(shake_timer / shake_duration_max, 0.0, 1.0)
			var cur_mag = shake_magnitude * factor
			camera.h_offset = (randf() * 2.0 - 1.0) * cur_mag
			camera.v_offset = (randf() * 2.0 - 1.0) * cur_mag
		else:
			camera.h_offset = 0.0
			camera.v_offset = 0.0

func get_camera_forward() -> Vector3:
	var f = -camera.global_transform.basis.z
	f.y = 0
	return f.normalized()

func get_camera_right() -> Vector3:
	var r = camera.global_transform.basis.x
	r.y = 0
	return r.normalized()

func get_aim_target(distance: float = 40.0) -> Dictionary:
	if not camera or not is_inside_tree():
		return {}
	var space_state = get_world_3d().direct_space_state
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	var from = camera.project_ray_origin(screen_center)
	var dir = camera.project_ray_normal(screen_center)
	var to = from + dir * distance
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	return space_state.intersect_ray(query)

func get_aim_point(distance: float = 40.0) -> Vector3:
	var hit = get_aim_target(distance)
	if hit.has("position"):
		return hit["position"]
	if camera:
		return camera.global_position - camera.global_transform.basis.z * distance
	return global_position

