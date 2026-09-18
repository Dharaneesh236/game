class_name HUD
extends Control

# Futuristic HUD Controller for RoboVerse: The Last Signal

@onready var mission_title_lbl: Label = $TopLeft/MissionTitle
@onready var mission_desc_lbl: Label = $TopLeft/MissionDesc
@onready var progress_bar: ProgressBar = $TopLeft/ProgressBar
@onready var progress_lbl: Label = $TopLeft/ProgressLabel

@onready var objective_banner: Panel = $TopCenter/ObjectiveBanner
@onready var objective_lbl: Label = $TopCenter/ObjectiveBanner/ObjectiveText

@onready var companion_panel: Panel = $TopRight/CompanionCard
@onready var companion_name_lbl: Label = $TopRight/CompanionCard/NameLabel
@onready var companion_role_lbl: Label = $TopRight/CompanionCard/RoleLabel
@onready var companion_status_lbl: Label = $TopRight/CompanionCard/StatusLabel
@onready var companion_color_tag: ColorRect = $TopRight/CompanionCard/ColorTag

@onready var prompt_panel: Panel = $BottomCenter/PromptPanel
@onready var prompt_lbl: Label = $BottomCenter/PromptPanel/PromptLabel

@onready var dialogue_panel: Panel = $BottomCenter/DialoguePanel
@onready var dialogue_speaker: Label = $BottomCenter/DialoguePanel/SpeakerLabel
@onready var dialogue_text: Label = $BottomCenter/DialoguePanel/TextLabel

# Squad status dots and hotkey labels
@onready var squad_petalo: ColorRect = $BottomLeft/SquadBox/HBox/PetaloDot
@onready var squad_quacky: ColorRect = $BottomLeft/SquadBox/HBox/QuackyDot
@onready var squad_tolly: ColorRect = $BottomLeft/SquadBox/HBox/TollyDot
@onready var squad_tiko: ColorRect = $BottomLeft/SquadBox/HBox/TikoDot

@onready var lbl_petalo: Label = $BottomLeft/SquadBox/HBox/PetaloLbl
@onready var lbl_quacky: Label = $BottomLeft/SquadBox/HBox/QuackyLbl
@onready var lbl_tolly: Label = $BottomLeft/SquadBox/HBox/TollyLbl
@onready var lbl_tiko: Label = $BottomLeft/SquadBox/HBox/TikoLbl

@onready var minimap: Control = $BottomLeft/MiniMap
@onready var reticle_dot: ColorRect = $CenterReticle/CenterDot

@onready var health_bar: ProgressBar = $TopLeft/HealthBox/HealthBar
@onready var health_lbl: Label = $TopLeft/HealthBox/HealthLabel
@onready var damage_flash: ColorRect = $DamageFlash

var dialogue_timer: float = 0.0
var last_health: float = 100.0

func _ready() -> void:
	GameState.objective_updated.connect(_on_objective_updated)
	GameState.robot_repaired.connect(_on_robot_repaired)
	GameState.companion_switched.connect(_on_companion_switched)
	GameState.dialogue_prompted.connect(_on_dialogue_prompted)

	dialogue_panel.visible = false
	prompt_panel.visible = false
	_update_squad_display()
	_update_companion_card()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		if minimap:
			minimap.visible = not minimap.visible
			AudioSynth.play_ui_click(1.2)

func _process(delta: float) -> void:
	# Connect to player health signal if ready
	var player = GameState.player_ref
	if is_instance_valid(player) and player.has_signal("health_changed"):
		if not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)
			_on_player_health_changed(player.current_health, player.max_health)

	# Update interact prompt based on player's current target
	if is_instance_valid(player) and player.current_interactable and player.current_interactable.is_active:
		prompt_panel.visible = true
		prompt_lbl.text = player.current_interactable.get_prompt()
		if reticle_dot:
			reticle_dot.color = Color(1.0, 0.85, 0.2, 0.95) # Glowing gold on target
	else:
		prompt_panel.visible = false
		if reticle_dot:
			reticle_dot.color = Color(0.0, 0.9, 1.0, 0.75) # Ambient cyan

	# Handle dialogue timer
	if dialogue_timer > 0.0:
		dialogue_timer -= delta
		if dialogue_timer <= 0.0:
			dialogue_panel.visible = false

func _on_player_health_changed(cur: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = cur
	if health_lbl:
		health_lbl.text = str(int(cur))
		if cur <= 25.0:
			health_lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		elif cur <= 50.0:
			health_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
		else:
			health_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5, 1.0))

	# Trigger damage flash if health decreased
	if cur < last_health and damage_flash:
		damage_flash.color = Color(1.0, 0.1, 0.1, 0.35)
		var tw = create_tween()
		tw.tween_property(damage_flash, "color:a", 0.0, 0.3)

	last_health = cur

func _on_objective_updated(title: String, objective: String, progress: float) -> void:
	mission_title_lbl.text = title.to_upper()
	mission_desc_lbl.text = "RoboVerse Restoration Protocol"
	objective_lbl.text = "[!] " + objective
	progress_bar.value = progress
	progress_lbl.text = str(int(progress)) + "%"

func _on_robot_repaired(robot_name: String) -> void:
	_update_squad_display()
	_update_companion_card()

func _on_companion_switched(robot_name: String) -> void:
	_update_squad_display()
	_update_companion_card()

func _update_squad_display() -> void:
	var active = GameState.active_companion
	if squad_petalo:
		squad_petalo.color = Color(0.1, 0.9, 1.0) if GameState.robots["PETALO"]["repaired"] else Color(0.6, 0.2, 0.2)
	if squad_quacky:
		squad_quacky.color = Color(1.0, 0.8, 0.2) if GameState.robots["QUACKY"]["repaired"] else Color(0.6, 0.2, 0.2)
	if squad_tolly:
		squad_tolly.color = Color(0.9, 0.3, 0.9) if GameState.robots["TOLLY"]["repaired"] else Color(0.6, 0.2, 0.2)
	if squad_tiko:
		squad_tiko.color = Color(0.2, 0.9, 0.4) if GameState.robots["TIKO"]["repaired"] else Color(0.6, 0.2, 0.2)

	if lbl_petalo:
		lbl_petalo.text = "[1] PETALO" + (" ★" if active == "PETALO" else "")
		lbl_petalo.add_theme_color_override("font_color", Color(1.0, 0.95, 0.3, 1.0) if active == "PETALO" else (Color(0.2, 0.9, 1.0, 0.85) if GameState.robots["PETALO"]["repaired"] else Color(0.6, 0.6, 0.6, 0.6)))
	if lbl_quacky:
		lbl_quacky.text = "[2] QUACKY" + (" ★" if active == "QUACKY" else "")
		lbl_quacky.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0) if active == "QUACKY" else (Color(1.0, 0.8, 0.2, 0.85) if GameState.robots["QUACKY"]["repaired"] else Color(0.6, 0.6, 0.6, 0.6)))
	if lbl_tolly:
		lbl_tolly.text = "[3] TOLLY" + (" ★" if active == "TOLLY" else "")
		lbl_tolly.add_theme_color_override("font_color", Color(0.9, 0.35, 1.0, 1.0) if active == "TOLLY" else (Color(0.9, 0.3, 0.9, 0.85) if GameState.robots["TOLLY"]["repaired"] else Color(0.6, 0.6, 0.6, 0.6)))
	if lbl_tiko:
		lbl_tiko.text = "[4] TIKO" + (" ★" if active == "TIKO" else "")
		lbl_tiko.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0) if active == "TIKO" else (Color(0.2, 0.9, 0.4, 0.85) if GameState.robots["TIKO"]["repaired"] else Color(0.6, 0.6, 0.6, 0.6)))

func _update_companion_card() -> void:
	var active = GameState.active_companion
	var data = GameState.robots.get(active, {})
	var key_hint = {
		"PETALO": "[1] or [Z]",
		"QUACKY": "[2] or [X]",
		"TOLLY": "[3] or [C]",
		"TIKO": "[4] or [V]"
	}.get(active, "[Q]")

	if companion_name_lbl and data.size() > 0:
		companion_name_lbl.text = "%s  %s" % [data.get("name", "Companion").to_upper(), key_hint]
		companion_role_lbl.text = data.get("role", "")
		var is_rep = data.get("repaired", false)
		companion_status_lbl.text = ("KEY %s // READY" % key_hint) if is_rep else "OFFLINE // DAMAGED"
		companion_color_tag.color = data.get("color", Color(0, 0.9, 1)) if is_rep else Color(0.8, 0.2, 0.2)

func _on_dialogue_prompted(speaker: String, text: String, duration: float) -> void:
	dialogue_speaker.text = speaker.to_upper()
	dialogue_text.text = text
	dialogue_panel.visible = true
	dialogue_timer = duration
