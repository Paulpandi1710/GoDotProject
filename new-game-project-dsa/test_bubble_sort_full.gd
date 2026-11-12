extends SceneTree

func _init():
	print("==================================================")
	print("DSA ACADEMY — LEVEL 03 COMPREHENSIVE FULL RUN TEST")
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

	LM.launch_lesson(2)
	var l3 = LM.active_lesson
	assert(l3 != null, "Level 3 must be loaded")
	print("✓ Level 3 loaded, state = ", l3.state)

	# --- PHASE 1: INTRO ---
	LM.handle_action("START") # INTRO_ADJACENT
	LM.handle_action("START") # INTRO_SWAP
	LM.handle_action("START") # Starts Guided Sort
	print("✓ Phase 1 complete, state = ", l3.state)
	assert(l3.state == l3.State.GUIDED_SWAP_QUESTION, "Expected GUIDED_SWAP_QUESTION")

	# --- TEST MISTAKE HANDLING IN GUIDED MODE ---
	print("\n--- Testing Mistake Handling in Guided Mode ---")
	LM.handle_action("MIDDLE") # Wrong answer (says NO when 45 > 12)
	assert(l3.state == l3.State.GUIDED_FEEDBACK, "Expected GUIDED_FEEDBACK")
	print("  ✓ Wrong answer led to GUIDED_FEEDBACK cleanly")
	LM.handle_action("START") # Press SPACE or click Try Again
	assert(l3.state == l3.State.GUIDED_SWAP_QUESTION, "Expected return to GUIDED_SWAP_QUESTION")
	print("  ✓ Try Again cleanly restored GUIDED_SWAP_QUESTION with UI options")

	# --- TEST 3D SHELF CLICKING ---
	print("\n--- Testing 3D Element Shelf Clicking ---")
	# At j=0, 45 > 12: Clicking Shelf 0 directly in 3D should trigger swap
	LM.element_selected(0, 45)
	assert(l3.state == l3.State.GUIDED_SWAPPING, "3D shelf click must trigger GUIDED_SWAPPING")
	print("  ✓ 3D Shelf click successfully initiated swap!")
	# Fast-forward swap animation
	l3._on_swap_finished()
	assert(l3.state == l3.State.GUIDED_AFTER_DECISION, "Expected GUIDED_AFTER_DECISION")
	# Clicking 3D shelf in AFTER_DECISION advances j to 1
	LM.element_selected(1, 45)
	assert(l3.state == l3.State.GUIDED_SWAP_QUESTION and l3.guided_j == 1, "Expected GUIDED_SWAP_QUESTION at j=1")
	print("  ✓ 3D Shelf click successfully advanced to next pair!")

	# --- COMPLETE GUIDED SORT (Passes 1, 2, 3) ---
	print("\n--- Running Full Guided Sort ---")
	var step_count = 0
	while l3.state != l3.State.REFLECT_INTRO and step_count < 100:
		step_count += 1
		match l3.state:
			l3.State.GUIDED_SWAP_QUESTION:
				var j = l3.guided_j
				if l3.guided_array[j] > l3.guided_array[j + 1]:
					LM.handle_action("FIRST") # Swap
				else:
					LM.handle_action("MIDDLE") # No swap
			l3.State.GUIDED_SWAPPING:
				LM.handle_action("START")
			l3.State.GUIDED_AFTER_DECISION:
				LM.handle_action("FIRST")
			l3.State.GUIDED_PASS_COMPLETE:
				LM.handle_action("FIRST")
			_:
				print("Current unexpected state in guided: ", l3.state)
				break

	print("✓ Guided sort finished! Guided array is: ", l3.guided_array)
	print("State: ", l3.state)
	assert(l3.state == l3.State.REFLECT_INTRO, "Must reach REFLECT_INTRO")

	# --- PHASE 3: REFLECTION ---
	print("\n--- Testing Phase 3: Reflection ---")
	LM.handle_action("START") # Advance from CODA message to reflection question
	assert(l3.state == l3.State.REFLECT_QUIZ, "Expected REFLECT_QUIZ")
	# Answer reflection quiz correctly:
	LM.handle_action("MIDDLE") # Correct option
	assert(l3.state == l3.State.REFLECT_CORRECT, "Expected REFLECT_CORRECT")
	LM.handle_action("START") # Advance to Practice Intro
	assert(l3.state == l3.State.PRACTICE_INTRO, "Expected PRACTICE_INTRO")
	print("✓ Phase 3 Reflection complete")

	# --- PHASE 4: INDEPENDENT PRACTICE ---
	print("\n--- Testing Phase 4: Independent Practice ---")
	LM.handle_action("START") # Start practice comparisons
	assert(l3.state == l3.State.PRACTICE_SWAP_QUESTION, "Expected PRACTICE_SWAP_QUESTION")

	# Test practice mistake handling
	LM.handle_action("MIDDLE") # Wrong answer (50 > 10, says no swap)
	assert(l3.state == l3.State.PRACTICE_FEEDBACK, "Expected PRACTICE_FEEDBACK")
	LM.handle_action("START") # Try again
	assert(l3.state == l3.State.PRACTICE_SWAP_QUESTION, "Expected return to PRACTICE_SWAP_QUESTION")
	print("  ✓ Practice mistake cleanly handled without freezing")

	step_count = 0
	while l3.state != l3.State.PRACTICE_DONE and step_count < 100:
		step_count += 1
		match l3.state:
			l3.State.PRACTICE_SWAP_QUESTION:
				var j = l3.practice_j
				if l3.practice_array[j] > l3.practice_array[j + 1]:
					LM.handle_action("FIRST") # Swap
				else:
					LM.handle_action("MIDDLE") # No swap
			l3.State.PRACTICE_SWAPPING:
				LM.handle_action("START")
			l3.State.PRACTICE_AFTER_DECISION:
				LM.handle_action("FIRST")
			l3.State.PRACTICE_PASS_COMPLETE:
				LM.handle_action("FIRST")
			_:
				print("Current state in practice: ", l3.state)
				break

	print("✓ Practice sort finished! Practice array is: ", l3.practice_array)
	assert(l3.state == l3.State.PRACTICE_DONE, "Expected PRACTICE_DONE")
	LM.handle_action("START") # Move to Knowledge Check
	assert(l3.state == l3.State.KC_ACTIVE, "Expected KC_ACTIVE")

	# --- PHASE 5: KNOWLEDGE CHECK ---
	print("\n--- Testing Phase 5: Knowledge Check (5 questions) ---")
	for i in range(5):
		assert(l3.state == l3.State.KC_ACTIVE, "Expected KC_ACTIVE for question " + str(i + 1))
		LM.handle_action("QUIZ_NEXT") # Advance through questions
	print("✓ Knowledge Check complete! State: ", l3.state)
	assert(l3.state == l3.State.PSEUDOCODE, "Expected PSEUDOCODE")

	# --- PHASES 6-9: THEORY & COMPLETION ---
	print("\n--- Testing Phases 6-9: Theory to Completion ---")
	LM.handle_action("START") # PSEUDOCODE -> CODE_SHOW_1
	assert(l3.state == l3.State.CODE_SHOW_1, "Expected CODE_SHOW_1")
	LM.handle_action("START") # CODE_SHOW_1 -> CODE_SHOW_2
	assert(l3.state == l3.State.CODE_SHOW_2, "Expected CODE_SHOW_2")
	LM.handle_action("START") # CODE_SHOW_2 -> CODE_SHOW_3
	assert(l3.state == l3.State.CODE_SHOW_3, "Expected CODE_SHOW_3")
	LM.handle_action("START") # CODE_SHOW_3 -> COMPLEXITY
	assert(l3.state == l3.State.COMPLEXITY, "Expected COMPLEXITY")
	LM.handle_action("START") # COMPLEXITY -> LEVEL_COMPLETE
	assert(l3.state == l3.State.LEVEL_COMPLETE, "Expected LEVEL_COMPLETE")
	LM.handle_action("START") # LEVEL_COMPLETE -> Finish & All Complete modal
	print("✓ Level 3 completed! Lesson index = ", LM.current_lesson_index)
	assert(LM.current_lesson_index >= LM.LESSON_PLAYLIST.size(), "Should have completed all 3 chapters")

	# Return to Nexus Hub:
	LM.handle_action("START")
	assert(LM.in_hub == true, "Must return to Nexus Hub")
	print("✓ Returned cleanly to Nexus Hub!")

	print("\n==================================================")
	print("ALL TESTS PASSED! ZERO GLITCHES OR HANGS DETECTED!")
	print("==================================================")
	quit()
