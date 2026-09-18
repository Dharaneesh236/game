extends SceneTree

# Automated Test Runner for RoboVerse: The Last Signal

func _init() -> void:
	print("\n==============================================")
	print("STARTING ROBOVERSE AUTOMATED SYSTEM VERIFICATION")
	print("==============================================\n")

	var AudioSynthClass = load("res://scripts/systems/audio_synth.gd")
	var audio_synth = AudioSynthClass.new()
	root.add_child(audio_synth)

	var GameStateClass = load("res://scripts/systems/game_state.gd")
	var game_state = GameStateClass.new()
	root.add_child(game_state)

	var tests_passed := 0
	var tests_total := 0

	# Test 1: Load Main Scene
	tests_total += 1
	var main_scene = load("res://scenes/main/Main.tscn")
	if main_scene:
		print("[PASS] Test 1: Main scene loaded successfully.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 1: Failed to load Main.tscn")

	# Test 2: Instantiate Main Scene
	tests_total += 1
	var main_instance = main_scene.instantiate()
	if main_instance:
		print("[PASS] Test 2: Main instance instantiated.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 2: Failed to instantiate Main.tscn")

	# Test 3: Player Instance & Camera Connection
	tests_total += 1
	var player = main_instance.get_node_or_null("Player")
	var cam = main_instance.get_node_or_null("ThirdPersonCamera")
	if player and cam:
		print("[PASS] Test 3: Player and ThirdPersonCamera present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 3: Missing Player or ThirdPersonCamera in Main.")

	# Test 4: UI System (HUD, RepairUI, PauseMenu)
	tests_total += 1
	var hud = main_instance.get_node_or_null("UI/HUD")
	var repair_ui = main_instance.get_node_or_null("UI/RepairUI")
	var pause_menu = main_instance.get_node_or_null("UI/PauseMenu")
	if hud and repair_ui and pause_menu:
		print("[PASS] Test 4: UI layer (HUD, RepairUI, PauseMenu) verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 4: Missing UI components.")

	# Test 5: Building 1 (Welcome Centre)
	tests_total += 1
	var b1_scene = load("res://scenes/buildings/WelcomeCentre.tscn")
	var b1 = b1_scene.instantiate()
	if b1.get_node_or_null("Petalo") and b1.get_node_or_null("ExitGate") and b1.get_node_or_null("UnstableGenerator"):
		print("[PASS] Test 5: Welcome Centre verified with Petalo, Gate, and Unstable Generator.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 5: Welcome Centre missing core objects.")

	# Test 6: Building 2 (Knowledge Centre)
	tests_total += 1
	var b2_scene = load("res://scenes/buildings/KnowledgeCentre.tscn")
	var b2 = b2_scene.instantiate()
	if b2.get_node_or_null("Tiko") and b2.get_node_or_null("HeavyServerObstacle"):
		print("[PASS] Test 6: Knowledge Centre verified with Tiko and Heavy Server Obstacle.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 6: Knowledge Centre missing core objects.")

	# Test 7: Building 3 (Coding & AI Hub)
	tests_total += 1
	var b3_scene = load("res://scenes/buildings/CodingAIHub.tscn")
	var b3 = b3_scene.instantiate()
	if b3.get_node_or_null("Quacky") and b3.get_node_or_null("MaintenanceDuct") and b3.get_node_or_null("AIMainframe"):
		print("[PASS] Test 7: Coding & AI Hub verified with Quacky, Duct, and Mainframe.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 7: Coding & AI Hub missing core objects.")

	# Test 8: Building 4 (Innovation Tower)
	tests_total += 1
	var b4_scene = load("res://scenes/buildings/InnovationTower.tscn")
	var b4 = b4_scene.instantiate()
	if b4.get_node_or_null("Tolly") and b4.get_node_or_null("ElevatorPlatform") and b4.get_node_or_null("CatwalkBridge"):
		print("[PASS] Test 8: Innovation Tower verified with Tolly, Elevator, and Catwalk Bridge.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 8: Innovation Tower missing core objects.")

	# Test 9: Building 5 (Testing Arena)
	tests_total += 1
	var b5_scene = load("res://scenes/buildings/TestingArena.tscn")
	var b5 = b5_scene.instantiate()
	if b5.get_node_or_null("CentralSignalTower") and b5.get_node_or_null("MasterConsole"):
		print("[PASS] Test 9: Testing Arena verified with Central Signal Tower and Master Console.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 9: Testing Arena missing core objects.")

	# Test 10: Petalo Light Ability & Revealing Nodes
	tests_total += 1
	var petalo_node = b1.get_node_or_null("Petalo")
	if petalo_node and petalo_node.has_method("perform_special_ability"):
		print("[PASS] Test 10: Petalo optical reveal ability verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 10: Petalo ability method missing.")

	# Test 11: Quacky Duct Scout & Item Delivery
	tests_total += 1
	var quacky_node = b3.get_node_or_null("Quacky")
	if quacky_node and quacky_node.has_method("attach_carried_module") and quacky_node.has_method("deliver_item"):
		quacky_node.attach_carried_module("AI Core Energy Module")
		var delivered = quacky_node.deliver_item()
		if delivered == "AI Core Energy Module":
			print("[PASS] Test 11: Quacky item retrieval and delivery cycle verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 11: Quacky delivered wrong item.")
	else:
		printerr("[FAIL] Test 11: Quacky delivery methods missing.")

	# Test 12: Tolly Access Protocol
	tests_total += 1
	var tolly_node = b4.get_node_or_null("Tolly")
	if tolly_node and tolly_node.has_method("perform_special_ability"):
		print("[PASS] Test 12: Tolly access protocol verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 12: Tolly access methods missing.")

	# Test 13: Tiko Heavy Push
	tests_total += 1
	var tiko_node = b2.get_node_or_null("Tiko")
	if tiko_node and tiko_node.has_method("perform_special_ability"):
		print("[PASS] Test 13: Tiko heavy manipulation verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 13: Tiko manipulation methods missing.")

	# Test 14: PowerCable State Transitions
	tests_total += 1
	var cable = b1.get_node_or_null("PowerCable1")
	if cable and cable.has_method("connect_cable"):
		cable.connect_cable()
		if cable.is_connected:
			print("[PASS] Test 14: Electrical PowerCable connection verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 14: PowerCable failed to connect.")
	else:
		printerr("[FAIL] Test 14: PowerCable missing connect method.")

	# Test 15: Unstable Machine Hazard & Stabilization
	tests_total += 1
	var machine = b1.get_node_or_null("UnstableGenerator")
	if machine and machine.has_method("stabilize_machine"):
		machine.stabilize_machine()
		if machine.is_stabilized and not machine.is_active_hazard:
			print("[PASS] Test 15: Unstable Machine hazard stabilization verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 15: Unstable Machine stabilization failed.")
	else:
		printerr("[FAIL] Test 15: Unstable Machine missing stabilize method.")

	# Test 16: SecurityGate Slide Open
	tests_total += 1
	var gate = b1.get_node_or_null("ExitGate")
	if gate and gate.has_method("open_gate"):
		gate.open_gate()
		if gate.is_open:
			print("[PASS] Test 16: Security Gate sliding door system verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 16: Gate failed to open.")
	else:
		printerr("[FAIL] Test 16: Gate missing open method.")

	# Test 17: GameState Mission Progression
	tests_total += 1
	game_state.set_objective("TEST MISSION", "Verify Test Runner", 50.0)
	if game_state.current_mission_title == "TEST MISSION" and game_state.progress_percentage == 50.0:
		print("[PASS] Test 17: GameState objective tracking verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 17: GameState objective tracking failed.")

	# Test 18: Final Signal Sequence Activation
	tests_total += 1
	game_state.trigger_final_signal()
	if game_state.last_signal_activated and game_state.progress_percentage == 100.0:
		print("[PASS] Test 18: Final Signal Sequence 100% completion verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 18: Final Signal Sequence failed.")

	print("\n==============================================")
	print("RESULTS: %d / %d TESTS PASSED!" % [tests_passed, tests_total])
	print("==============================================\n")

	# Clean up instances
	main_instance.free()
	b1.free()
	b2.free()
	b3.free()
	b4.free()
	b5.free()
	audio_synth.free()
	game_state.free()

	if tests_passed == tests_total:
		quit(0)
	else:
		quit(1)
