## ============================================================
## DSA ACADEMY — LEVEL 02: BINARY SEARCH (COMPREHENSIVE)
##
## PHASE 1:  Introduction  (sorted array, halving, L/R/Mid)
## PHASE 2:  Guided Search  (teach each step)
## PHASE 3:  Reflection Quiz  (why sorted?)
## PHASE 4:  Independent Practice  (student drives)
## PHASE 5:  Knowledge Check  (5 quiz questions)
## PHASE 6:  Pseudocode
## PHASE 7:  Code Connection  (C Code step by step)
## PHASE 8:  Complexity Introduction  (O(log n) idea)
## PHASE 9:  Level Complete
## ============================================================

extends Lesson
class_name BinarySearchLesson

# ═══════════════════════════════════════════════════════════
# STATE MACHINE
# ═══════════════════════════════════════════════════════════
enum State {
	# ── Phase 1: Introduction
	INTRO_WELCOME,
	INTRO_SORTED,
	INTRO_BOUNDS,
	INTRO_HALVING,

	# ── Phase 2: Guided Search
	GUIDED_SHOW_FORMULA,
	GUIDED_CLICK_MID,
	GUIDED_CHECK_MID,
	GUIDED_UPDATE_BOUNDS,

	# ── Phase 3: Reflection
	REFLECT_QUIZ,
	REFLECT_CORRECT,

	# ── Phase 4: Practice
	PRACTICE_INTRO,
	PRACTICE_SHOW_FORMULA,
	PRACTICE_CLICK_MID,
	PRACTICE_CHECK_MID,
	PRACTICE_UPDATE_BOUNDS,
	PRACTICE_DONE,

	# ── Phase 5: Knowledge Check
	KC_ACTIVE,
	KC_CORRECT_EXPLAIN,

	# ── Phase 6-9: Theory + Finish
	PSEUDOCODE,
	CODE_SHOW_1,
	CODE_SHOW_2,
	CODE_SHOW_3,
	COMPLEXITY,
	LEVEL_COMPLETE,
	FINISHED
}

# ═══════════════════════════════════════════════════════════
# DATA
# ═══════════════════════════════════════════════════════════

var state: State = State.INTRO_WELCOME

## Guided search
const GUIDED_ARRAY   := [10, 15, 25, 30, 40, 55, 60]
const GUIDED_TARGET  := 55
var guided_comparisons: int = 0
var guided_left: int = 0
var guided_right: int = 0
var guided_mid: int = 0

## Practice search
const PRACTICE_ARRAY  := [2, 14, 23, 31, 45, 56, 68, 77, 89]
const PRACTICE_TARGET := 23
var practice_comparisons: int = 0
var practice_left: int = 0
var practice_right: int = 0
var practice_mid: int = 0

var pending_index: int = -1
var pending_value: int = -1

## Interactive Lab State
var interactive_array: Array = [10, 15, 25, 30, 40, 55, 60]
var interactive_target: int = 55
var interactive_left: int = 0
var interactive_right: int = 6
var interactive_mid: int = 3
var interactive_comparisons: int = 0
var interactive_found_idx: int = -1
var _auto_playing: bool = false
var _auto_timer: float = 0.0
var _playback_speed: float = 1.0

var _kc_index: int = 0
const KC_QUESTIONS := [
	{
		"q":       "What is the MOST IMPORTANT requirement for Binary Search?",
		"opts":    ["The array must have an even number of elements",
					"The array must be SORTED",
					"The array must contain only positive numbers"],
		"correct": 1,
		"explain": "Binary Search ONLY works on sorted arrays. If the array isn't sorted, we can't reliably eliminate half of the elements!"
	},
	{
		"q":       "How does Binary Search calculate the Middle index?",
		"opts":    ["Mid = (Left + Right) / 2",
					"Mid = Left + (Right * 2)",
					"Mid = Right - Left"],
		"correct": 0,
		"explain": "Mid is calculated as the average of the Left and Right bounds: (Left + Right) / 2. Any decimal is truncated (rounded down)."
	},
	{
		"q":       "If the middle value is LESS than the target...",
		"opts":    ["Move the RIGHT bound to Mid - 1",
					"Move the LEFT bound to Mid + 1",
					"Stop searching"],
		"correct": 1,
		"explain": "If Mid < Target, the target must be to the right of Mid! So we update our Left bound to Mid + 1."
	},
	{
		"q":       "When does Binary Search stop and say 'Not Found'?",
		"opts":    ["When Left becomes greater than Right (Left > Right)",
					"When Left equals Right (Left == Right)",
					"After checking 3 elements"],
		"correct": 0,
		"explain": "If Left crosses Right (Left > Right), it means the search space has shrunk to zero elements, and the target is not in the array."
	},
	{
		"q":       "In the WORST case, how many elements does Binary Search check?",
		"opts":    ["It checks every single element",
					"Logarithmic number of elements O(log n)",
					"Just 1 element"],
		"correct": 1,
		"explain": "Because it halves the search space each time, it takes at most O(log n) steps. For 1,000,000 elements, it only takes ~20 checks!"
	},
]

var _kc_started: bool = false

# ═══════════════════════════════════════════════════════════
# START
# ═══════════════════════════════════════════════════════════

func _process(delta):
	if _auto_playing:
		_auto_timer += delta
		var delay = 1.0 / max(_playback_speed, 0.25)
		if _auto_timer >= delay:
			_auto_timer = 0.0
			step_interactive()

# ─── INTERACTIVE LAB CONTROLS ───
func step_interactive():
	## STEP may click mid during search states — never auto-answers quiz choices.
	if state == State.GUIDED_CLICK_MID:
		element_selected(guided_mid, GUIDED_ARRAY[guided_mid])
		return
	elif state == State.PRACTICE_CLICK_MID:
		element_selected(practice_mid, PRACTICE_ARRAY[practice_mid])
		return
	elif state == State.GUIDED_CHECK_MID or state == State.GUIDED_UPDATE_BOUNDS \
			or state == State.PRACTICE_CHECK_MID or state == State.PRACTICE_UPDATE_BOUNDS:
		if game_ui and game_ui.has_method("set_hint"):
			game_ui.set_hint("Decide in the panel (1/2/SPACE). PLAY/STEP won't answer for you.")
		set_auto_play(false)
		return

	# General Sandbox Binary Search Step
	if interactive_array.is_empty():
		interactive_array = [10, 15, 25, 30, 40, 55, 60]

	if interactive_found_idx != -1 or interactive_left > interactive_right:
		reset_interactive()
		return

	interactive_mid = int((interactive_left + interactive_right) / 2)
	var mid_val = interactive_array[interactive_mid]
	interactive_comparisons += 1
	var is_match = (mid_val == interactive_target)

	if array_system:
		array_system.update_binary_bounds(interactive_left, interactive_right, interactive_mid)
		array_system.execute_comparison(interactive_mid, mid_val)

	if game_ui:
		var code_line = 3 if is_match else (6 if mid_val < interactive_target else 8)
		game_ui.highlight_code_line(code_line)
		game_ui.set_watch_variables({
			"Left Bound": interactive_left,
			"Right Bound": interactive_right,
			"Mid Candidate": interactive_mid,
			"arr[mid]": mid_val,
			"Target Value": interactive_target,
			"Comparisons": interactive_comparisons,
			"Status": "MATCH! Found at mid" if is_match else ("%d < %d -> Go RIGHT" % [mid_val, interactive_target] if mid_val < interactive_target else "%d > %d -> Go LEFT" % [mid_val, interactive_target])
		})
		game_ui.set_complexity_stats(interactive_comparisons, int(ceil(log(interactive_array.size()) / log(2))) + 1, "O(log n) Halving")
		game_ui.update_array_ribbon(interactive_array, interactive_mid, interactive_target, range(0, interactive_left) + range(interactive_right + 1, interactive_array.size()), interactive_mid if is_match else -1)
		game_ui.set_step("Mid = Index %d (arr[%d] = %d) vs Target %d" % [interactive_mid, interactive_mid, mid_val, interactive_target])
		game_ui.set_formula(
			("✅ arr[%d] == %d → MATCH FOUND!" % [interactive_mid, mid_val]) if is_match else (
				("arr[%d] = %d < %d → Discard Left [%d..%d]" % [interactive_mid, mid_val, interactive_target, interactive_left, interactive_mid]) if mid_val < interactive_target else (
					"arr[%d] = %d > %d → Discard Right [%d..%d]" % [interactive_mid, mid_val, interactive_target, interactive_mid, interactive_right]
				)
			)
		)

	if is_match:
		interactive_found_idx = interactive_mid
		set_auto_play(false)
	else:
		if mid_val < interactive_target:
			interactive_left = interactive_mid + 1
		else:
			interactive_right = interactive_mid - 1

		if interactive_left > interactive_right:
			if game_ui:
				game_ui.highlight_code_line(9)
				game_ui.set_step("Target %d not found in sorted array" % interactive_target)
			set_auto_play(false)

func set_auto_play(is_playing: bool):
	_auto_playing = is_playing
	_auto_timer = 0.0
	if game_ui:
		game_ui.set_playback_state(is_playing)

func reset_interactive():
	_auto_playing = false
	interactive_left = 0
	interactive_right = interactive_array.size() - 1
	interactive_mid = int((interactive_left + interactive_right) / 2)
	interactive_comparisons = 0
	interactive_found_idx = -1
	if array_system:
		array_system.target_value = interactive_target
		array_system.create_array(interactive_array)
		array_system.start_binary_search(interactive_target, interactive_left, interactive_right, interactive_mid)
	if game_ui:
		game_ui.set_playback_state(false)
		game_ui.highlight_code_line(1)
		game_ui.set_watch_variables({
			"Left Bound": interactive_left,
			"Right Bound": interactive_right,
			"Mid Candidate": interactive_mid,
			"arr[mid]": interactive_array[interactive_mid],
			"Target Value": interactive_target,
			"Comparisons": 0,
			"Status": "Ready"
		})
		game_ui.set_complexity_stats(0, int(ceil(log(interactive_array.size()) / log(2))) + 1, "Ready")
		game_ui.update_array_ribbon(interactive_array, interactive_mid, interactive_target, [])
		game_ui.set_step("Binary Search Lab: Press [⏭ STEP] or [▶ PLAY]")
		game_ui.set_formula("Search Window: [0 ... %d] | Target: %d" % [interactive_right, interactive_target])

func set_target_interactive(val: int):
	interactive_target = val
	reset_interactive()

func randomize_interactive():
	var new_arr := []
	var pool := [4, 8, 12, 19, 25, 33, 42, 51, 60, 68, 77, 85, 94]
	pool.shuffle()
	for i in range(7):
		new_arr.append(pool[i])
	new_arr.sort()
	interactive_array = new_arr
	interactive_target = new_arr[randi() % new_arr.size()]
	if game_ui:
		game_ui.set_deck_target_label(interactive_target)
	reset_interactive()

func set_playback_speed(speed: float):
	_playback_speed = speed

func start_lesson():
	apply_theme("binary_search")
	_reset_vars()
	state = State.INTRO_WELCOME
	_p1_welcome()

func _reset_vars():
	guided_comparisons = 0
	practice_comparisons = 0
	_kc_index = 0
	_kc_started = false
	pending_index = -1
	pending_value = -1

# ═══════════════════════════════════════════════════════════
# PHASE 1 — VISUAL INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p1_welcome():
	if array_system:
		array_system.clear_all_visualizers()
		array_system.create_array(GUIDED_ARRAY)
	game_ui.set_lesson("Level 02 — Binary Search")
	game_ui.set_objective("Learn to search by halving")
	game_ui.set_target(GUIDED_TARGET)
	game_ui.set_step("Welcome to Level 02")
	game_ui.hide_formula()
	game_ui.show_lesson_message(
		"DSA ACADEMY  🎓\n\n"
		+ "LEVEL  02  ―  HALVE THE SEARCH\n\n"
		+ "CODA: \"Welcome back! Linear Search was okay, but we can go dramatically faster.\"\n\n"
		+ "\"In this lesson, you will learn BINARY SEARCH.\"\n\n"
		+ "\"Watch the 3D archive in front of you as we demonstrate how halving works visually!\""
	)
	game_ui.set_hint("Press SPACE to begin the visual walkthrough")

func _p1_sorted():
	state = State.INTRO_SORTED
	game_ui.set_step("Visual Concept 1 of 3 — The Sorted Archive")
	game_ui.set_formula("Requirement: The Array MUST be SORTED!")
	if array_system and array_system.has_method("visualize_intro_sorted"):
		array_system.visualize_intro_sorted()
	game_ui.show_lesson_message(
		"CODA: \"Look at the illuminated shelves in the archive:\n\n"
		+ "  [ 10 ≤ 15 ≤ 25 ≤ 30 ≤ 40 ≤ 55 ≤ 60 ]\n\n"
		+ "Notice the ascending order! In Binary Search, this is MANDATORY.\n\n"
		+ "Because it is sorted, any element in the middle tells us everything:\n"
		+ "• Every shelf to the LEFT is smaller\n"
		+ "• Every shelf to the RIGHT is larger!\""
	)

func _p1_bounds():
	state = State.INTRO_BOUNDS
	game_ui.set_step("Visual Concept 2 of 3 — Left and Right Bounds")
	game_ui.set_formula("Active Window: LEFT = 0  |  RIGHT = 6  (7 Elements)")
	if array_system and array_system.has_method("visualize_intro_bounds"):
		array_system.visualize_intro_bounds(0, GUIDED_ARRAY.size() - 1)
	game_ui.show_lesson_message(
		"CODA: \"Instead of scanning from shelf 0 to 6 one-by-one, we define two boundary pointers:\n\n"
		+ "  ▶ LEFT  = Index 0  (Shelf with Value 10)\n"
		+ "  ▶ RIGHT = Index 6  (Shelf with Value 60)\n\n"
		+ "Our target (#55) is guaranteed to be inside this window.\""
	)

func _p1_halving():
	state = State.INTRO_HALVING
	game_ui.set_step("Visual Concept 3 of 3 — Halving the Search Space")
	game_ui.set_formula("Mid = (0 + 6) / 2 = 3  (Value 30 < 55) → Left Half Eliminated!")
	if array_system and array_system.has_method("visualize_intro_halving"):
		array_system.visualize_intro_halving(0, GUIDED_ARRAY.size() - 1, 3, GUIDED_TARGET)
	game_ui.show_lesson_message(
		"CODA: \"Now watch closely! We check the MIDDLE shelf (Index 3):\n\n"
		+ "  1. Mid = (0 + 6) ÷ 2 = 3   (Value is 30)\n"
		+ "  2. Compare: 30 < 55 (Our Target)\n"
		+ "  3. Because the archive is sorted, the target CANNOT be on the left!\n\n"
		+ "✂ NOTICE: Shelves 0, 1, 2, 3 are ELIMINATED in ONE comparison!\n"
		+ "We cut half the search space away instantly!\""
	)

# ═══════════════════════════════════════════════════════════
# PHASE 2 — GUIDED SEARCH
# ═══════════════════════════════════════════════════════════

func _p2_start():
	guided_left = 0
	guided_right = GUIDED_ARRAY.size() - 1
	guided_comparisons = 0
	game_ui.set_lesson("Guided Search — Halving the array")
	if array_system:
		if array_system.has_method("reset_element_visuals"):
			array_system.reset_element_visuals()
		array_system.create_array(GUIDED_ARRAY)
	_p2_show_formula()

func _p2_show_formula():
	state = State.GUIDED_SHOW_FORMULA
	guided_mid = (guided_left + guided_right) / 2
	if array_system:
		array_system.start_binary_search(GUIDED_TARGET, guided_left, guided_right, guided_mid)
	var formula_str = "Left=%d  Right=%d  →  Mid = (%d + %d) ÷ 2 = %d" % [guided_left, guided_right, guided_left, guided_right, guided_mid]
	game_ui.set_formula(formula_str)
	game_ui.show_choice_message(
		("📐  HOW BINARY SEARCH FINDS MID:\n\n"
		+ "• LEFT POINTER  = Index %d  (Start of active search window)\n"
		+ "• RIGHT POINTER = Index %d  (End of active search window)\n"
		+ "• FORMULA: Mid = (Left + Right) ÷ 2 = (%d + %d) ÷ 2 = %d\n\n"
		+ "Elements outside [%d ... %d] will turn pitch BLACK & CLOSED (🔒).\n"
		+ "Now click the glowing MID shelf (Index %d) in the archive!") % [
			guided_left, guided_right, guided_left, guided_right, guided_mid,
			guided_left, guided_right, guided_mid
		],
		["Got it — I'll inspect Mid (Index %d)!" % guided_mid]
	)

func _p2_wait_click():
	state = State.GUIDED_CLICK_MID
	hide_panel()
	game_ui.set_step("→  Click the highlighted MID element (Index %d)" % guided_mid)
	game_ui.set_hint("Click the purple-highlighted shelf in the 3D world")

func _p2_check_mid():
	state = State.GUIDED_CHECK_MID
	guided_comparisons += 1
	if array_system: array_system.execute_comparison(pending_index, pending_value)
	
	game_ui.show_choice_message(
		"CODA checks Shelf %d → value is %d.\n\nTarget is File #%d.\n\n%s" % [
			pending_index, pending_value, GUIDED_TARGET,
			"✅  MATCH! Found it!" if pending_value == GUIDED_TARGET
			else ("⬅  %d < %d  →  Target is to the RIGHT" % [pending_value, GUIDED_TARGET] if pending_value < GUIDED_TARGET
			else "➡  %d > %d  →  Target is to the LEFT" % [pending_value, GUIDED_TARGET])
		],
		["Continue"]
	)

func _p2_update_bounds():
	state = State.GUIDED_UPDATE_BOUNDS
	if pending_value < GUIDED_TARGET:
		game_ui.show_choice_message(
			("CODA: \"Shelf %d holds value %d.\n\n"
			+ "%d < %d  →  The target is BIGGER.\n\n"
			+ "In a sorted archive, bigger values are to the RIGHT.\n"
			+ "Which boundary should CODA move?\"") % [pending_index, pending_value, pending_value, GUIDED_TARGET],
			["Move LEFT bound to Mid+1  ✅", "Move RIGHT bound to Mid-1"]
		)
	else:
		game_ui.show_choice_message(
			("CODA: \"Shelf %d holds value %d.\n\n"
			+ "%d > %d  →  The target is SMALLER.\n\n"
			+ "In a sorted archive, smaller values are to the LEFT.\n"
			+ "Which boundary should CODA move?\"") % [pending_index, pending_value, pending_value, GUIDED_TARGET],
			["Move LEFT bound to Mid+1", "Move RIGHT bound to Mid-1  ✅"]
		)

func _p2_handle_bounds_quiz(action: String):
	var is_correct = false
	if pending_value < GUIDED_TARGET:
		is_correct = (action == "FIRST")
	else:
		is_correct = (action == "MIDDLE")
		
	if is_correct:
		if pending_value < GUIDED_TARGET:
			guided_left = guided_mid + 1
		else:
			guided_right = guided_mid - 1

		var new_mid = (guided_left + guided_right) / 2
		if array_system:
			array_system.update_binary_bounds(guided_left, guided_right, new_mid)

		game_ui.show_lesson_message(
			("✅  SEARCH WINDOW SHRUNK!\n\n"
			+ "• New Range: Indices [%d ... %d]\n"
			+ "• Eliminated elements have turned completely BLACK & CLOSED (⛔ CLOSED)!\n"
			+ "• Next Mid = (%d + %d) ÷ 2 = %d\n\n"
			+ "Press SPACE to inspect the new Mid candidate.") % [
				guided_left, guided_right, guided_left, guided_right, new_mid
			]
		)
	else:
		game_ui.show_choice_feedback(
			"CODA: \"Wait! Think about it.\n\n"
			+ "If the target is BIGGER (%d > %d), it must be to the right (move LEFT bound past mid to %d).\n"
			+ "If the target is SMALLER (%d < %d), it must be to the left (move RIGHT bound before mid to %d).\"" % [
				GUIDED_TARGET, pending_value, guided_mid + 1,
				GUIDED_TARGET, pending_value, guided_mid - 1
			]
		)

# ═══════════════════════════════════════════════════════════
# PHASE 3 — REFLECTION
# ═══════════════════════════════════════════════════════════

func _p3_show_reflection():
	state = State.REFLECT_QUIZ
	game_ui.set_step("Reflection Question")
	game_ui.set_formula("Think about what you just experienced...")
	game_ui.show_choice_message(
		"CODA: \"Great work! You found the target fast.\"\n\n"
		+ "WHY was it absolutely necessary for the array to be SORTED?",
		[
			"Because Binary Search looks better on sorted arrays",
			"Because otherwise we couldn't guarantee which half the target is in",
			"Because sorted arrays take up less memory"
		]
	)

# ═══════════════════════════════════════════════════════════
# PHASE 4 — INDEPENDENT PRACTICE
# ═══════════════════════════════════════════════════════════

func _p4_intro():
	state = State.PRACTICE_INTRO
	if array_system:
		array_system.clear_all_visualizers()
		array_system.create_array(PRACTICE_ARRAY)
	game_ui.set_lesson("Practice — Your Turn! 💪")
	game_ui.set_objective("Find File #" + str(PRACTICE_TARGET) + " on your own")
	game_ui.set_target(PRACTICE_TARGET)
	game_ui.set_step("Independent Practice")
	game_ui.set_formula("New array: %s   |   Target: %d" % [str(PRACTICE_ARRAY), PRACTICE_TARGET])
	game_ui.show_lesson_message(
		("CODA: \"Your turn — I'll step back and let you drive!\"\n\n"
		+ "New archive:  %s\n"
		+ "Target:       File  #%d\n\n"
		+ "Remember the rules:\n"
		+ "  ▶  Calculate MID and click it\n"
		+ "  ▶  If target is BIGGER, move LEFT past mid\n"
		+ "  ▶  If target is SMALLER, move RIGHT past mid\n"
		+ "  ▶  Continue until you find File #%d!") % [str(PRACTICE_ARRAY), PRACTICE_TARGET, PRACTICE_TARGET]
	)

func _p4_start():
	practice_left = 0
	practice_right = PRACTICE_ARRAY.size() - 1
	practice_comparisons = 0
	_p4_show_formula()

func _p4_show_formula():
	state = State.PRACTICE_SHOW_FORMULA
	practice_mid = (practice_left + practice_right) / 2
	if array_system:
		array_system.start_binary_search(PRACTICE_TARGET, practice_left, practice_right, practice_mid)
	var formula_str = "Left=%d  Right=%d  →  Mid = (%d + %d) ÷ 2 = %d" % [practice_left, practice_right, practice_left, practice_right, practice_mid]
	game_ui.set_formula(formula_str)
	game_ui.show_choice_message(
		("Calculate the Middle index:\n\n"
		+ "Left = %d,  Right = %d\n"
		+ "Mid  = (%d + %d) ÷ 2  =  %d\n\n"
		+ "Click Shelf %d in the archive!") % [practice_left, practice_right, practice_left, practice_right, practice_mid, practice_mid],
		["Click Shelf %d" % practice_mid]
	)

func _p4_wait_click():
	state = State.PRACTICE_CLICK_MID
	hide_panel()
	game_ui.set_step("→  Click the highlighted MID element (Index %d)" % practice_mid)

func _p4_check_mid():
	state = State.PRACTICE_CHECK_MID
	practice_comparisons += 1
	if array_system: array_system.execute_comparison(pending_index, pending_value)
	
	game_ui.show_choice_message(
		"Value is %d.\nTarget is File #%d.\n\n%s" % [
			pending_value, PRACTICE_TARGET,
			"✅  MATCH! Found it!" if pending_value == PRACTICE_TARGET
			else ("⬅  %d < %d  →  Target is to the RIGHT" % [pending_value, PRACTICE_TARGET] if pending_value < PRACTICE_TARGET
			else "➡  %d > %d  →  Target is to the LEFT" % [pending_value, PRACTICE_TARGET])
		],
		["Continue"]
	)

func _p4_update_bounds():
	state = State.PRACTICE_UPDATE_BOUNDS
	if pending_value < PRACTICE_TARGET:
		game_ui.show_choice_message(
			("%d < %d  →  The target is BIGGER.\n\n"
			+ "Which boundary do you move?") % [pending_value, PRACTICE_TARGET],
			["Move LEFT bound to Mid+1", "Move RIGHT bound to Mid-1"]
		)
	else:
		game_ui.show_choice_message(
			("%d > %d  →  The target is SMALLER.\n\n"
			+ "Which boundary do you move?") % [pending_value, PRACTICE_TARGET],
			["Move LEFT bound to Mid+1", "Move RIGHT bound to Mid-1"]
		)

func _p4_handle_bounds_quiz(action: String):
	var is_correct = false
	if pending_value < PRACTICE_TARGET:
		is_correct = (action == "FIRST")
	else:
		is_correct = (action == "MIDDLE")
		
	if is_correct:
		if pending_value < PRACTICE_TARGET:
			practice_left = practice_mid + 1
		else:
			practice_right = practice_mid - 1
			
		if practice_left > practice_right:
			state = State.PRACTICE_DONE
			game_ui.set_step("Search exhausted — file not found")
		else:
			var new_mid = (practice_left + practice_right) / 2
			if array_system:
				array_system.update_binary_bounds(practice_left, practice_right, new_mid)
			game_ui.show_lesson_message(
				("✅  Correct! Range updated to [%d ... %d].\n\n"
				+ "Notice how out-of-range elements immediately shut down into BLACK & CLOSED pods!\n"
				+ "New Mid = %d") % [practice_left, practice_right, new_mid]
			)
	else:
		game_ui.show_choice_feedback("Incorrect boundary update. If Target is bigger, move Left bound past Mid! If Target is smaller, move Right bound before Mid!")

# ═══════════════════════════════════════════════════════════
# PHASE 5 — KNOWLEDGE CHECK
# ═══════════════════════════════════════════════════════════

func _p5_start():
	_kc_index = 0
	_kc_started = true
	state     = State.KC_ACTIVE
	game_ui.set_lesson("Knowledge Check 📝")
	game_ui.set_objective("Test your understanding of Binary Search")
	game_ui.set_step("Knowledge Check — Question 1 of %d" % KC_QUESTIONS.size())
	game_ui.hide_formula()
	_p5_show_question()

func _p5_show_question():
	if _kc_index >= KC_QUESTIONS.size():
		_p6_pseudocode()
		return
	var q = KC_QUESTIONS[_kc_index]
	state = State.KC_ACTIVE
	game_ui.set_step("Question %d of %d" % [_kc_index + 1, KC_QUESTIONS.size()])
	if game_ui.has_method("show_quiz_question"):
		game_ui.show_quiz_question(q, _kc_index, KC_QUESTIONS.size())
	else:
		game_ui.show_choice_message(q["q"], q["opts"])

func _p5_handle_answer(action: String):
	var q           = KC_QUESTIONS[_kc_index]
	var chosen      = {"FIRST": 0, "MIDDLE": 1, "LAST": 2}.get(action, -1)
	if chosen < 0: return

	if chosen == q["correct"]:
		_kc_index     += 1
		state          = State.KC_CORRECT_EXPLAIN
		hide_panel()
		var done_all   = (_kc_index >= KC_QUESTIONS.size())
		game_ui.show_lesson_message(
			"✅  Correct!\n\n" + q["explain"] + (
				"\n\n🎉  All questions answered! Moving to the next section..." if done_all else ""
			)
		)
	else:
		game_ui.show_choice_feedback("Not quite.\n\n" + q["explain"] + "\n\nTry again!")


# ═══════════════════════════════════════════════════════════
# PHASE 6 — PSEUDOCODE
# ═══════════════════════════════════════════════════════════

func _p6_pseudocode():
	state = State.PSEUDOCODE
	game_ui.set_lesson("Pseudocode — The Algorithm in Plain English")
	game_ui.set_step("Phase 6 — Pseudocode")
	game_ui.set_formula("WHILE left <= right → find mid → check mid → adjust bounds")
	game_ui.show_lesson_message(
		"CODA: \"Let's write out exactly what you just DID!\"\n\n"
		+ "════════════════════════════════\n"
		+ "BINARY SEARCH — PSEUDOCODE\n"
		+ "════════════════════════════════\n\n"
		+ "SET left = 0, right = N - 1\n\n"
		+ "WHILE left <= right:\n"
		+ "    SET mid = (left + right) / 2\n\n"
		+ "    IF array[mid] == target:\n"
		+ "        RETURN mid\n"
		+ "    ELSE IF array[mid] < target:\n"
		+ "        left = mid + 1\n"
		+ "    ELSE:\n"
		+ "        right = mid - 1\n\n"
		+ "RETURN -1   ← NOT FOUND"
	)

# ═══════════════════════════════════════════════════════════
# PHASE 7 — CODE CONNECTION
# ═══════════════════════════════════════════════════════════

func _p7_code_1():
	state = State.CODE_SHOW_1
	game_ui.set_step("Phase 7 — Real Code in C (Step 1)")
	game_ui.set_formula("Setup: defining the left and right boundaries")
	game_ui.show_c_code_step(
		"Binary Search in C — The Bounds",
		"int binary_search(int arr[], int size, int target) {\n"
		+ ">   int left = 0;\n"
		+ ">   int right = size - 1;\n\n"
		+ "    // while loop and logic\n"
		+ "    return -1;\n"
		+ "}",
		"CODA: \"We start by initializing our Left (0) and Right (size - 1) boundary pointers!\"",
		"Next: The While Loop →"
	)

func _p7_code_2():
	state = State.CODE_SHOW_2
	game_ui.set_step("Phase 7 — Real Code in C (Step 2)")
	game_ui.set_formula("The While Loop & finding Mid")
	game_ui.show_c_code_step(
		"Binary Search in C — Halving to find Mid",
		"int binary_search(int arr[], int size, int target) {\n"
		+ "    int left = 0;\n"
		+ "    int right = size - 1;\n\n"
		+ ">   while (left <= right) {\n"
		+ ">       int mid = left + (right - left) / 2;\n"
		+ "        // comparisons\n"
		+ "    }\n"
		+ "    return -1;\n"
		+ "}",
		"CODA: \"We use 'left + (right - left) / 2' in C to calculate the exact middle without integer overflow!\"",
		"Next: The Comparisons →"
	)

func _p7_code_3():
	state = State.CODE_SHOW_3
	game_ui.set_step("Phase 7 — Real Code in C (Step 3)")
	game_ui.set_formula("Compare Mid, then adjust Left or Right")
	game_ui.show_c_code_step(
		"Binary Search in C — The Comparison Logic",
		"        if (arr[mid] == target)\n"
		+ ">           return mid;\n\n"
		+ ">       if (arr[mid] < target)\n"
		+ ">           left = mid + 1;\n"
		+ "        else\n"
		+ ">           right = mid - 1;\n"
		+ "    }\n"
		+ ">   return -1;\n"
		+ "}",
		"CODA: \"Check middle: if target, return mid! If target is bigger, move left up. Otherwise, move right down. If not found, return -1.\"",
		"Understood! →"
	)

# ═══════════════════════════════════════════════════════════
# PHASE 8 — COMPLEXITY INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p8_complexity():
	state = State.COMPLEXITY
	game_ui.set_step("Phase 8 — Efficiency (O(log n))")
	game_ui.set_formula("Binary Search halves the array. O(log n) time!")
	game_ui.show_lesson_message(
		"CODA: \"Why is Binary Search so famous?\"\n\n"
		+ "Imagine an archive with 1,000,000 files.\n\n"
		+ "Linear Search (O(n)): Up to 1,000,000 checks.\n"
		+ "Binary Search (O(log n)): Only ~20 checks!\n\n"
		+ "Because we divide the search space by 2 every time, the number of checks grows very slowly. "
		+ "This is called LOGARITHMIC TIME complexity: O(log n)."
	)

# ═══════════════════════════════════════════════════════════
# PHASE 9 — LEVEL COMPLETE
# ═══════════════════════════════════════════════════════════

func _p9_complete():
	state = State.LEVEL_COMPLETE
	game_ui.set_step("🎓  Level 02 Complete!")
	game_ui.set_formula("Binary Search: O(log n)  |  Requires Sorted Array")
	game_ui.show_lesson_message(
		"🎉  LEVEL  02  COMPLETE!\n\n"
		+ "CODA: \"Incredible job! Let's review:\"\n\n"
		+ "  ✅  Binary search ONLY works on SORTED arrays\n"
		+ "  ✅  It uses Left and Right bounds to track the search space\n"
		+ "  ✅  It compares the Target to the Mid element\n"
		+ "  ✅  It eliminates HALF the array with every check\n"
		+ "  ✅  Time Complexity is O(log n) — blazing fast!\n\n"
		+ "CODA: \"Ready for Level 03?\"\n"
		+ "\"(Hint: What if the archive ISN'T sorted? Time to learn Sorting!)\""
	)

# ═══════════════════════════════════════════════════════════
# MAIN DISPATCH — handle_action
# ═══════════════════════════════════════════════════════════

func handle_action(action: String):
	match state:
		State.INTRO_WELCOME:
			if action == "START": _p1_sorted()
		State.INTRO_SORTED:
			if action == "START": _p1_bounds()
		State.INTRO_BOUNDS:
			if action == "START": _p1_halving()
		State.INTRO_HALVING:
			if action == "START": _p2_start()
			
		State.GUIDED_SHOW_FORMULA:
			if action in ["START", "FIRST"]: _p2_wait_click()
			
		State.GUIDED_CHECK_MID:
			if action in ["START", "FIRST"]:
				if pending_value == GUIDED_TARGET:
					state = State.REFLECT_QUIZ
					game_ui.show_success_message(GUIDED_TARGET, pending_index, guided_comparisons)
				else:
					_p2_update_bounds()
					
		State.GUIDED_UPDATE_BOUNDS:
			if action in ["FIRST", "MIDDLE"]: _p2_handle_bounds_quiz(action)
			elif action == "START": _p2_show_formula() # After correct bound quiz

		State.REFLECT_QUIZ:
			if action == "START": _p3_show_reflection()
			elif action == "MIDDLE": 
				state = State.REFLECT_CORRECT
				hide_panel()
				game_ui.show_lesson_message(
					"✅  Exactly right!\n\n"
					+ "CODA: \"We MUST have a sorted array to know which half to eliminate. "
					+ "If it were random, moving left or right would be meaningless!\"\n\n"
					+ "\"Now, your turn to try!\""
				)
			elif action in ["FIRST", "LAST"]:
				game_ui.show_choice_feedback("Think about WHY we can eliminate half the array. What makes that possible?")

		State.REFLECT_CORRECT:
			if action == "START": _p4_intro()
			
		State.PRACTICE_INTRO:
			if action == "START": _p4_start()
			
		State.PRACTICE_SHOW_FORMULA:
			if action in ["START", "FIRST"]: _p4_wait_click()
			
		State.PRACTICE_CHECK_MID:
			if action in ["START", "FIRST"]:
				if pending_value == PRACTICE_TARGET:
					state = State.PRACTICE_DONE
					game_ui.show_success_message(PRACTICE_TARGET, pending_index, practice_comparisons)
				else:
					_p4_update_bounds()
					
		State.PRACTICE_UPDATE_BOUNDS:
			if action in ["FIRST", "MIDDLE"]: _p4_handle_bounds_quiz(action)
			elif action == "START": _p4_show_formula() # After correct bound quiz

		State.PRACTICE_DONE:
			if action == "START":
				hide_panel()
				state = State.KC_ACTIVE
				game_ui.show_lesson_message(
					("CODA: \"Awesome! You performed Binary Search completely on your own.\"\n\n"
					+ "You made %d comparison%s to find File #%d.\n\n"
					+ "Now let's check your understanding!") % [practice_comparisons, "s" if practice_comparisons != 1 else "", PRACTICE_TARGET]
				)

		State.KC_ACTIVE:
			if action in ["QUIZ_NEXT", "NEXT"]:
				_kc_index += 1
				_p5_show_question()
			elif action == "START":
				if not _kc_started:
					_kc_started = true
					_p5_start()
				else:
					_p5_show_question()
			elif action in ["FIRST", "MIDDLE", "LAST"]:
				_kc_started = true
				_p5_handle_answer(action)
			
		State.KC_CORRECT_EXPLAIN:
			if action in ["START", "QUIZ_NEXT", "NEXT"]:
				_p5_show_question()
			
		State.PSEUDOCODE:
			if action in ["START", "FIRST"]: _p7_code_1()
			
		State.CODE_SHOW_1:
			if action in ["FIRST", "START"]: _p7_code_2()
			
		State.CODE_SHOW_2:
			if action in ["FIRST", "START"]: _p7_code_3()
			
		State.CODE_SHOW_3:
			if action in ["FIRST", "START"]: 
				_p8_complexity()
				
		State.COMPLEXITY:
			if action in ["START", "FIRST"]: _p9_complete()
			
		State.LEVEL_COMPLETE:
			if action in ["START", "FIRST"]:
				state = State.FINISHED
				hide_panel()
				lesson_finished.emit()

# ═══════════════════════════════════════════════════════════
# ELEMENT SELECTED
# ═══════════════════════════════════════════════════════════

func element_selected(index: int, value: int):
	if state == State.GUIDED_CLICK_MID:
		if index == guided_mid:
			pending_index = index  
			pending_value = value
			_p2_check_mid()
		else:
			game_ui.show_choice_feedback(
				("CODA: \"That's not the middle!\n\n"
				+ "Left = %d, Right = %d\nMid = (%d + %d) / 2 = %d\n\n"
				+ "I need Shelf %d, but you clicked Shelf %d. Try again!\"") % [
					guided_left, guided_right, guided_left, guided_right, guided_mid, guided_mid, index
				]
			)
			
	elif state == State.PRACTICE_CLICK_MID:
		if index == practice_mid:
			pending_index = index
			pending_value = value
			_p4_check_mid()
		else:
			game_ui.show_choice_feedback(
				("Hint: Middle is (%d + %d) / 2 = %d.\n\n"
				+ "Click Shelf %d, not %d.") % [
					practice_left, practice_right, practice_mid, practice_mid, index
				]
			)
