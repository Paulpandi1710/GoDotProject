extends SceneTree

func _init():
	print("========================================")
	print("DSA ACADEMY — COMPREHENSIVE AUTOMATED TEST")
	print("========================================")
	
	var LM = load("res://lesson_manager.gd").new()
	root.add_child(LM)
	
	var ui = load("res://game_ui.gd").new()
	root.add_child(ui)
	ui._ready()
	
	var arr = load("res://array_system.gd").new()
	root.add_child(arr)
	
	LM.setup(arr, ui)
	LM.start_lesson()
	assert(LM.in_hub == true, "Must boot into Hub mode")
	LM.launch_lesson(0)
	assert(LM.in_hub == false, "Must exit Hub on lesson launch")
	
	# --- LEVEL 1: LINEAR SEARCH ---
	print("\n>>> TESTING LEVEL 1: LINEAR SEARCH")
	var l1 = LM.active_lesson
	assert(l1 != null, "Level 1 must be active")
	
	# Skip to Pseudocode
	l1.state = l1.State.PSEUDOCODE
	LM.handle_action("START")
	assert(l1.state == l1.State.CODE_SHOW_1, "Expected CODE_SHOW_1")
	assert(ui._story_code_panel.visible == true, "Code panel must be visible in step 1")
	print("  ✓ CODE_SHOW_1 active, code panel visible")
	
	# Test advance via START (e.g. Space key)
	LM.handle_action("START")
	assert(l1.state == l1.State.CODE_SHOW_2, "Expected CODE_SHOW_2 via START")
	print("  ✓ Advanced to CODE_SHOW_2 via Space/START")
	
	# Test advance via FIRST (e.g. button click or '1' key)
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.CODE_SHOW_3, "Expected CODE_SHOW_3 via FIRST")
	print("  ✓ Advanced to CODE_SHOW_3 via '1'/FIRST")
	
	# Advance to Complexity
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.COMPLEXITY, "Expected COMPLEXITY")
	assert(ui._story_overlay.visible == true, "Story overlay must be visible on Complexity")
	assert(ui._story_code_panel.visible == false, "Code panel must be hidden on Complexity")
	print("  ✓ Advanced to COMPLEXITY, overlay visible, code panel hidden")
	
	# Advance from Complexity to Challenge Intro
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.CHALLENGE_INTRO, "Expected CHALLENGE_INTRO via FIRST/START")
	print("  ✓ Advanced to CHALLENGE_INTRO")

	# Advance to Challenge Predict
	LM.handle_action("START")
	assert(l1.state == l1.State.CHALLENGE_PREDICT, "Expected CHALLENGE_PREDICT via START")
	print("  ✓ Advanced to CHALLENGE_PREDICT")

	# Predict 5 comparisons
	LM.handle_action("MIDDLE")
	assert(l1.state == l1.State.CHALLENGE_SEARCHING, "Expected CHALLENGE_SEARCHING")
	assert(l1.challenge_prediction == 5, "Expected prediction of 5")
	print("  ✓ Prediction registered, CHALLENGE_SEARCHING active")

	# Advance to Challenge Result
	l1.state = l1.State.CHALLENGE_RESULT
	LM.handle_action("START")
	assert(l1.state == l1.State.LEVEL_COMPLETE, "Expected LEVEL_COMPLETE via START from CHALLENGE_RESULT")
	assert(ui._story_overlay.visible == true, "Overlay must remain open on Level Complete")
	print("  ✓ Advanced to LEVEL_COMPLETE")

	# Complete Level 1 -> FINISHED
	LM.handle_action("START")
	assert(l1.state == l1.State.FINISHED, "Level 1 must be in FINISHED state")
	print("  ✓ Level 1 marked FINISHED, emitting lesson_finished...")
	LM.handle_action("START")
	
	# Wait for chapter transition
	var timer = create_timer(3.4)
	await timer.timeout
	
	# --- LEVEL 2: BINARY SEARCH ---
	print("\n>>> TESTING LEVEL 2: BINARY SEARCH")
	assert(LM.current_lesson_index == 1, "Expected lesson index 1")
	var l2 = LM.active_lesson
	assert(l2 != null, "Level 2 must be active")
	print("  ✓ BinarySearchLesson loaded: ", l2.get_script().resource_path)
	
	l2.state = l2.State.PSEUDOCODE
	LM.handle_action("START")
	assert(l2.state == l2.State.CODE_SHOW_1, "Expected CODE_SHOW_1 in Level 2")
	assert(ui._story_code_panel.visible == true, "Code panel must be visible in Level 2")
	print("  ✓ Level 2 C Code step 1 visible")
	
	LM.handle_action("START")
	assert(l2.state == l2.State.CODE_SHOW_2, "Expected CODE_SHOW_2 in Level 2")
	LM.handle_action("FIRST")
	assert(l2.state == l2.State.CODE_SHOW_3, "Expected CODE_SHOW_3 in Level 2")
	LM.handle_action("FIRST")
	assert(l2.state == l2.State.COMPLEXITY, "Expected COMPLEXITY in Level 2")
	assert(ui._story_overlay.visible == true, "Overlay visible on Level 2 Complexity")
	print("  ✓ Level 2 C Code steps 2 & 3 & Complexity succeeded")
	
	LM.handle_action("START")
	assert(l2.state == l2.State.LEVEL_COMPLETE, "Expected Level 2 Complete")
	LM.handle_action("START")
	assert(l2.state == l2.State.FINISHED, "Level 2 must be FINISHED")
	print("  ✓ Level 2 complete, awaiting chapter transition...")
	
	timer = create_timer(3.4)
	await timer.timeout
	
	# --- LEVEL 3: BUBBLE SORT ---
	print("\n>>> TESTING LEVEL 3: BUBBLE SORT")
	assert(LM.current_lesson_index == 2, "Expected lesson index 2")
	var l3 = LM.active_lesson
	assert(l3 != null, "Level 3 must be active")
	print("  ✓ BubbleSortLesson loaded: ", l3.get_script().resource_path)
	
	l3.state = l3.State.PSEUDOCODE
	LM.handle_action("START")
	assert(l3.state == l3.State.CODE_SHOW_1, "Expected CODE_SHOW_1 in Level 3")
	assert(ui._story_code_panel.visible == true, "Code panel must be visible in Level 3")
	print("  ✓ Level 3 C Code step 1 visible")
	
	LM.handle_action("FIRST")
	assert(l3.state == l3.State.CODE_SHOW_2, "Expected CODE_SHOW_2 in Level 3")
	LM.handle_action("START")
	assert(l3.state == l3.State.CODE_SHOW_3, "Expected CODE_SHOW_3 in Level 3")
	LM.handle_action("FIRST")
	assert(l3.state == l3.State.COMPLEXITY, "Expected COMPLEXITY in Level 3")
	assert(ui._story_overlay.visible == true, "Overlay visible on Level 3 Complexity")
	print("  ✓ Level 3 C Code steps 2 & 3 & Complexity succeeded")
	
	LM.handle_action("START")
	assert(l3.state == l3.State.LEVEL_COMPLETE, "Expected Level 3 Complete")
	LM.handle_action("START")
	assert(l3.state == l3.State.FINISHED, "Level 3 must be FINISHED")
	
	print("\n========================================")
	print("🎉 ALL TESTS PASSED! ZERO GLITCHES & ZERO SOFTLOCKS!")
	print("========================================")
	quit()
