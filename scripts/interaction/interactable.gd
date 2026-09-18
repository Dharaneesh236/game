class_name Interactable
extends Area3D

# Reusable Interactable Component for RoboVerse

signal interacted(interactor: Node)

@export var prompt_message: String = "Interact"
@export var action_type: String = "general" # "repair_robot", "connect_cable", "activate_node", "gate", "terminal", "command"
@export var target_identifier: String = ""
@export var is_active: bool = true
@export var one_time_use: bool = false

var is_highlighted: bool = false
var original_materials: Dictionary = {}

func _ready() -> void:
	# Interaction layer 2 or default
	collision_layer = 2
	collision_mask = 1

func get_prompt() -> String:
	return prompt_message

func execute_interaction(interactor: Node) -> void:
	if not is_active:
		return
	AudioSynth.play_ui_click(1.2)
	interacted.emit(interactor)
	if one_time_use:
		is_active = false

func set_highlight(enabled: bool) -> void:
	if is_highlighted == enabled:
		return
	is_highlighted = enabled
	# Optional visual feedback pulse or glow
