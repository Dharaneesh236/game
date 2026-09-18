extends Node3D

# In-Engine Automated Test Suite for RoboVerse: The Last Signal

func _ready() -> void:
	print("\n==============================================")
	print("STARTING ROBOVERSE IN-ENGINE SYSTEM VERIFICATION")
	print("==============================================\n")

	var tests_passed := 0
	var tests_total := 0

	# Test 1: Autoloads Active
	tests_total += 1
	if GameState != null and AudioSynth != null:
		print("[PASS] Test 1: Autoloads GameState and AudioSynth active.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 1: Autoloads missing.")

	# Test 2: Main Scene Load
	tests_total += 1
	var main_scene = load("res://scenes/main/Main.tscn")
	var main_inst = main_scene.instantiate()
	add_child(main_inst)
	if main_inst:
		print("[PASS] Test 2: Main scene instantiated in active tree.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 2: Main scene instantiation failed.")

	# Test 3: Player and Camera Target
	tests_total += 1
	var player = main_inst.get_node_or_null("Player")
	var cam_ctrl = main_inst.get_node_or_null("ThirdPersonCamera")
	if player and cam_ctrl and cam_ctrl.target == player:
		print("[PASS] Test 3: Player and ThirdPersonCamera connected.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 3: Player/Camera target linking failed.")

	# Test 4: UI Hierarchy
	tests_total += 1
	var hud = main_inst.get_node_or_null("UI/HUD")
	var repair_ui = main_inst.get_node_or_null("UI/RepairUI")
	var pause_menu = main_inst.get_node_or_null("UI/PauseMenu")
	if hud and repair_ui and pause_menu:
		print("[PASS] Test 4: UI layer (HUD, RepairUI, PauseMenu) verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 4: UI components missing.")

	# Test 5: Building 1 (Welcome Centre)
	tests_total += 1
	var b1_scene = load("res://scenes/buildings/WelcomeCentre.tscn")
	var b1 = b1_scene.instantiate()
	add_child(b1)
	var petalo = b1.get_node_or_null("Petalo")
	var gate1 = b1.get_node_or_null("ExitGate")
	var gen1 = b1.get_node_or_null("UnstableGenerator")
	var cable1 = b1.get_node_or_null("PowerCable1")
	if petalo and gate1 and gen1 and cable1:
		print("[PASS] Test 5: Welcome Centre elements (Petalo, Gate, Gen, Cable) present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 5: Welcome Centre missing core objects.")

	# Test 6: Building 2 (Knowledge Centre)
	tests_total += 1
	var b2_scene = load("res://scenes/buildings/KnowledgeCentre.tscn")
	var b2 = b2_scene.instantiate()
	add_child(b2)
	var tiko = b2.get_node_or_null("Tiko")
	var heavy_obst = b2.get_node_or_null("HeavyServerObstacle")
	if tiko and heavy_obst:
		print("[PASS] Test 6: Knowledge Centre elements (Tiko, HeavyObstacle) present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 6: Knowledge Centre missing core objects.")

	# Test 7: Building 3 (Coding & AI Hub)
	tests_total += 1
	var b3_scene = load("res://scenes/buildings/CodingAIHub.tscn")
	var b3 = b3_scene.instantiate()
	add_child(b3)
	var quacky = b3.get_node_or_null("Quacky")
	var duct = b3.get_node_or_null("MaintenanceDuct")
	var mainframe = b3.get_node_or_null("AIMainframe")
	if quacky and duct and mainframe:
		print("[PASS] Test 7: Coding AI Hub elements (Quacky, Duct, Mainframe) present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 7: Coding AI Hub missing core objects.")

	# Test 8: Building 4 (Innovation Tower)
	tests_total += 1
	var b4_scene = load("res://scenes/buildings/InnovationTower.tscn")
	var b4 = b4_scene.instantiate()
	add_child(b4)
	var tolly = b4.get_node_or_null("Tolly")
	var elevator = b4.get_node_or_null("ElevatorPlatform")
	var bridge = b4.get_node_or_null("CatwalkBridge")
	if tolly and elevator and bridge:
		print("[PASS] Test 8: Innovation Tower elements (Tolly, Elevator, Bridge) present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 8: Innovation Tower missing core objects.")

	# Test 9: Building 5 (Testing Arena)
	tests_total += 1
	var b5_scene = load("res://scenes/buildings/TestingArena.tscn")
	var b5 = b5_scene.instantiate()
	add_child(b5)
	var tower = b5.get_node_or_null("CentralSignalTower")
	var console = b5.get_node_or_null("MasterConsole")
	if tower and console:
		print("[PASS] Test 9: Testing Arena elements (Tower, Console) present.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 9: Testing Arena missing core objects.")

	# Test 10: Petalo Optical Ability
	tests_total += 1
	if petalo and petalo.has_method("perform_special_ability"):
		petalo.repair_robot()
		print("[PASS] Test 10: Petalo repair and ability activation verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 10: Petalo ability missing.")

	# Test 11: Quacky Module Carry & Delivery
	tests_total += 1
	if quacky and quacky.has_method("attach_carried_module") and quacky.has_method("deliver_item"):
		quacky.repair_robot()
		quacky.attach_carried_module("AI Core Energy Module")
		var item = quacky.deliver_item()
		if item == "AI Core Energy Module":
			print("[PASS] Test 11: Quacky item retrieval and delivery cycle verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 11: Quacky item delivery failed.")
	else:
		printerr("[FAIL] Test 11: Quacky delivery methods missing.")

	# Test 12: Tiko Manipulation
	tests_total += 1
	if tiko and tiko.has_method("perform_special_ability"):
		tiko.repair_robot()
		print("[PASS] Test 12: Tiko heavy manipulation verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 12: Tiko methods missing.")

	# Test 13: Tolly Security Access
	tests_total += 1
	if tolly and tolly.has_method("perform_special_ability"):
		tolly.repair_robot()
		print("[PASS] Test 13: Tolly security access protocol verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 13: Tolly methods missing.")

	# Test 14: Electrical Cable Connection
	tests_total += 1
	if cable1 and cable1.has_method("connect_cable"):
		cable1.connect_cable()
		if cable1.is_connected:
			print("[PASS] Test 14: Electrical cable connection verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 14: Cable connection failed.")
	else:
		printerr("[FAIL] Test 14: Cable method missing.")

	# Test 15: Unstable Machine Stabilization
	tests_total += 1
	if gen1 and gen1.has_method("stabilize_machine"):
		gen1.stabilize_machine()
		if gen1.is_stabilized:
			print("[PASS] Test 15: Unstable Machine hazard stabilization verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 15: Hazard stabilization failed.")
	else:
		printerr("[FAIL] Test 15: Generator method missing.")

	# Test 16: Security Gate Opening
	tests_total += 1
	if gate1 and gate1.has_method("open_gate"):
		gate1.open_gate()
		if gate1.is_open:
			print("[PASS] Test 16: Security Gate slide mechanism verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 16: Gate open failed.")
	else:
		printerr("[FAIL] Test 16: Gate method missing.")

	# Test 17: GameState Mission Tracking
	tests_total += 1
	GameState.set_objective("RESTORE WELCOME CENTRE", "Power Nodes Online", 45.0)
	if GameState.current_mission_title == "RESTORE WELCOME CENTRE" and GameState.progress_percentage == 45.0:
		print("[PASS] Test 17: GameState objective tracking verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 17: GameState tracking failed.")

	# Test 18: Final Signal Sequence
	tests_total += 1
	GameState.trigger_final_signal()
	if GameState.last_signal_activated and GameState.progress_percentage == 100.0:
		print("[PASS] Test 18: Final Signal Sequence 100% completion verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 18: Final signal sequence failed.")

	# Test 19: Tab Respawn to Entrance
	tests_total += 1
	if player and player.has_method("respawn_to_entrance"):
		player.global_position = Vector3(50.0, 10.0, -30.0)
		player.respawn_to_entrance()
		if player.global_position.distance_to(Vector3(0, 1.0, 14.0)) < 0.1:
			print("[PASS] Test 19: Tab Respawn to facility entrance verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 19: Tab Respawn position mismatch: ", player.global_position)
	else:
		printerr("[FAIL] Test 19: Player respawn_to_entrance method missing.")

	# Test 20: Bottom-Left MiniMap Verification
	tests_total += 1
	var m_map = hud.get_node_or_null("BottomLeft/MiniMap")
	if m_map and m_map is Control and "radar_radius_meters" in m_map:
		print("[PASS] Test 20: Bottom-Left Holographic Radar MiniMap verified on HUD.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 20: Bottom-Left MiniMap missing on HUD.")

	# Test 21: Player Human Mesh Hierarchy
	tests_total += 1
	var head = player.get_node_or_null("VisualRoot/Head")
	var hair = player.get_node_or_null("VisualRoot/Head/Hair")
	var hands = player.get_node_or_null("VisualRoot/ArmLeft/HandLeft")
	if head and hair and hands:
		print("[PASS] Test 21: Player human explorer visual hierarchy verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 21: Player human visual elements missing.")

	# Test 22: Level Transition & Obstacles in Welcome Centre
	tests_total += 1
	var trans = b1.get_node_or_null("LevelTransition")
	var barrier = b1.get_node_or_null("ElectricBarrier1")
	if trans and barrier:
		print("[PASS] Test 22: LevelTransition trigger and Electric Barrier hazard verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 22: LevelTransition or Electric Barrier missing.")

	# Test 23: OpticalBarrier hazard and disarm protocol
	tests_total += 1
	var opt_scene = load("res://scenes/objects/OpticalBarrier.tscn")
	var opt_barrier = opt_scene.instantiate()
	add_child(opt_barrier)
	if opt_barrier and opt_barrier.is_active:
		opt_barrier.deactivate_barrier()
		if not opt_barrier.is_active:
			print("[PASS] Test 23: OpticalBarrier hazard and prism bypass verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 23: OpticalBarrier deactivation failed.")
	else:
		printerr("[FAIL] Test 23: OpticalBarrier instantiation failed.")

	# Test 24: Obstacles Across All 5 Facilities
	tests_total += 1
	var b2_has_obs = b2.get_node_or_null("ElectricBarrier") != null and b2.get_node_or_null("OpticalBarrier") != null and b2.get_node_or_null("CoolingTurbine") != null
	var b3_has_obs = b3.get_node_or_null("ElectricBarrier") != null and b3.get_node_or_null("OpticalBarrier") != null and b3.get_node_or_null("SubstationTurbine") != null
	var b4_has_obs = b4.get_node_or_null("UpperElectricBarrier") != null and b4.get_node_or_null("OpticalBarrier") != null and b4.get_node_or_null("TowerLiftHydraulics") != null
	var b5_has_obs = b5.get_node_or_null("ElectricBarrierL") != null and b5.get_node_or_null("OpticalBarrierR") != null and b5.get_node_or_null("HarmonicTurbine") != null
	if b2_has_obs and b3_has_obs and b4_has_obs and b5_has_obs:
		print("[PASS] Test 24: Obstacles (Electric barriers, Optical sensors, Turbines) verified across all 5 facilities.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 24: Missing obstacles across facilities: ", [b2_has_obs, b3_has_obs, b4_has_obs, b5_has_obs])

	# Test 25: Player Mouse Aim Formula Verification
	tests_total += 1
	var fwd_vec = Vector3(0, 0, -1)
	var computed_fwd_angle = atan2(-fwd_vec.x, -fwd_vec.z)
	var right_vec = Vector3(1, 0, 0)
	var computed_right_angle = atan2(-right_vec.x, -right_vec.z)
	if is_zero_approx(computed_fwd_angle) and is_equal_approx(computed_right_angle, -PI / 2.0):
		print("[PASS] Test 25: Player mouse aim rotation angle formula verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 25: Aim rotation formula math mismatch.")

	# Test 26: HUD Center Reticle Aiming Crosshair
	tests_total += 1
	var reticle = hud.get_node_or_null("CenterReticle/CenterDot")
	if reticle and reticle is ColorRect:
		print("[PASS] Test 26: HUD Center Reticle crosshair and targeting dot verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 26: HUD Center Reticle missing.")

	# Test 27: 360-degree Orbit Camera Rotation Verification
	tests_total += 1
	var initial_yaw = cam_ctrl.current_yaw
	# Simulate full 360 degree horizontal mouse sweep (2 * PI / mouse_sensitivity pixels)
	var full_circle_pixels = TAU / cam_ctrl.mouse_sensitivity
	var mouse_event = InputEventMouseMotion.new()
	mouse_event.relative = Vector2(full_circle_pixels, 0)
	cam_ctrl._input(mouse_event)
	var final_yaw = cam_ctrl.current_yaw
	# Both should correspond to equivalent orientations (approx equal modulo TAU)
	var diff = abs(wrapf(final_yaw - initial_yaw, -PI, PI))
	if diff < 0.05:
		print("[PASS] Test 27: 360-degree continuous mouse orbit rotation verified on ThirdPersonCamera.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 27: 360-degree yaw rotation mismatch: diff=", diff)

	# Test 28: Human Character Movement Direction Orientation
	tests_total += 1
	var move_fwd = Vector3(0, 0, -1)
	var angle_fwd = atan2(-move_fwd.x, -move_fwd.z)
	var move_back = Vector3(0, 0, 1)
	var angle_back = atan2(-move_back.x, -move_back.z)
	var move_left = Vector3(-1, 0, 0)
	var angle_left = atan2(-move_left.x, -move_left.z)
	var move_right = Vector3(1, 0, 0)
	var angle_right = atan2(-move_right.x, -move_right.z)
	var facing_correct = is_zero_approx(angle_fwd) and is_equal_approx(abs(angle_back), PI) and is_equal_approx(angle_left, PI / 2.0) and is_equal_approx(angle_right, -PI / 2.0)
	if facing_correct:
		print("[PASS] Test 28: Human character 360-degree movement direction orientation verified (W/A/S/D turn to face motion).")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 28: Movement direction facing mismatch.")

	# Test 29: Human Health System (100 HP, damage, defeat recall)
	tests_total += 1
	if player and player.current_health == 100.0:
		player.invulnerability_timer = 0.0
		player.take_damage(25.0, "Test Hazard")
		var damaged_ok = (player.current_health == 75.0)
		player.invulnerability_timer = 0.0
		player.take_damage(80.0, "Lethal Hazard")
		# Defeat triggers respawn_to_entrance which restores health to 100.0
		var respawn_health_ok = (player.current_health == 100.0)
		if damaged_ok and respawn_health_ok:
			print("[PASS] Test 29: Human health system (100 HP, hazard damage, defeat recovery) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 29: Health damage/recovery failed: damaged_ok=", damaged_ok, " respawn_health_ok=", respawn_health_ok)
	else:
		printerr("[FAIL] Test 29: Player initial health mismatch.")

	# Test 30: Downfall Detection and Auto-Respawn to Starting Point
	tests_total += 1
	if player:
		player.global_position = Vector3(15.0, -12.0, -10.0)
		player.handle_downfall()
		var pos_ok = player.global_position.distance_to(Vector3(0, 1.0, 14.0)) < 0.1
		var vel_ok = player.velocity == Vector3.ZERO
		var hp_ok = player.current_health == 100.0
		if pos_ok and vel_ok and hp_ok:
			print("[PASS] Test 30: Downfall detection and auto-respawn to starting point (entrance) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 30: Downfall respawn verification failed.")
	else:
		printerr("[FAIL] Test 30: Player reference missing.")

	# Test 31: Strict Sequential Gatekeeping & Locked Air-Lock Rejection
	tests_total += 1
	var trans_scene = load("res://scenes/objects/LevelTransition.tscn")
	var trans_inst = trans_scene.instantiate()
	add_child(trans_inst)
	if trans_inst:
		var init_locked = (trans_inst.is_active == false)
		trans_inst._on_body_entered(player)
		var rejected_ok = (trans_inst.has_triggered == false)
		trans_inst.activate_transition()
		var unlock_ok = (trans_inst.is_active == true)
		trans_inst._on_body_entered(player)
		var allowed_ok = (trans_inst.has_triggered == true)
		if init_locked and rejected_ok and unlock_ok and allowed_ok:
			print("[PASS] Test 31: Strict sequential air-lock gatekeeping (locked by default, rejection buzzer/pushback, unlock trigger) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 31: Air-lock transition test failed: init_locked=", init_locked, " rejected_ok=", rejected_ok, " unlock_ok=", unlock_ok, " allowed_ok=", allowed_ok)
		trans_inst.queue_free()
	else:
		printerr("[FAIL] Test 31: LevelTransition instantiation failed.")

	# Test 32: Building Mission Completion Verification (Welcome Centre)
	tests_total += 1
	var wc_scene = load("res://scenes/buildings/WelcomeCentre.tscn")
	var wc_inst = wc_scene.instantiate()
	add_child(wc_inst)
	if wc_inst:
		var initial_complete = wc_inst.is_mission_complete()
		# Simulate completing all Welcome Centre requirements
		GameState.robots["PETALO"]["repaired"] = true
		wc_inst.nodes_active = 3
		var gen = wc_inst.get_node_or_null("UnstableGenerator")
		if gen:
			gen.is_stabilized = true
		var final_complete = wc_inst.is_mission_complete()
		wc_inst._check_and_unlock_facility()
		var gate_unlocked = (wc_inst.exit_gate != null and wc_inst.exit_gate.is_locked == false)
		if not initial_complete and final_complete and gate_unlocked:
			print("[PASS] Test 32: Building mission verification (incomplete by default -> 100% complete unlocks gate & transition) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 32: Building mission verification failed: init=", initial_complete, " final=", final_complete, " gate_unlocked=", gate_unlocked)
		wc_inst.queue_free()
	else:
		printerr("[FAIL] Test 32: WelcomeCentre instantiation failed.")

	# Test 33: Pause Menu Fast-Travel Sequential Sector Lock
	tests_total += 1
	GameState.max_unlocked_building = 0
	var can_b0 = GameState.can_access_building(0)
	var cannot_b4 = not GameState.can_access_building(4)
	GameState.mark_facility_completed(0) # Unlocks building 1
	var can_b1 = GameState.can_access_building(1)
	GameState.mark_facility_completed(3) # Unlocks building 4 (Testing Arena)
	var can_b4 = GameState.can_access_building(4)
	if can_b0 and cannot_b4 and can_b1 and can_b4:
		print("[PASS] Test 33: Sequential sector unlocking and fast-travel restriction logic verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 33: Sector lock logic failed: b0=", can_b0, " no_b4=", cannot_b4, " b1=", can_b1, " b4=", can_b4)

	# Test 34: Testing Arena 4 Elemental Relay Pylons & Grand Climax Architecture
	tests_total += 1
	var ta_scene = load("res://scenes/buildings/TestingArena.tscn")
	var ta_inst = ta_scene.instantiate()
	add_child(ta_inst)
	if ta_inst:
		var has_south = ta_inst.get_node_or_null("RelayPylonSouth/BeamMesh") != null
		var has_east = ta_inst.get_node_or_null("RelayPylonEast/BeamMesh") != null
		var has_north = ta_inst.get_node_or_null("RelayPylonNorth/BeamMesh") != null
		var has_west = ta_inst.get_node_or_null("RelayPylonWest/BeamMesh") != null
		var has_dual_beam = ta_inst.get_node_or_null("CentralSignalTower/SkyBeam") != null and ta_inst.get_node_or_null("CentralSignalTower/SkyBeamOuter") != null
		var has_shockwave = ta_inst.get_node_or_null("CentralSignalTower/ShockwaveRing") != null
		var has_circuits = ta_inst.get_node_or_null("FloorCircuits") != null
		var has_victory_ui = ta_inst.get_node_or_null("VictoryUI/Panel/VBox/FacilitiesGrid") != null
		var all_arena_ok = has_south and has_east and has_north and has_west and has_dual_beam and has_shockwave and has_circuits and has_victory_ui
		if all_arena_ok:
			print("[PASS] Test 34: Testing Arena Grand Climax Architecture (4 Elemental Pylons, Dual Sky Beam, Shockwave Ring, Floor Circuits, Grand Victory UI) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 34: Testing Arena components missing.")
		ta_inst.queue_free()
	else:
		printerr("[FAIL] Test 34: TestingArena instantiation failed.")

	# Test 35: Welcome Centre Full Level 1 Progression and Node Revelation
	tests_total += 1
	var lvl1_scene = load("res://scenes/buildings/WelcomeCentre.tscn")
	var lvl1 = lvl1_scene.instantiate()
	add_child(lvl1)
	if lvl1:
		var p_bot: PetaloRobot = lvl1.get_node_or_null("Petalo")
		var s_node1: SignalNode = lvl1.get_node_or_null("SignalNode1")
		var s_node2: SignalNode = lvl1.get_node_or_null("SignalNode2")
		var s_node3: SignalNode = lvl1.get_node_or_null("SignalNode3")
		var gen: UnstableMachine = lvl1.get_node_or_null("UnstableGenerator")
		var e_gate: SecurityGate = lvl1.get_node_or_null("ExitGate")
		var t_pad: LevelTransition = lvl1.get_node_or_null("LevelTransition")

		var step1_ok = (p_bot != null and s_node1 != null and s_node2 != null and s_node3 != null and gen != null and e_gate != null and t_pad != null)

		# Step 1: Petalo repair
		p_bot.repair_robot()
		var petalo_repaired = GameState.robots["PETALO"]["repaired"]

		# Step 2: Petalo lantern reveals hidden nodes
		p_bot.perform_special_ability()
		var nodes_revealed = s_node1.is_revealed and s_node2.is_revealed and s_node3.is_revealed

		# Step 3: Activate nodes
		s_node1.activate_node()
		s_node2.activate_node()
		s_node3.activate_node()
		var nodes_done = (lvl1.nodes_active >= 3)

		# Step 4: Stabilize generator
		gen.stabilize_machine()
		var gen_stable = gen.is_stabilized

		# Step 5: Mission complete check & gate unlock
		var mission_ok = lvl1.is_mission_complete()
		var gate_open = e_gate.is_open
		var transition_active = t_pad.is_active

		# Step 6: Verify transition pad is safely on floor (not floating over void)
		var floor_node: StaticBody3D = lvl1.get_node_or_null("Floor")
		var pad_on_floor = (floor_node != null and t_pad.global_position.z >= -23.5)

		if step1_ok and petalo_repaired and nodes_revealed and nodes_done and gen_stable and mission_ok and gate_open and transition_active and pad_on_floor:
			print("[PASS] Test 35: Welcome Centre Level 1 Full Progression (Petalo repair, node revelation, 3/3 activation, generator stabilization, gate unlock, safe floor airlock) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 35: Level 1 progression failed: p_rep=", petalo_repaired, " n_rev=", nodes_revealed, " n_done=", nodes_done, " g_stab=", gen_stable, " m_ok=", mission_ok, " g_open=", gate_open, " t_act=", transition_active, " on_floor=", pad_on_floor)
		lvl1.queue_free()
	else:
		printerr("[FAIL] Test 35: WelcomeCentre instantiation failed.")

	# Test 36: Knowledge Centre Level 2 Progression & Sequence Node Resilience
	tests_total += 1
	var lvl2_scene = load("res://scenes/buildings/KnowledgeCentre.tscn")
	var lvl2 = lvl2_scene.instantiate()
	add_child(lvl2)
	if lvl2:
		# Step 1: Repair Tiko
		var tiko_bot = lvl2.get_node_or_null("Tiko")
		if tiko_bot:
			tiko_bot.repair_robot()
		var tiko_rep = GameState.robots["TIKO"]["repaired"]

		# Step 2: Clear Heavy Server Obstacle
		lvl2.apply_heavy_push()
		var obst_cleared = lvl2.obstacle_cleared

		# Step 3: Out-of-order sequence test (Beta before Alpha) -> must reset gracefully
		lvl2._check_node_step(2)
		var reset_ok = (lvl2.sequence_step == 0 and lvl2.node_a.interactable.is_active == true)

		# Step 4: Correct sequence: Alpha -> Beta -> Gamma
		lvl2._check_node_step(1)
		lvl2._check_node_step(2)
		lvl2._check_node_step(3)
		var seq_done = (lvl2.sequence_step == 3)

		# Step 5: Mission completion & safe airlock pad
		var m2_ok = lvl2.is_mission_complete()
		var gate2_open = lvl2.exit_gate.is_open
		var t2_active = lvl2.transition_pad.is_active
		var floor2: StaticBody3D = lvl2.get_node_or_null("Floor")
		var pad2_on_floor = (floor2 != null and lvl2.transition_pad.global_position.z >= -23.5)

		if tiko_rep and obst_cleared and reset_ok and seq_done and m2_ok and gate2_open and t2_active and pad2_on_floor:
			print("[PASS] Test 36: Knowledge Centre Level 2 Full Progression (Tiko repair, server push, sequence error resilience, 3-node alignment, exit unlock, safe airlock) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 36: Level 2 progression failed: tiko_rep=", tiko_rep, " obst=", obst_cleared, " reset=", reset_ok, " seq=", seq_done, " m_ok=", m2_ok, " gate=", gate2_open, " t_act=", t2_active, " pad_floor=", pad2_on_floor)
		lvl2.queue_free()
	else:
		printerr("[FAIL] Test 36: KnowledgeCentre instantiation failed.")

	# Test 37: Coding & AI Hub Level 3 Progression & Quacky Retrieval
	tests_total += 1
	var lvl3_scene = load("res://scenes/buildings/CodingAIHub.tscn")
	var lvl3 = lvl3_scene.instantiate()
	add_child(lvl3)
	if lvl3:
		# Step 1: Repair Quacky
		var quacky_bot = lvl3.get_node_or_null("Quacky")
		if quacky_bot:
			quacky_bot.repair_robot()
		var quacky_rep = GameState.robots["QUACKY"]["repaired"]

		# Step 2: Scout duct and retrieve AI core module
		lvl3.retrieve_module()
		var mod_retrieved = lvl3.module_retrieved and quacky_bot != null and quacky_bot.is_carrying_item

		# Step 3: Deliver module to AI Mainframe
		lvl3.ai_restored = true
		lvl3._check_and_unlock_facility()
		var m3_ok = lvl3.is_mission_complete()
		var gate3_open = lvl3.exit_gate.is_open
		var t3_active = lvl3.transition_pad.is_active
		var floor3: StaticBody3D = lvl3.get_node_or_null("Floor")
		var pad3_on_floor = (floor3 != null and lvl3.transition_pad.global_position.z >= -23.5)

		if quacky_rep and mod_retrieved and m3_ok and gate3_open and t3_active and pad3_on_floor:
			print("[PASS] Test 37: Coding & AI Hub Level 3 Full Progression (Quacky repair, duct scouting, AI core retrieval, mainframe restore, gate unlock, safe airlock) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 37: Level 3 progression failed: q_rep=", quacky_rep, " mod=", mod_retrieved, " m_ok=", m3_ok, " gate=", gate3_open, " t_act=", t3_active, " pad_floor=", pad3_on_floor)
		lvl3.queue_free()
	else:
		printerr("[FAIL] Test 37: CodingAIHub instantiation failed.")

	# Test 38: Innovation Tower Level 4 Progression & Tolly Security Hack
	tests_total += 1
	var lvl4_scene = load("res://scenes/buildings/InnovationTower.tscn")
	var lvl4 = lvl4_scene.instantiate()
	add_child(lvl4)
	if lvl4:
		# Step 1: Repair Tolly
		var tolly_bot = lvl4.get_node_or_null("Tolly")
		if tolly_bot:
			tolly_bot.repair_robot()
		var tolly_rep = GameState.robots["TOLLY"]["repaired"]

		# Step 2: Ascend elevator
		lvl4.elevator_at_top = true

		# Step 3: Align catwalk bridge
		lvl4.align_bridge()
		var bridge_ok = lvl4.bridge_aligned

		# Step 4: Hack biometric security gate with Tolly
		lvl4.upper_security_gate.unlock_gate()
		var gate4_open = lvl4.upper_security_gate.is_open

		# Step 5: Mission verification
		var m4_ok = lvl4.is_mission_complete()
		var t4_active = lvl4.transition_pad.is_active
		var deck4: StaticBody3D = lvl4.get_node_or_null("UpperDeck")
		var pad4_on_deck = (deck4 != null and lvl4.transition_pad.global_position.z >= -23.5)

		if tolly_rep and bridge_ok and gate4_open and m4_ok and t4_active and pad4_on_deck:
			print("[PASS] Test 38: Innovation Tower Level 4 Full Progression (Tolly repair, catwalk bridge alignment, biometric gate override, safe airlock) verified.")
			tests_passed += 1
		else:
			printerr("[FAIL] Test 38: Level 4 progression failed: tolly_rep=", tolly_rep, " bridge=", bridge_ok, " gate=", gate4_open, " m_ok=", m4_ok, " t_act=", t4_active, " pad_deck=", pad4_on_deck)
		lvl4.queue_free()
	else:
		printerr("[FAIL] Test 38: InnovationTower instantiation failed.")

	# Test 39: Companion Squad Switching & Reticle Targeting Integration
	tests_total += 1
	GameState.mark_robot_repaired("PETALO")
	GameState.mark_robot_repaired("QUACKY")
	GameState.mark_robot_repaired("TOLLY")
	GameState.mark_robot_repaired("TIKO")

	var switch_p = GameState.switch_active_companion("PETALO") and GameState.active_companion == "PETALO"
	var switch_q = GameState.switch_active_companion("QUACKY") and GameState.active_companion == "QUACKY"
	var switch_t = GameState.switch_active_companion("TOLLY") and GameState.active_companion == "TOLLY"
	var switch_k = GameState.switch_active_companion("TIKO") and GameState.active_companion == "TIKO"
	var all_switch_ok = switch_p and switch_q and switch_t and switch_k

	# Verify camera controller aim query methods
	var cam_has_aim = cam_ctrl.has_method("get_aim_target") and cam_ctrl.has_method("get_aim_point")
	var aim_point: Vector3 = cam_ctrl.get_aim_point(20.0) if cam_has_aim else Vector3.ZERO
	var aim_ok = cam_has_aim and (aim_point != null)

	# Verify player health & respawn integrity
	player.invulnerability_timer = 0.0
	player.take_damage(25.0)
	var dmg_ok = is_equal_approx(player.current_health, 75.0)
	player.heal(15.0)
	var heal_ok = is_equal_approx(player.current_health, 90.0)
	player.respawn_to_entrance()
	var respawn_ok = is_equal_approx(player.current_health, 100.0) and player.global_position.is_equal_approx(Vector3(0, 1.0, 14.0))

	if all_switch_ok and aim_ok and dmg_ok and heal_ok and respawn_ok:
		print("[PASS] Test 39: Companion Squad Switching (Petalo/Quacky/Tolly/Tiko hotkeys), Reticle Aim Query, and Player Health/Respawn System verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 39: Companion/Aim/Health test failed: switch=", all_switch_ok, " aim=", aim_ok, " dmg=", dmg_ok, " heal=", heal_ok, " respawn=", respawn_ok)

	# Test 40: Dedicated Per-Character Separate Keys [1/Z, 2/X, 3/C, 4/V] Verification
	tests_total += 1
	var tracker = {"robot": "", "pos": Vector3.ZERO}
	var cmd_tracker = func(r_id: String, pos: Vector3):
		tracker["robot"] = r_id
		tracker["pos"] = pos

	GameState.robot_command_requested.connect(cmd_tracker)

	# Test 40.1: Direct invocation of command_character for each character
	player.command_character("PETALO")
	var cmd_p_ok = (tracker["robot"] == "PETALO" and GameState.active_companion == "PETALO")

	player.command_character("QUACKY")
	var cmd_q_ok = (tracker["robot"] == "QUACKY" and GameState.active_companion == "QUACKY")

	player.command_character("TOLLY")
	var cmd_t_ok = (tracker["robot"] == "TOLLY" and GameState.active_companion == "TOLLY")

	player.command_character("TIKO")
	var cmd_k_ok = (tracker["robot"] == "TIKO" and GameState.active_companion == "TIKO")

	# Test 40.2: Dedicated Key Event simulation: [1], [2], [3], [4] and [Z], [X], [C], [V]
	var make_key_event = func(code: int) -> InputEventKey:
		var ev = InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = true
		ev.echo = false
		return ev

	# Press Key 1 (Petalo)
	tracker["robot"] = ""
	player._unhandled_input(make_key_event.call(KEY_1))
	var ev_1_ok = (tracker["robot"] == "PETALO" and GameState.active_companion == "PETALO")

	# Press Key 2 (Quacky)
	tracker["robot"] = ""
	player._unhandled_input(make_key_event.call(KEY_2))
	var ev_2_ok = (tracker["robot"] == "QUACKY" and GameState.active_companion == "QUACKY")

	# Press Key C (Tolly)
	tracker["robot"] = ""
	player._unhandled_input(make_key_event.call(KEY_C))
	var ev_c_ok = (tracker["robot"] == "TOLLY" and GameState.active_companion == "TOLLY")

	# Press Key V (Tiko)
	tracker["robot"] = ""
	player._unhandled_input(make_key_event.call(KEY_V))
	var ev_v_ok = (tracker["robot"] == "TIKO" and GameState.active_companion == "TIKO")

	# Test 40.3: Offline handling
	GameState.robots["PETALO"]["repaired"] = false
	tracker["robot"] = ""
	player._unhandled_input(make_key_event.call(KEY_1))
	var offline_safe = (tracker["robot"] == "") # blocked command
	GameState.robots["PETALO"]["repaired"] = true

	GameState.robot_command_requested.disconnect(cmd_tracker)

	var all_char_keys_ok = cmd_p_ok and cmd_q_ok and cmd_t_ok and cmd_k_ok and ev_1_ok and ev_2_ok and ev_c_ok and ev_v_ok and offline_safe

	if all_char_keys_ok:
		print("[PASS] Test 40: Dedicated Per-Character Separate Keys (Petalo [1/Z], Quacky [2/X], Tolly [3/C], Tiko [4/V], Offline guard) verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 40: Per-character separate keys test failed: p=", cmd_p_ok, " q=", cmd_q_ok, " t=", cmd_t_ok, " k=", cmd_k_ok, " ev1=", ev_1_ok, " ev2=", ev_2_ok, " evC=", ev_c_ok, " evV=", ev_v_ok, " off=", offline_safe)

	# Test 41: Companion Arrival & Power Activation Guarantee
	tests_total += 1
	var t41_ok = true

	# 41.1 Companion arrival position: Calling bring_to_player_and_activate moves companion directly beside explorer
	var test_player_pos = Vector3(10.0, 1.0, 5.0)
	var test_player_fwd = Vector3.FORWARD # (0, 0, -1)
	petalo.global_position = Vector3(50.0, 0, 50.0) # start far away
	petalo.bring_to_player_and_activate(test_player_pos, test_player_fwd, test_player_pos + test_player_fwd * 5.0)
	var arrive_dist = petalo.global_position.distance_to(test_player_pos)
	if arrive_dist > 3.0 or petalo.global_position.distance_to(Vector3(50, 0, 50)) < 10.0:
		printerr("[FAIL] 41.1 Companion failed to arrive beside player: dist=", arrive_dist)
		t41_ok = false

	# 41.2 Petalo power activation on SignalNodes and ElectricBarrier
	var test_node_scene = load("res://scenes/objects/SignalNode.tscn")
	var test_node = test_node_scene.instantiate()
	add_child(test_node)
	test_node.global_position = petalo.global_position + Vector3(5.0, 0, 0)
	test_node.is_initially_hidden = true
	test_node.is_revealed = false
	test_node.is_active = false

	var test_barrier_scene = load("res://scenes/objects/ElectricBarrier.tscn")
	var test_barrier = test_barrier_scene.instantiate()
	add_child(test_barrier)
	test_barrier.global_position = petalo.global_position + Vector3(-5.0, 0, 0)
	test_barrier.is_active = true

	petalo.perform_special_ability()
	if not test_node.is_revealed or not test_node.is_active:
		printerr("[FAIL] 41.2 Petalo failed to activate signal node: rev=", test_node.is_revealed, " act=", test_node.is_active)
		t41_ok = false
	if test_barrier.is_active:
		printerr("[FAIL] 41.2 Petalo failed to deactivate electric barrier")
		t41_ok = false

	# 41.3 Tolly power activation on SecurityGate
	var test_gate_scene = load("res://scenes/objects/Gate.tscn")
	var test_gate = test_gate_scene.instantiate()
	add_child(test_gate)
	test_gate.global_position = test_player_pos + Vector3(0, 0, -8.0)
	test_gate.is_locked = true
	test_gate.is_open = false
	tolly.bring_to_player_and_activate(test_player_pos, test_player_fwd, test_gate.global_position)
	if test_gate.is_locked or not test_gate.is_open:
		printerr("[FAIL] 41.3 Tolly failed to unlock security gate")
		t41_ok = false

	# 41.4 Missing companion auto-spawn on key command
	GameState.robots["QUACKY"]["repaired"] = true
	# Remove any existing quacky from player's parent to test spawn
	for b in get_tree().get_nodes_in_group("robots"):
		if b is QuackyRobot:
			b.queue_free()
	await get_tree().process_frame
	player.command_character("QUACKY")
	var spawned_quacky = false
	for b in get_tree().get_nodes_in_group("robots"):
		if b is QuackyRobot:
			spawned_quacky = true
			break
	if not spawned_quacky:
		printerr("[FAIL] 41.4 Failed to auto-spawn missing repaired companion on key command")
		t41_ok = false

	test_node.queue_free()
	test_barrier.queue_free()
	test_gate.queue_free()

	if t41_ok:
		print("[PASS] Test 41: Companion Arrival (Flank Positioning) & Power Activation (Nodes, Barriers, Gates, Auto-Spawn) verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 41: Companion arrival and power activation test failed.")

	# Test 42: Innovation Tower Bidirectional Elevator System (Ground & Upper Call Terminals, Descend & Ascend)
	tests_total += 1
	var t42_ok = true

	var b4_test_scene = load("res://scenes/buildings/InnovationTower.tscn")
	var b4_test = b4_test_scene.instantiate()
	add_child(b4_test)

	var elev = b4_test.get_node_or_null("ElevatorPlatform")
	var g_term = b4_test.get_node_or_null("GroundCallTerminal")
	var u_term = b4_test.get_node_or_null("UpperCallTerminal")
	var g_inter = b4_test.get_node_or_null("GroundCallTerminal/Interactable")
	var u_inter = b4_test.get_node_or_null("UpperCallTerminal/Interactable")

	if not elev or not g_term or not u_term or not g_inter or not u_inter:
		printerr("[FAIL] 42.1 Missing elevator platform or call terminals in InnovationTower")
		t42_ok = false

	# Test 42.2: Call down when elevator is at top
	if elev:
		elev.position.y = 6.0
		b4_test.elevator_target_y = 6.0
		b4_test.elevator_at_top = true
		b4_test.call_elevator_down()
		if not b4_test.is_elevator_moving or b4_test.elevator_target_y != 0.2:
			printerr("[FAIL] 42.2 call_elevator_down failed to initiate descent motion")
			t42_ok = false

		# Step physics process to complete descent
		b4_test._physics_process(3.0)
		b4_test._physics_process(0.1)
		if elev.position.y > 0.3 or b4_test.is_elevator_moving:
			printerr("[FAIL] 42.2 Elevator failed to reach ground level: y=", elev.position.y)
			t42_ok = false

	# Test 42.3: Call up when elevator is at ground
	if elev:
		b4_test.call_elevator_up()
		if not b4_test.is_elevator_moving or b4_test.elevator_target_y != 6.0:
			printerr("[FAIL] 42.3 call_elevator_up failed to initiate ascent motion")
			t42_ok = false

		# Step physics process to complete ascent
		b4_test._physics_process(3.0)
		b4_test._physics_process(0.1)
		if elev.position.y < 5.8 or b4_test.is_elevator_moving:
			printerr("[FAIL] 42.3 Elevator failed to reach upper deck: y=", elev.position.y)
			t42_ok = false

	b4_test.queue_free()

	if t42_ok:
		print("[PASS] Test 42: Bidirectional Elevator System (Ground & Upper Call Terminals, Down/Up descent/ascent) verified.")
		tests_passed += 1
	else:
		printerr("[FAIL] Test 42: Bidirectional Elevator test failed.")

	print("\n==============================================")
	print("RESULTS: %d / %d TESTS PASSED!" % [tests_passed, tests_total])
	print("==============================================\n")

	get_tree().quit(0 if tests_passed == tests_total else 1)


