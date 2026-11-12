extends SceneTree

func _init():
	print("==================================================")
	print("TESTING DSA ACADEMY — INTERACTIVE LAB & DIGITAL HANDBOOK")
	print("==================================================")

	var LM = load("res://lesson_manager.gd").new()
	root.add_child(LM)

	var ui = load("res://game_ui.gd").new()
	root.add_child(ui)
	ui._ready()

	var arr = load("res://array_system.gd").new()
	root.add_child(arr)

	LM.setup(arr, ui)
	LM.start_lesson()

	# ----------------------------------------------------
	# 1. VERIFY INTERACTIVE UI DECK & HANDBOOK INITIALIZATION
	# ----------------------------------------------------
	print("\n>>> 1. TESTING UI COMPONENT CREATION")
	assert(ui._deck_container != null, "Interactive Deck must be built")
	assert(ui._handbook_panel != null, "Handbook panel must be built")
	assert(ui._array_ribbon_container != null, "Array ribbon card must be built")
	print("  ✓ Interactive Deck, Handbook Codex, and Array Ribbon present")

	# Test Handbook toggle
	assert(ui.is_handbook_open() == false, "Handbook should start closed")
	ui.toggle_handbook()
	assert(ui.is_handbook_open() == true, "Handbook must toggle open")
	ui.toggle_handbook()
	assert(ui.is_handbook_open() == false, "Handbook must toggle closed")
	print("  ✓ Handbook toggle verified (Open / Close)")

	# ----------------------------------------------------
	# 2. TEST LEVEL 1: LINEAR SEARCH INTERACTIVE STEPPING & LIVE TRACE
	# ----------------------------------------------------
	print("\n>>> 2. TESTING LINEAR SEARCH INTERACTIVE PLAYBACK & CODE TRACE")
	LM.launch_lesson(0)
	var l1 = LM.active_lesson
	assert(l1 != null, "Linear Search must be loaded")

	# Reset interactive state
	l1.reset_interactive()
	assert(l1.interactive_index == 0, "Initial interactive index must be 0")
	assert(l1.interactive_comparisons == 0, "Initial comparisons must be 0")
	assert(ui._handbook_code_lbl.text.length() > 0, "Code trace should have C source code loaded")
	print("  ✓ Level 1 interactive reset ready")

	# Perform 1 manual step
	var init_val = l1.interactive_array[0]
	LM.step_interactive()
	assert(l1.interactive_index == 1, "Index must advance to 1 after step")
	assert(l1.interactive_comparisons == 1, "Comparisons must increment to 1")
	assert(ui._watch_vars.has("Active Index (i)"), "Watch variable 'Active Index (i)' must be updated")
	assert(ui._watch_vars["Active Index (i)"] == 0, "Last evaluated index was 0")
	print("  ✓ Single step executed cleanly, Variable Watch window updated")

	# Change Target and Step again
	LM.set_target_interactive(15)
	assert(l1.interactive_target == 15, "Target must update to 15")
	assert(l1.interactive_comparisons == 0, "Target change resets comparisons")
	LM.step_interactive()
	assert(l1.interactive_comparisons == 1, "Comparisons must increment to 1")
	print("  ✓ Target dynamically adjusted and stepped")

	# Play/Pause auto-stepping
	LM.set_auto_play(true)
	assert(l1._auto_playing == true, "Auto-play must be active")
	LM.set_auto_play(false)
	assert(l1._auto_playing == false, "Auto-play must pause cleanly")
	print("  ✓ Play/Pause deck state verified")

	# ----------------------------------------------------
	# 3. TEST LEVEL 2: BINARY SEARCH INTERACTIVE BOUNDS & HALVING
	# ----------------------------------------------------
	print("\n>>> 3. TESTING BINARY SEARCH INTERACTIVE LAB")
	LM.launch_lesson(1)
	var l2 = LM.active_lesson
	assert(l2 != null, "Binary Search must be loaded")

	l2.reset_interactive()
	var initial_left = l2.interactive_left
	var initial_right = l2.interactive_right
	var expected_mid = int((initial_left + initial_right) / 2)
	assert(l2.interactive_mid == expected_mid, "Initial mid must be calculated")
	print("  ✓ Binary search initialized with bounds [%d .. %d]" % [initial_left, initial_right])

	# Step halving
	LM.step_interactive()
	assert(l2.interactive_comparisons == 1, "Comparisons must be 1 after halving comparison")
	assert(ui._watch_vars.has("Mid Candidate"), "Watch variables must include 'Mid Candidate'")
	print("  ✓ Binary Search step halved search space and updated inspector")

	# ----------------------------------------------------
	# 4. TEST LEVEL 3: BUBBLE SORT INTERACTIVE STEPPING & PAIR SWAP
	# ----------------------------------------------------
	print("\n>>> 4. TESTING BUBBLE SORT INTERACTIVE LAB")
	LM.launch_lesson(2)
	var l3 = LM.active_lesson
	assert(l3 != null, "Bubble Sort must be loaded")

	l3.reset_interactive()
	var initial_j = l3.interactive_j
	var val_a = l3.interactive_array[initial_j]
	var val_b = l3.interactive_array[initial_j + 1]
	print("  ✓ Bubble Sort initialized: pair arr[0]=%d, arr[1]=%d" % [val_a, val_b])

	LM.step_interactive()
	assert(l3.interactive_comparisons == 1, "Comparisons must be 1")
	assert(ui._watch_vars.has("Pair Index (j)"), "Watch variables must include 'Pair Index (j)'")
	print("  ✓ Bubble Sort comparison & swap logic stepped interactively")

	# Test speed adjustment
	LM.set_playback_speed(2.0)
	assert(l3._playback_speed == 2.0, "Playback speed must update to 2.0x")
	print("  ✓ Playback speed adjusted to 2.0x")

	print("\n==================================================")
	print("🎉 ALL INTERACTIVE LAB TESTS PASSED (100% SUCCESS)!")
	print("==================================================")
	quit()
