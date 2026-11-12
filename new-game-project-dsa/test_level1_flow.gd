extends SceneTree

func _init():
	print("========================================")
	print("DSA ACADEMY — LEVEL 01 COMPREHENSIVE TEST")
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
	print("✓ Successfully booted into Hub mode (Front Room)")

	LM.launch_lesson(0)
	assert(LM.in_hub == false, "Must exit Hub on sector launch")

	var l1 = LM.active_lesson
	assert(l1 != null, "Level 1 must be active")
	print("✓ Level 1 (LinearSearchLesson) loaded from Hub")

	# ----------------------------------------------------
	# PHASE 1: Introduction Flow
	# ----------------------------------------------------
	print("\n--- PHASE 1: INTRODUCTION ---")
	assert(l1.state == l1.State.INTRO_WELCOME, "Expected INTRO_WELCOME")
	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_ARRAY, "Expected INTRO_ARRAY")
	print("  ✓ Welcome -> Intro Array")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_ELEMENT, "Expected INTRO_ELEMENT")
	print("  ✓ Intro Array -> Intro Element")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_INDEX, "Expected INTRO_INDEX")
	print("  ✓ Intro Element -> Intro Index")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_INDEX_ZERO, "Expected INTRO_INDEX_ZERO")
	print("  ✓ Intro Index -> Intro Index Zero")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_TARGET, "Expected INTRO_TARGET")
	print("  ✓ Intro Index Zero -> Intro Target")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_SEARCH_CONCEPT, "Expected INTRO_SEARCH_CONCEPT")
	print("  ✓ Intro Target -> Intro Search Concept")

	LM.handle_action("START")
	assert(l1.state == l1.State.INTRO_ALGORITHM, "Expected INTRO_ALGORITHM")
	print("  ✓ Intro Search Concept -> Intro Algorithm")

	LM.handle_action("START")
	assert(l1.state == l1.State.GUIDED_PRE_QUIZ, "Expected GUIDED_PRE_QUIZ")
	print("  ✓ Intro Algorithm -> Guided Pre Quiz")

	# ----------------------------------------------------
	# PHASE 2: Guided Search
	# ----------------------------------------------------
	print("\n--- PHASE 2: GUIDED SEARCH ---")
	# Answer pre-quiz: "At INDEX 0" (FIRST option)
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.GUIDED_SEARCHING, "Expected GUIDED_SEARCHING")
	print("  ✓ Pre-quiz passed -> GUIDED_SEARCHING active")

	# Step 0: click index 0 (value 10)
	l1.element_selected(0, 10)
	assert(l1.state == l1.State.GUIDED_COMPARE_SHOW, "Expected GUIDED_COMPARE_SHOW at index 0")
	# Answer compare quiz: 10 == 40? -> NO ("MIDDLE")
	LM.handle_action("MIDDLE")
	assert(l1.state == l1.State.GUIDED_RESULT_SHOWN, "Expected GUIDED_RESULT_SHOWN")
	# Advance
	LM.handle_action("START")
	assert(l1.state == l1.State.GUIDED_SEARCHING, "Expected GUIDED_SEARCHING for index 1")
	assert(l1.guided_index == 1, "Expected guided_index == 1")
	print("  ✓ Index 0 checked (10 != 40)")

	# Step 1: click index 1 (value 25)
	l1.element_selected(1, 25)
	assert(l1.state == l1.State.GUIDED_COMPARE_SHOW, "Expected GUIDED_COMPARE_SHOW at index 1")
	# Answer compare quiz: 25 == 40? -> NO ("MIDDLE")
	LM.handle_action("MIDDLE")
	assert(l1.state == l1.State.GUIDED_RESULT_SHOWN, "Expected GUIDED_RESULT_SHOWN")
	LM.handle_action("START")
	assert(l1.state == l1.State.GUIDED_SEARCHING, "Expected GUIDED_SEARCHING for index 2")
	assert(l1.guided_index == 2, "Expected guided_index == 2")
	print("  ✓ Index 1 checked (25 != 40)")

	# Step 2: click index 2 (value 40) - TARGET!
	l1.element_selected(2, 40)
	assert(l1.state == l1.State.GUIDED_COMPARE_SHOW, "Expected GUIDED_COMPARE_SHOW at index 2")
	# Answer compare quiz: 40 == 40? -> YES ("FIRST")
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.GUIDED_RESULT_SHOWN, "Expected GUIDED_RESULT_SHOWN")
	LM.handle_action("START")
	assert(l1.state == l1.State.REFLECT_QUIZ, "Expected REFLECT_QUIZ after finding target")
	print("  ✓ Index 2 checked (40 == 40) -> TARGET FOUND!")

	# ----------------------------------------------------
	# PHASE 3: Reflection Quiz
	# ----------------------------------------------------
	print("\n--- PHASE 3: REFLECTION QUIZ ---")
	# Option 1: "It can't see the values until it checks each one" (FIRST)
	LM.handle_action("FIRST")
	assert(l1.state == l1.State.REFLECT_CORRECT, "Expected REFLECT_CORRECT")
	print("  ✓ Reflection question answered correctly")

	LM.handle_action("START")
	assert(l1.state == l1.State.PRACTICE_INTRO, "Expected PRACTICE_INTRO")
	print("  ✓ Transitioned to Independent Practice")

	# ----------------------------------------------------
	# PHASE 4: Independent Practice
	# ----------------------------------------------------
	print("\n--- PHASE 4: INDEPENDENT PRACTICE ---")
	LM.handle_action("START")
	assert(l1.state == l1.State.PRACTICE_SEARCHING, "Expected PRACTICE_SEARCHING")
	# Practice array: [15, 50, 20, 35, 70], Target = 35
	# Click index 0 (15)
	l1.element_selected(0, 15)
	# Wait for transition
	var timer = create_timer(1.1)
	await timer.timeout
	# Click index 1 (50)
	l1.element_selected(1, 50)
	timer = create_timer(1.1)
	await timer.timeout
	# Click index 2 (20)
	l1.element_selected(2, 20)
	timer = create_timer(1.1)
	await timer.timeout
	# Click index 3 (35) -> MATCH!
	l1.element_selected(3, 35)
	assert(l1.state == l1.State.PRACTICE_DONE, "Expected PRACTICE_DONE")
	print("  ✓ Practice search completed (Found 35 at index 3 in 4 comparisons)")

	LM.handle_action("START")
	assert(l1.state == l1.State.NOT_FOUND_INTRO, "Expected NOT_FOUND_INTRO")
	print("  ✓ Transitioned to Not-Found Scenario")

	# ----------------------------------------------------
	# PHASE 4B: Not-Found Scenario
	# ----------------------------------------------------
	print("\n--- PHASE 4B: NOT-FOUND SCENARIO ---")
	LM.handle_action("START")
	assert(l1.state == l1.State.NOT_FOUND_SEARCHING, "Expected NOT_FOUND_SEARCHING")
	# NOT_FOUND_ARRAY: [10, 25, 40, 15, 30], target = 99
	for i in range(5):
		l1.element_selected(i, l1.NOT_FOUND_ARRAY[i])
		timer = create_timer(1.1)
		await timer.timeout

	assert(l1.state == l1.State.NOT_FOUND_DONE, "Expected NOT_FOUND_DONE")
	print("  ✓ All 5 elements checked without match")

	LM.handle_action("START")
	assert(l1.state == l1.State.NOT_FOUND_EXPLAIN, "Expected NOT_FOUND_EXPLAIN")
	print("  ✓ Not-Found Explanation active")

	LM.handle_action("START")
	assert(l1.state == l1.State.KC_ACTIVE, "Expected KC_ACTIVE")
	print("  ✓ Transitioned to Knowledge Check")

	# ----------------------------------------------------
	# PHASE 5: Knowledge Check (5 questions)
	# ----------------------------------------------------
	print("\n--- PHASE 5: KNOWLEDGE CHECK ---")
	var kc_answers = [
		"FIRST",   # Q0: What is an array? -> ordered sequence
		"MIDDLE",  # Q1: First element index? -> 0
		"LAST",    # Q2: Where does Linear Search start? -> index 0
		"LAST",    # Q3: When no match? -> next element (index + 1)
		"LAST"     # Q4: Worst case? -> ALL elements
	]

	for q in range(5):
		assert(l1.state == l1.State.KC_ACTIVE, "Expected KC_ACTIVE for Q%d" % q)
		LM.handle_action(kc_answers[q])
		assert(l1.state == l1.State.KC_CORRECT_EXPLAIN, "Expected KC_CORRECT_EXPLAIN for Q%d" % q)
		print("  ✓ Question %d answered correctly" % (q + 1))
		LM.handle_action("START")

	assert(l1.state == l1.State.PSEUDOCODE, "Expected PSEUDOCODE after KC")
	print("  ✓ All 5 Knowledge Check questions passed!")

	# ----------------------------------------------------
	# PHASES 6-8: Pseudocode, C Code, Complexity
	# ----------------------------------------------------
	print("\n--- PHASES 6-8: THEORY & CODE ---")
	LM.handle_action("START")
	assert(l1.state == l1.State.CODE_SHOW_1, "Expected CODE_SHOW_1")
	print("  ✓ C Code Step 1 (Loop header)")

	LM.handle_action("START")
	assert(l1.state == l1.State.CODE_SHOW_2, "Expected CODE_SHOW_2")
	print("  ✓ C Code Step 2 (Comparison & Return index)")

	LM.handle_action("FIRST")
	assert(l1.state == l1.State.CODE_SHOW_3, "Expected CODE_SHOW_3")
	print("  ✓ C Code Step 3 (Return -1 not found)")

	LM.handle_action("FIRST")
	assert(l1.state == l1.State.COMPLEXITY, "Expected COMPLEXITY")
	print("  ✓ Complexity O(n) explanation")

	# ----------------------------------------------------
	# PHASE 8B: Mini Challenge
	# ----------------------------------------------------
	print("\n--- PHASE 8B: MINI CHALLENGE ---")
	LM.handle_action("START")
	assert(l1.state == l1.State.CHALLENGE_INTRO, "Expected CHALLENGE_INTRO")
	LM.handle_action("START")
	assert(l1.state == l1.State.CHALLENGE_PREDICT, "Expected CHALLENGE_PREDICT")
	print("  ✓ Prediction prompt active")

	# Predict 5 comparisons ("MIDDLE")
	LM.handle_action("MIDDLE")
	assert(l1.state == l1.State.CHALLENGE_SEARCHING, "Expected CHALLENGE_SEARCHING")
	assert(l1.challenge_prediction == 5, "Expected prediction 5")
	print("  ✓ Prediction registered: 5 comparisons")

	# Perform challenge search: CHALLENGE_ARRAY = [55, 12, 80, 25, 90, 30], target = 90
	for i in range(5):
		l1.element_selected(i, l1.CHALLENGE_ARRAY[i])
		timer = create_timer(1.1)
		await timer.timeout

	assert(l1.state == l1.State.CHALLENGE_RESULT, "Expected CHALLENGE_RESULT")
	print("  ✓ Challenge search verified: found at index 4 with 5 comparisons")

	LM.handle_action("START")
	assert(l1.state == l1.State.LEVEL_COMPLETE, "Expected LEVEL_COMPLETE")
	print("  ✓ Advanced to LEVEL_COMPLETE")

	# ----------------------------------------------------
	# PHASE 9: Level Complete
	# ----------------------------------------------------
	print("\n--- PHASE 9: LEVEL COMPLETE ---")
	LM.handle_action("START")
	assert(l1.state == l1.State.FINISHED, "Expected FINISHED")
	print("  ✓ Advanced to FINISHED")

	print("\n========================================")
	print("🎉 LEVEL 01 COMPREHENSIVE TEST PASSED 100%!")
	print("========================================")
	quit()
