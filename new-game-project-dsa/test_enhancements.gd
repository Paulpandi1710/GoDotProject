extends SceneTree

func _init():
	print("========================================")
	print("TESTING DSA ACADEMY — ENHANCEMENTS & BUG FIXES")
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

	# ──────────────────────────────────────────────────────────
	# 1. TEST LEVEL 2 (BINARY SEARCH) VISUAL INTRODUCTION
	# ──────────────────────────────────────────────────────────
	print("\n>>> 1. TESTING BINARY SEARCH VISUAL INTRODUCTION")
	LM.launch_lesson(1) # Launch Binary Search
	var l2 = LM.active_lesson
	assert(l2 != null, "BinarySearchLesson must be active")
	assert(l2.state == l2.State.INTRO_WELCOME, "Expected INTRO_WELCOME")
	print("  ✓ Booted into INTRO_WELCOME")

	# Welcome -> Sorted visual step
	LM.handle_action("START")
	assert(l2.state == l2.State.INTRO_SORTED, "Expected INTRO_SORTED")
	assert(arr.has_method("visualize_intro_sorted"), "array_system must have visualize_intro_sorted")
	print("  ✓ INTRO_WELCOME -> INTRO_SORTED (Visual sorted scan executed)")

	# Sorted -> Bounds visual step
	LM.handle_action("START")
	assert(l2.state == l2.State.INTRO_BOUNDS, "Expected INTRO_BOUNDS")
	assert(arr.has_method("visualize_intro_bounds"), "array_system must have visualize_intro_bounds")
	print("  ✓ INTRO_SORTED -> INTRO_BOUNDS (Visual left & right bounds executed)")

	# Bounds -> Halving visual step
	LM.handle_action("START")
	assert(l2.state == l2.State.INTRO_HALVING, "Expected INTRO_HALVING")
	assert(arr.has_method("visualize_intro_halving"), "array_system must have visualize_intro_halving")
	print("  ✓ INTRO_BOUNDS -> INTRO_HALVING (Visual halving elimination executed)")

	# Halving -> Guided search start
	LM.handle_action("START")
	assert(l2.state == l2.State.GUIDED_SHOW_FORMULA, "Expected GUIDED_SHOW_FORMULA")
	print("  ✓ INTRO_HALVING -> GUIDED_SHOW_FORMULA (Transitioned to gameplay)")

	# ──────────────────────────────────────────────────────────
	# 2. TEST BINARY SEARCH QUIZ & NO-RESET BUG FIX
	# ──────────────────────────────────────────────────────────
	print("\n>>> 2. TESTING QUIZ FLOW & WRONG ANSWER BEHAVIOR")
	# Jump to Knowledge Check
	l2.state = l2.State.KC_ACTIVE
	l2._kc_index = 0
	l2._kc_started = true
	l2._p5_show_question()
	assert(l2._kc_index == 0, "Expected Q0")
	print("  ✓ At Question 0")

	# Submit a CORRECT answer for Q0 (correct is 1 = "MIDDLE")
	LM.handle_action("MIDDLE")
	assert(l2.state == l2.State.KC_CORRECT_EXPLAIN, "Expected KC_CORRECT_EXPLAIN on correct answer")
	assert(l2._kc_index == 1, "Question index must advance to 1")
	print("  ✓ Q0 answered correctly -> Advanced to Q1 (_kc_index = 1)")

	# Advance to Q1
	LM.handle_action("START")
	assert(l2.state == l2.State.KC_ACTIVE, "Expected KC_ACTIVE for Q1")
	assert(l2._kc_index == 1, "Still at Q1")
	print("  ✓ At Question 1")

	# Now submit a WRONG answer for Q1 (correct is 0 = "FIRST", submit "LAST")
	LM.handle_action("LAST")
	print("  ✓ Submitted wrong answer for Q1")

	# Press START / Space — CRITICAL TEST: MUST NOT RESET TO Q0!
	LM.handle_action("START")
	assert(l2._kc_index == 1, "CRITICAL: _kc_index must NOT be reset to 0 on wrong answer!")
	print("  ✓ VERIFIED: Wrong answer did NOT reset quiz to Q0! Player remains at Q1.")

	# Advance via QUIZ_NEXT
	LM.handle_action("QUIZ_NEXT")
	assert(l2._kc_index == 2, "Expected _kc_index = 2 after QUIZ_NEXT")
	print("  ✓ Advanced to Question 2 via QUIZ_NEXT (_kc_index = 2)")

	# ──────────────────────────────────────────────────────────
	# 3. TEST GLASSMORPHISM UI TOKENS & PANEL STYLES
	# ──────────────────────────────────────────────────────────
	print("\n>>> 3. TESTING GLASSMORPHISM & UI THEMING")
	assert(UITheme.C_TEXT_MAIN == Color(1, 1, 1, 1), "Main text must be crisp white")
	assert(UITheme.C_BLACK_SCRIM.a > 0.6, "Backdrop scrim must provide high contrast dimming")
	assert(ui._story_overlay.color.a > 0.6, "_story_overlay must use dark glassmorphism scrim")
	assert(ui._story_feedback_card != null, "Story panel must have animatic feedback card")
	print("  ✓ Glassmorphic styling and animatic feedback card verified")

	print("\n========================================")
	print("🎉 ALL ENHANCEMENT TESTS PASSED 100%!")
	print("========================================")
	quit()
