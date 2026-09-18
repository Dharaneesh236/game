class_name PauseMenu
extends Control

# Pause Menu with Controls Guide and Building Selector (Respects Mission Progression)

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var b1_btn: Button = $Panel/VBox/FastTravelHBox/B1Btn
@onready var b2_btn: Button = $Panel/VBox/FastTravelHBox/B2Btn
@onready var b3_btn: Button = $Panel/VBox/FastTravelHBox/B3Btn
@onready var b4_btn: Button = $Panel/VBox/FastTravelHBox/B4Btn
@onready var b5_btn: Button = $Panel/VBox/FastTravelHBox/B5Btn

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(_on_resume_pressed)
	b1_btn.pressed.connect(func(): _fast_travel(0))
	b2_btn.pressed.connect(func(): _fast_travel(1))
	b3_btn.pressed.connect(func(): _fast_travel(2))
	b4_btn.pressed.connect(func(): _fast_travel(3))
	b5_btn.pressed.connect(func(): _fast_travel(4))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var new_state = not visible
	visible = new_state
	get_tree().paused = new_state
	if new_state:
		_update_button_states()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		AudioSynth.play_ui_click(0.9)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		AudioSynth.play_ui_click(1.1)

func _update_button_states() -> void:
	var btns = [b1_btn, b2_btn, b3_btn, b4_btn, b5_btn]
	for i in range(btns.size()):
		if btns[i]:
			var unlocked = GameState.can_access_building(i)
			btns[i].disabled = not unlocked
			btns[i].modulate = Color(1, 1, 1, 1) if unlocked else Color(0.4, 0.4, 0.4, 0.5)
			if not unlocked and not btns[i].text.ends_with(" 🔒"):
				btns[i].text += " 🔒"
			elif unlocked and btns[i].text.ends_with(" 🔒"):
				btns[i].text = btns[i].text.replace(" 🔒", "")

func _on_resume_pressed() -> void:
	toggle_pause()

func _fast_travel(building_index: int) -> void:
	if not GameState.can_access_building(building_index):
		AudioSynth.play_airlock_denied()
		GameState.show_dialogue("Navigation", "SECTOR LOCKED: Complete previous facility missions first!")
		return
	GameState.change_building(building_index)
	toggle_pause()
