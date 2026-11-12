## ============================================================
## DSA ACADEMY — LEVEL 03: BUBBLE SORT (COMPREHENSIVE)
##
## PHASE 1:  Introduction (scrambled array, adjacent elements)
## PHASE 2:  Guided Sort (teach swapping step by step)
## PHASE 3:  Reflection Quiz (why bubble?)
## PHASE 4:  Independent Practice (student drives)
## PHASE 5:  Knowledge Check (5 questions)
## PHASE 6:  Pseudocode
## PHASE 7:  Code Connection (C Code)
## PHASE 8:  Complexity Introduction (O(n²))
## PHASE 9:  Level Complete
## ============================================================

extends Lesson
class_name BubbleSortLesson

# ═══════════════════════════════════════════════════════════
# STATE MACHINE
# ═══════════════════════════════════════════════════════════
enum State {
	# ── Phase 1: Intro
	INTRO_WELCOME,
	INTRO_ADJACENT,
	INTRO_SWAP,

	# ── Phase 2: Guided
	GUIDED_COMPARE,
	GUIDED_SWAP_QUESTION,
	GUIDED_FEEDBACK,
	GUIDED_SWAPPING,
	GUIDED_AFTER_DECISION,
	GUIDED_PASS_COMPLETE,

	# ── Phase 3: Reflection
	REFLECT_INTRO,
	REFLECT_QUIZ,
	REFLECT_CORRECT,

	# ── Phase 4: Practice
	PRACTICE_INTRO,
	PRACTICE_COMPARE,
	PRACTICE_SWAP_QUESTION,
	PRACTICE_FEEDBACK,
	PRACTICE_SWAPPING,
	PRACTICE_AFTER_DECISION,
	PRACTICE_PASS_COMPLETE,
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

var state: State = State.INTRO_WELCOME

## Guided data
var guided_array: Array = [45, 12, 33, 8, 21]
var guided_n: int = 5
var guided_comparisons: int = 0
var guided_swaps: int = 0
var guided_pass: int = 0
var guided_j: int = 0
var guided_swaps_in_pass: int = 0

## Practice data
var practice_array: Array = [50, 10, 40, 20, 30]
var practice_n: int = 5
var practice_comparisons: int = 0
var practice_swaps: int = 0
var practice_pass: int = 0
var practice_j: int = 0
var practice_swaps_in_pass: int = 0

var current_mode: String = "GUIDED" # "GUIDED" or "PRACTICE"

## Interactive Lab State
var interactive_array: Array = [45, 12, 33, 8, 21]
var interactive_i: int = 0
var interactive_j: int = 0
var interactive_swaps: int = 0
var interactive_comparisons: int = 0
var _auto_playing: bool = false
var _auto_timer: float = 0.0
var _playback_speed: float = 1.0

var _kc_index: int = 0
var _kc_started: bool = false
const KC_QUESTIONS := [
	{
		"q":       "How does Bubble Sort work?",
		"opts":    ["By repeatedly swapping adjacent elements if they are in the wrong order",
					"By finding the minimum element and placing it at the beginning",
					"By dividing the array into two halves"],
		"correct": 0,
		"explain": "Bubble Sort compares adjacent pairs (side-by-side elements) and swaps them if the left one is bigger."
	},
	{
		"q":       "After ONE complete pass of Bubble Sort, what is guaranteed?",
		"opts":    ["The array is fully sorted",
					"The largest element is at its correct position at the very end",
					"The smallest element is at the beginning"],
		"correct": 1,
		"explain": "The largest element 'bubbles up' to the end during the first pass. We don't have to check that last position again!"
	},
	{
		"q":       "If we have N elements, how many passes do we need in the worst case?",
		"opts":    ["N-1 passes", "Just 1 pass", "N/2 passes"],
		"correct": 0,
		"explain": "We need N-1 passes to sort N elements, because each pass locks in one element at the end. The final element will automatically be in place."
	},
	{
		"q":       "How can we optimize Bubble Sort?",
		"opts":    ["Stop if a pass completes without making ANY swaps",
					"Always swap every element",
					"Skip checking the first element"],
		"correct": 0,
		"explain": "If we go through the whole array and make ZERO swaps, it means the array is already sorted! We can break out early."
	},
	{
		"q":       "What is the Time Complexity of Bubble Sort in the worst case?",
		"opts":    ["O(1)", "O(log n)", "O(n²)"],
		"correct": 2,
		"explain": "We make around N passes, and each pass makes up to N comparisons. N * N = O(n²), which is very slow for large datasets."
	},
]

# ═══════════════════════════════════════════════════════════
# START
# ═══════════════════════════════════════════════════════════

func _process(delta):
	if _auto_playing:
		_auto_timer += delta
		var delay = 1.2 / max(_playback_speed, 0.25)
		if _auto_timer >= delay:
			_auto_timer = 0.0
			step_interactive()

# ─── INTERACTIVE LAB CONTROLS ───
func step_interactive():
	if state == State.GUIDED_SWAP_QUESTION:
		var el1 = guided_array[guided_j]
		var el2 = guided_array[guided_j + 1]
		if el1 > el2:
			handle_action("FIRST")
		else:
			handle_action("MIDDLE")
		return
	elif state == State.GUIDED_AFTER_DECISION:
		handle_action("START")
		return
	elif state == State.GUIDED_PASS_COMPLETE:
		handle_action("START")
		return
	elif state == State.PRACTICE_SWAP_QUESTION:
		var el1 = practice_array[practice_j]
		var el2 = practice_array[practice_j + 1]
		if el1 > el2:
			handle_action("FIRST")
		else:
			handle_action("MIDDLE")
		return
	elif state == State.PRACTICE_AFTER_DECISION:
		handle_action("START")
		return

	# General Sandbox Bubble Sort Step
	if interactive_array.is_empty():
		interactive_array = [45, 12, 33, 8, 21]

	var n = interactive_array.size()
	if interactive_i >= n - 1:
		reset_interactive()
		return

	var j = interactive_j
	var val1 = interactive_array[j]
	var val2 = interactive_array[j + 1]
	interactive_comparisons += 1
	var needs_swap = (val1 > val2)

	if array_system:
		array_system.highlight_bubble_pair(j, j + 1, val1, val2)

	if needs_swap:
		interactive_swaps += 1
		interactive_array[j] = val2
		interactive_array[j + 1] = val1
		if array_system:
			array_system.swap_elements(j, j + 1, 0.35 / max(_playback_speed, 0.5))

	if game_ui:
		game_ui.highlight_code_line(4 if needs_swap else 3)
		game_ui.set_watch_variables({
			"Pass (i)": interactive_i,
			"Pair Index (j)": j,
			"arr[j]": val1,
			"arr[j+1]": val2,
			"Decision": "%d > %d -> SWAP!" % [val1, val2] if needs_swap else "%d <= %d -> KEEP" % [val1, val2],
			"Total Swaps": interactive_swaps,
			"Comparisons": interactive_comparisons
		})
		game_ui.set_complexity_stats(interactive_comparisons, int(n * (n - 1) / 2), "O(n²) Bubbling")
		var sorted_indices := []
		for s_idx in range(n - interactive_i, n):
			sorted_indices.append(s_idx)
		game_ui.update_array_ribbon(interactive_array, j, -1, [], -1, sorted_indices)
		game_ui.set_step("Comparing Pair: arr[%d]=%d and arr[%d]=%d" % [j, val1, j + 1, val2])
		game_ui.set_formula(
			("🔄 %d > %d → SWAP EXECUTED!" % [val1, val2]) if needs_swap else ("✓ %d <= %d → Order preserved" % [val1, val2])
		)

	interactive_j += 1
	if interactive_j >= n - interactive_i - 1:
		interactive_j = 0
		interactive_i += 1
		if array_system:
			array_system.mark_element_sorted(n - interactive_i)
		if interactive_i >= n - 1:
			if array_system:
				array_system.celebrate_array_sorted()
			if game_ui:
				game_ui.set_step("🎉 Bubble Sort Complete! Archive Fully Stabilized")
			set_auto_play(false)

func set_auto_play(is_playing: bool):
	_auto_playing = is_playing
	_auto_timer = 0.0
	if game_ui:
		game_ui.set_playback_state(is_playing)

func reset_interactive():
	_auto_playing = false
	interactive_i = 0
	interactive_j = 0
	interactive_swaps = 0
	interactive_comparisons = 0
	if array_system:
		array_system.set_sorting_mode(true)
		array_system.create_array(interactive_array)
	if game_ui:
		game_ui.set_playback_state(false)
		game_ui.highlight_code_line(2)
		game_ui.set_watch_variables({
			"Pass (i)": 0,
			"Pair Index (j)": 0,
			"arr[0]": interactive_array[0],
			"arr[1]": interactive_array[1],
			"Total Swaps": 0,
			"Comparisons": 0,
			"Status": "Ready to Sort"
		})
		game_ui.set_complexity_stats(0, int(interactive_array.size() * (interactive_array.size() - 1) / 2), "Ready")
		game_ui.update_array_ribbon(interactive_array, 0, -1, [])
		game_ui.set_step("Bubble Sort Lab: Press [⏭ STEP] or [▶ PLAY]")
		game_ui.set_formula("Pass 1 of %d • Compare adjacent pairs" % (interactive_array.size() - 1))

func randomize_interactive():
	var new_arr := []
	var pool := [8, 14, 21, 29, 35, 42, 53, 64, 72, 85, 96]
	pool.shuffle()
	for i in range(5):
		new_arr.append(pool[i])
	interactive_array = new_arr
	reset_interactive()

func set_playback_speed(speed: float):
	_playback_speed = speed

func start_lesson():
	apply_theme("bubble_sort")
	_reset_vars()
	state = State.INTRO_WELCOME
	_p1_welcome()

func _reset_vars():
	guided_comparisons = 0
	guided_swaps = 0
	guided_pass = 0
	guided_j = 0
	guided_swaps_in_pass = 0
	practice_comparisons = 0
	practice_swaps = 0
	practice_pass = 0
	practice_j = 0
	practice_swaps_in_pass = 0
	_kc_index = 0
	_kc_started = false
	guided_array = [45, 12, 33, 8, 21]
	practice_array = [50, 10, 40, 20, 30]

# ═══════════════════════════════════════════════════════════
# PHASE 1 — INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p1_welcome():
	if array_system:
		array_system.clear_all_visualizers()
		array_system.set_sorting_mode(true)
		array_system.create_array(guided_array)
	game_ui.set_lesson("Level 03 — Bubble Sort")
	game_ui.set_objective("Sort the archive: smallest → largest")
	if game_ui.has_method("set_sorting_pass"):
		game_ui.set_sorting_pass(1)
	elif game_ui.has_method("hide_target"):
		game_ui.hide_target()
	game_ui.set_step("Welcome to Level 03")
	game_ui.hide_formula()
	game_ui.show_lesson_message(
		"DSA ACADEMY  🎓\n\n"
		+ "LEVEL  03  ―  BUBBLE UP\n\n"
		+ "CODA: \"OH NO! Someone scrambled the archive! 😱\"\n\n"
		+ "Before we can use Binary Search again, we must SORT it.\n\n"
		+ "We will use an algorithm called BUBBLE SORT."
	)
	game_ui.set_hint("SPACE to continue")

func _p1_adjacent():
	state = State.INTRO_ADJACENT
	game_ui.set_step("Concept 1 of 2 — Adjacent Pairs")
	game_ui.set_formula("We only compare elements side-by-side (index 'j' and 'j+1')")
	game_ui.show_lesson_message(
		"CODA: \"Bubble Sort is simple.\"\n\n"
		+ "We look at two items that are next to each other (ADJACENT).\n"
		+ "Like looking at Shelf 0 and Shelf 1.\n\n"
		+ "If the LEFT item is BIGGER than the RIGHT item, they are out of order!"
	)

func _p1_swap():
	state = State.INTRO_SWAP
	game_ui.set_step("Concept 2 of 2 — Swapping")
	game_ui.set_formula("If LEFT > RIGHT → SWAP!")
	game_ui.show_lesson_message(
		"CODA: \"When they are out of order, we SWAP them!\"\n\n"
		+ "We do this over and over, moving from left to right.\n"
		+ "The largest values will slowly 'bubble up' to the end of the array.\n\n"
		+ "Let's fix this archive!"
	)

# ═══════════════════════════════════════════════════════════
# PHASE 2 — GUIDED
# ═══════════════════════════════════════════════════════════

func _p2_start():
	current_mode = "GUIDED"
	state = State.GUIDED_COMPARE
	guided_pass = 0
	guided_j = 0
	guided_comparisons = 0
	guided_swaps = 0
	guided_swaps_in_pass = 0
	game_ui.set_lesson("Guided Sort — Pass 1")
	if game_ui.has_method("set_sorting_pass"):
		game_ui.set_sorting_pass(1)
	_setup_comparison()

func _setup_comparison():
	var arr = guided_array if current_mode == "GUIDED" else practice_array
	var p = guided_pass if current_mode == "GUIDED" else practice_pass
	var j_idx = guided_j if current_mode == "GUIDED" else practice_j
	var n_val = guided_n if current_mode == "GUIDED" else practice_n
	var comps = guided_comparisons if current_mode == "GUIDED" else practice_comparisons
	
	var sorted_up_to = n_val - p - 1

	if j_idx >= sorted_up_to:
		if current_mode == "GUIDED":
			_handle_pass_complete()
		else:
			_handle_practice_pass_complete()
		return

	if current_mode == "GUIDED": state = State.GUIDED_SWAP_QUESTION
	else: state = State.PRACTICE_SWAP_QUESTION
	
	var left_val = arr[j_idx]
	var right_val = arr[j_idx + 1]
	
	if current_mode == "GUIDED": guided_comparisons += 1
	else: practice_comparisons += 1
	
	comps += 1

	if array_system:
		array_system.highlight_bubble_pair(j_idx, j_idx + 1, left_val, right_val)

	game_ui.set_step("Pass %d  |  Comparing Shelf %d (%d) & Shelf %d (%d)" % [p + 1, j_idx, left_val, j_idx + 1, right_val])
	game_ui.set_formula("Comparing: [%d] vs [%d]  |  Total Comparisons: %d" % [left_val, right_val, comps])

	game_ui.show_choice_message(
		("CODA: \"Compare Shelf %d (%d) and Shelf %d (%d).\n\n"
		+ "Is %d > %d? Are they out of order? Should I SWAP them?\"") % [j_idx, left_val, j_idx+1, right_val, left_val, right_val],
		["YES — Swap them!  🔄", "NO — They are in order!  ✅"]
	)

func _handle_pass_complete():
	var sorted_idx = guided_n - guided_pass - 1
	if array_system:
		array_system.mark_element_sorted(sorted_idx)
	state = State.GUIDED_PASS_COMPLETE
	var sorted_val = guided_array[sorted_idx]
	game_ui.show_choice_message(
		("✅  Pass %d Complete!\n\n"
		+ "• Largest unsorted number (%d) bubbled to Shelf %d and is now LOCKED (SORTED ✓).\n"
		+ "• Shelves [0 .. %d] remain to be sorted in the next pass.\n\n"
		+ "Ready for Pass %d?") % [
			guided_pass + 1, sorted_val, sorted_idx, sorted_idx - 1, guided_pass + 2
		],
		["Start Pass %d →" % (guided_pass + 2)]
	)

func _advance_pass():
	guided_pass += 1
	guided_j = 0
	
	var is_sorted := true
	for i in range(guided_n - 1):
		if guided_array[i] > guided_array[i + 1]:
			is_sorted = false
			break

	if is_sorted or guided_pass >= guided_n - 1:
		if array_system:
			array_system.celebrate_array_sorted()
		hide_formula()
		state = State.REFLECT_INTRO
		game_ui.show_lesson_message(
			("CODA: \"The entire archive is now fully sorted! 🎉\"\n\n"
			+ "Final Array:  %s\n\n"
			+ "Total Comparisons: %d  |  Total Swaps: %d\n\n"
			+ "All elements are in ascending order.\n"
			+ "Let's reflect on this algorithm!") % [
				str(guided_array), guided_comparisons, guided_swaps
			]
		)
	else:
		guided_swaps_in_pass = 0
		game_ui.set_lesson("Guided Sort — Pass %d" % (guided_pass + 1))
		if game_ui.has_method("set_sorting_pass"):
			game_ui.set_sorting_pass(guided_pass + 1)
		_setup_comparison()

func _show_guided_mistake(reason: String):
	state = State.GUIDED_FEEDBACK
	game_ui.show_choice_message(
		"⚠️  NOT QUITE!\n\n"
		+ reason + "\n\n"
		+ "In Bubble Sort, we arrange items in ASCENDING order (smallest to largest).\n"
		+ "Let's check this pair again!",
		["Try Again ↺  (or press SPACE)"]
	)

func _show_practice_mistake(reason: String):
	state = State.PRACTICE_FEEDBACK
	game_ui.show_choice_message(
		"⚠️  NOT QUITE!\n\n"
		+ reason + "\n\n"
		+ "Remember: If Left > Right, we must SWAP!",
		["Try Again ↺  (or press SPACE)"]
	)

func _do_swap():
	var arr = guided_array if current_mode == "GUIDED" else practice_array
	var j_idx = guided_j if current_mode == "GUIDED" else practice_j
	
	if current_mode == "GUIDED":
		state = State.GUIDED_SWAPPING
		guided_swaps += 1
		guided_swaps_in_pass += 1
	else:
		state = State.PRACTICE_SWAPPING
		practice_swaps += 1
		practice_swaps_in_pass += 1
		
	var temp = arr[j_idx]
	arr[j_idx] = arr[j_idx + 1]
	arr[j_idx + 1] = temp

	if array_system:
		var tween = array_system.swap_elements(j_idx, j_idx + 1, 0.5)
		if tween:
			tween.finished.connect(_on_swap_finished)
		else:
			_on_swap_finished()
	else:
		_on_swap_finished()

	# Safety fallback in case tween is interrupted or headless:
	if is_inside_tree() and get_tree() != null:
		var safety_timer := get_tree().create_timer(0.65)
		safety_timer.timeout.connect(func():
			if state == State.GUIDED_SWAPPING or state == State.PRACTICE_SWAPPING:
				_on_swap_finished()
		)

func _on_swap_finished():
	if state != State.GUIDED_SWAPPING and state != State.PRACTICE_SWAPPING:
		return
	var arr = guided_array if current_mode == "GUIDED" else practice_array
	var j_idx = guided_j if current_mode == "GUIDED" else practice_j
	if current_mode == "GUIDED":
		state = State.GUIDED_AFTER_DECISION
	else:
		state = State.PRACTICE_AFTER_DECISION
		
	if array_system:
		array_system.clear_bubble_pair(j_idx, j_idx + 1)
		
	game_ui.show_choice_message(
		("🔄  Swapped Successfully!\n\n"
		+ "• Shelf %d is now %d\n"
		+ "• Shelf %d is now %d\n\n"
		+ "The larger value bubbled rightward.") % [
			j_idx, arr[j_idx], j_idx + 1, arr[j_idx + 1]
		],
		["Continue →"]
	)

func _no_swap():
	var arr = guided_array if current_mode == "GUIDED" else practice_array
	var j_idx = guided_j if current_mode == "GUIDED" else practice_j
	if array_system:
		array_system.clear_bubble_pair(j_idx, j_idx + 1)
		
	if current_mode == "GUIDED":
		state = State.GUIDED_AFTER_DECISION
	else:
		state = State.PRACTICE_AFTER_DECISION
		
	game_ui.show_choice_message(
		("✅  Correct! Elements are in order.\n\n"
		+ "Shelf %d (%d) ≤ Shelf %d (%d).\n\n"
		+ "No swap needed. Moving to next pair!") % [
			j_idx, arr[j_idx], j_idx + 1, arr[j_idx + 1]
		],
		["Continue →"]
	)

func _advance_j():
	if current_mode == "GUIDED":
		guided_j += 1
	else:
		practice_j += 1
	_setup_comparison()

# ═══════════════════════════════════════════════════════════
# PHASE 3 — REFLECTION
# ═══════════════════════════════════════════════════════════

func _p3_show_reflection():
	state = State.REFLECT_QUIZ
	game_ui.set_step("Reflection Question")
	game_ui.set_formula("Think about the bubbling...")
	var ref_q = {
		"q": "Why is this algorithm called BUBBLE Sort?",
		"opts": [
			"Because it is super fast and pops like bubbles",
			"Because the largest unsorted value 'bubbles up' to the end in each pass",
			"Because it uses temporary memory like bubbles"
		],
		"correct": 1,
		"explain": "In every pass, adjacent comparisons push the largest unsorted number rightward, exactly like bubbles rising to the surface of water!"
	}
	if game_ui.has_method("show_quiz_question"):
		game_ui.show_quiz_question(ref_q, 0, 1)
	else:
		game_ui.show_choice_message(ref_q["q"], ref_q["opts"])

# ═══════════════════════════════════════════════════════════
# PHASE 4 — INDEPENDENT PRACTICE
# ═══════════════════════════════════════════════════════════

func _p4_intro():
	current_mode = "PRACTICE"
	state = State.PRACTICE_INTRO
	if array_system:
		array_system.clear_all_visualizers()
		array_system.set_sorting_mode(true)
		array_system.create_array(practice_array)
	game_ui.set_lesson("Practice — Your Turn! 💪")
	game_ui.set_objective("Sort the new archive")
	game_ui.set_step("Independent Practice")
	game_ui.set_formula("New array: %s" % [str(practice_array)])
	game_ui.show_lesson_message(
		("CODA: \"Your turn!\"\n\n"
		+ "New archive:  %s\n\n"
		+ "Remember:\n"
		+ "  ▶  If LEFT > RIGHT, click YES to swap.\n"
		+ "  ▶  If LEFT <= RIGHT, click NO.\n"
		+ "  ▶  I will not give you hints this time!") % [str(practice_array)]
	)

func _p4_start():
	practice_pass = 0
	practice_j = 0
	practice_comparisons = 0
	practice_swaps = 0
	practice_swaps_in_pass = 0
	if game_ui.has_method("set_sorting_pass"):
		game_ui.set_sorting_pass(1)
	_setup_comparison()

func _handle_practice_pass_complete():
	var sorted_idx = practice_n - practice_pass - 1
	if array_system:
		array_system.mark_element_sorted(sorted_idx)
	state = State.PRACTICE_PASS_COMPLETE
	var sorted_val = practice_array[sorted_idx]
	game_ui.show_choice_message(
		("✅  Pass %d complete!\n\n"
		+ "• Largest number in this pass (%d) locked at Shelf %d.\n"
		+ "• Archive so far: %s") % [practice_pass + 1, sorted_val, sorted_idx, str(practice_array)],
		["Start Pass %d →" % (practice_pass + 2)]
	)

func _advance_practice_pass():
	practice_pass += 1
	practice_j = 0
	var is_sorted := true
	for i in range(practice_n - 1):
		if practice_array[i] > practice_array[i + 1]:
			is_sorted = false
			break

	if is_sorted or practice_pass >= practice_n - 1:
		if array_system:
			array_system.celebrate_array_sorted()
		hide_formula()
		state = State.PRACTICE_DONE
		game_ui.show_lesson_message(
			("CODA: \"Excellent! The archive is fully sorted! 🎉\"\n\n"
			+ "Final Array: %s\n"
			+ "Comparisons: %d  |  Swaps: %d\n\n"
			+ "Let's check your knowledge!") % [
				str(practice_array), practice_comparisons, practice_swaps
			]
		)
	else:
		practice_swaps_in_pass = 0
		game_ui.set_lesson("Practice Sort — Pass %d" % (practice_pass + 1))
		if game_ui.has_method("set_sorting_pass"):
			game_ui.set_sorting_pass(practice_pass + 1)
		_setup_comparison()

# ═══════════════════════════════════════════════════════════
# PHASE 5 — KNOWLEDGE CHECK
# ═══════════════════════════════════════════════════════════

func _p5_start():
	_kc_index = 0
	_kc_started = true
	state     = State.KC_ACTIVE
	game_ui.set_lesson("Knowledge Check 📝")
	game_ui.set_objective("Test your understanding of Bubble Sort")
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
	game_ui.set_lesson("Pseudocode")
	game_ui.set_step("Phase 6 — Pseudocode")
	game_ui.set_formula("A loop inside a loop! Two levels of repetition.")
	game_ui.show_lesson_message(
		"CODA: \"Here is what you just did, written in pseudocode!\"\n\n"
		+ "════════════════════════════════\n"
		+ "BUBBLE SORT — PSEUDOCODE\n"
		+ "════════════════════════════════\n\n"
		+ "FOR pass from 0 to N-1:\n"
		+ "    FOR j from 0 to N-pass-1:\n"
		+ "        IF array[j] > array[j+1]:\n"
		+ "            SWAP array[j] AND array[j+1]\n\n"
		+ "════════════════════════════════\n\n"
		+ "Notice the NESTED loops. A loop inside a loop!"
	)

# ═══════════════════════════════════════════════════════════
# PHASE 7 — CODE CONNECTION
# ═══════════════════════════════════════════════════════════

func _p7_code_1():
	state = State.CODE_SHOW_1
	game_ui.set_step("Phase 7 — Real Code in C (Step 1)")
	game_ui.set_formula("The outer loop handles the passes")
	game_ui.show_c_code_step(
		"Bubble Sort in C — The Outer Pass Loop",
		"void bubble_sort(int arr[], int n) {\n"
		+ ">   for (int i = 0; i < n - 1; i++) {\n"
		+ "        // inner loop\n"
		+ "    }\n"
		+ "}",
		"CODA: \"The outer 'for' loop runs N-1 times. These correspond to the passes across the archive!\"",
		"Next: The Inner Loop →"
	)

func _p7_code_2():
	state = State.CODE_SHOW_2
	game_ui.set_step("Phase 7 — Real Code in C (Step 2)")
	game_ui.set_formula("The inner loop compares adjacent elements")
	game_ui.show_c_code_step(
		"Bubble Sort in C — The Inner Comparison Loop",
		"void bubble_sort(int arr[], int n) {\n"
		+ "    for (int i = 0; i < n - 1; i++) {\n"
		+ ">       for (int j = 0; j < n - i - 1; j++) {\n"
		+ "            // comparison and swap\n"
		+ "        }\n"
		+ "    }\n"
		+ "}",
		"CODA: \"The inner loop goes from 0 up to 'n - i - 1'. Why '- i'?\n"
		+ "Because in each pass, the largest items have already bubbled to the end!\"",
		"Next: The Swap Logic →"
	)

func _p7_code_3():
	state = State.CODE_SHOW_3
	game_ui.set_step("Phase 7 — Real Code in C (Step 3)")
	game_ui.set_formula("Swap requires a temporary variable")
	game_ui.show_c_code_step(
		"Bubble Sort in C — The Swap Logic",
		"        for (int j = 0; j < n - i - 1; j++) {\n"
		+ ">           if (arr[j] > arr[j + 1]) {\n"
		+ ">               int temp = arr[j];\n"
		+ ">               arr[j] = arr[j + 1];\n"
		+ ">               arr[j + 1] = temp;\n"
		+ "            }\n"
		+ "        }\n"
		+ "    }\n"
		+ "}",
		"CODA: \"We use a 'temp' variable to hold arr[j] so it doesn't get erased during the swap!\"",
		"Understood! →"
	)

# ═══════════════════════════════════════════════════════════
# PHASE 8 — COMPLEXITY INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p8_complexity():
	state = State.COMPLEXITY
	game_ui.set_step("Phase 8 — Efficiency (O(n²))")
	game_ui.set_formula("Nested Loops = O(n * n) = O(n²)")
	game_ui.show_lesson_message(
		"CODA: \"How fast is Bubble Sort? Not very.\"\n\n"
		+ "If we have N items, we do N passes, and in each pass we do about N checks.\n"
		+ "N * N = N².\n\n"
		+ "For 1,000 items, that's 1,000,000 checks!\n"
		+ "This is called QUADRATIC TIME complexity: O(n²)."
	)

# ═══════════════════════════════════════════════════════════
# PHASE 9 — LEVEL COMPLETE
# ═══════════════════════════════════════════════════════════

func _p9_complete():
	state = State.LEVEL_COMPLETE
	game_ui.set_step("🎓  Level 03 Complete!")
	game_ui.set_formula("Bubble Sort: O(n²)  |  Easy to write, slow to run")
	game_ui.show_lesson_message(
		"🎉  LEVEL  03  COMPLETE!\n\n"
		+ "CODA: \"Fantastic job sorting the archive!\"\n\n"
		+ "  ✅  Bubble Sort works by swapping adjacent elements\n"
		+ "  ✅  Largest items 'bubble up' to the end\n"
		+ "  ✅  It uses NESTED loops (a loop inside a loop)\n"
		+ "  ✅  Time Complexity is O(n²) — quite slow for large data\n\n"
		+ "CODA: \"You have completed the DSA Academy!\"\n"
		+ "\"You are now ready to write some super fast code!\""
	)

# ═══════════════════════════════════════════════════════════
# MAIN DISPATCH — handle_action
# ═══════════════════════════════════════════════════════════

func handle_action(action: String):
	match state:
		State.INTRO_WELCOME:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]: _p1_adjacent()
		State.INTRO_ADJACENT:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]: _p1_swap()
		State.INTRO_SWAP:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]: _p2_start()
			
		State.GUIDED_SWAP_QUESTION:
			if action == "FIRST":
				if guided_array[guided_j] > guided_array[guided_j + 1]:
					_do_swap()
				else:
					_show_guided_mistake("Shelf %d (%d) ≤ Shelf %d (%d)!\nThey are ALREADY in correct order. No swap is needed." % [
						guided_j, guided_array[guided_j], guided_j + 1, guided_array[guided_j + 1]
					])
			elif action == "MIDDLE":
				if guided_array[guided_j] <= guided_array[guided_j + 1]:
					_no_swap()
				else:
					_show_guided_mistake("Shelf %d (%d) > Shelf %d (%d)!\nSince %d is greater than %d, they are out of order and MUST be swapped." % [
						guided_j, guided_array[guided_j], guided_j + 1, guided_array[guided_j + 1],
						guided_array[guided_j], guided_array[guided_j + 1]
					])
			elif action in ["START", "NEXT"]:
				_setup_comparison()

		State.GUIDED_FEEDBACK:
			if action in ["START", "FIRST", "MIDDLE", "LAST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_setup_comparison()

		State.GUIDED_SWAPPING:
			if action in ["START", "FIRST"]:
				_on_swap_finished()

		State.GUIDED_AFTER_DECISION:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_advance_j()
				
		State.GUIDED_PASS_COMPLETE:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_advance_pass()

		State.REFLECT_INTRO:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_p3_show_reflection()

		State.REFLECT_QUIZ:
			if action in ["QUIZ_NEXT", "NEXT"]:
				state = State.REFLECT_CORRECT
				hide_panel()
				game_ui.show_lesson_message("✅  Exactly right!\n\nThe largest items bubble up to the top, like bubbles rising to the water's surface.\n\nNow try it yourself in Independent Practice!")
			elif action == "MIDDLE": 
				state = State.REFLECT_CORRECT
				hide_panel()
				game_ui.show_lesson_message("✅  Exactly right!\n\nThe largest items bubble up to the top, like bubbles rising to the water's surface.\n\nNow try it yourself in Independent Practice!")
			elif action in ["FIRST", "LAST"]:
				game_ui.show_choice_feedback("Think about what happens to the largest value in each pass — it bubbles rightward.")
			elif action == "START":
				_p3_show_reflection()

		State.REFLECT_CORRECT:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_p4_intro()
			
		State.PRACTICE_INTRO:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_p4_start()
			
		State.PRACTICE_SWAP_QUESTION:
			if action == "FIRST":
				if practice_array[practice_j] > practice_array[practice_j + 1]:
					_do_swap()
				else:
					_show_practice_mistake("Shelf %d (%d) ≤ Shelf %d (%d)!\nThese numbers are already sorted. No swap needed." % [
						practice_j, practice_array[practice_j], practice_j + 1, practice_array[practice_j + 1]
					])
			elif action == "MIDDLE":
				if practice_array[practice_j] <= practice_array[practice_j + 1]:
					_no_swap()
				else:
					_show_practice_mistake("Shelf %d (%d) > Shelf %d (%d)!\nLeft is greater than Right. We must SWAP them!" % [
						practice_j, practice_array[practice_j], practice_j + 1, practice_array[practice_j + 1]
					])
			elif action in ["START", "NEXT"]:
				_setup_comparison()

		State.PRACTICE_FEEDBACK:
			if action in ["START", "FIRST", "MIDDLE", "LAST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_setup_comparison()

		State.PRACTICE_SWAPPING:
			if action in ["START", "FIRST"]:
				_on_swap_finished()

		State.PRACTICE_AFTER_DECISION:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_advance_j()
				
		State.PRACTICE_PASS_COMPLETE:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_advance_practice_pass()
				
		State.PRACTICE_DONE:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				hide_panel()
				_p5_start()

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
			if action in ["START", "FIRST", "QUIZ_NEXT", "NEXT"]:
				_p5_show_question()
			
		State.PSEUDOCODE:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]: _p7_code_1()
			
		State.CODE_SHOW_1:
			if action in ["FIRST", "START", "NEXT", "QUIZ_NEXT"]: _p7_code_2()
			
		State.CODE_SHOW_2:
			if action in ["FIRST", "START", "NEXT", "QUIZ_NEXT"]: _p7_code_3()
			
		State.CODE_SHOW_3:
			if action in ["FIRST", "START", "NEXT", "QUIZ_NEXT"]: 
				_p8_complexity()
				
		State.COMPLEXITY:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]: _p9_complete()
			
		State.LEVEL_COMPLETE:
			if action in ["START", "FIRST", "NEXT", "QUIZ_NEXT"]:
				state = State.FINISHED
				hide_panel()
				lesson_finished.emit()

# ═══════════════════════════════════════════════════════════
# ELEMENT SELECTED (3D World Shelf Clicking)
# ═══════════════════════════════════════════════════════════

func element_selected(index: int, value: int):
	var arr = guided_array if current_mode == "GUIDED" else practice_array
	var j_idx = guided_j if current_mode == "GUIDED" else practice_j

	match state:
		State.GUIDED_SWAP_QUESTION, State.PRACTICE_SWAP_QUESTION:
			if index == j_idx or index == j_idx + 1:
				if arr[j_idx] > arr[j_idx + 1]:
					_do_swap()
				else:
					_no_swap()
			else:
				if game_ui and game_ui.has_method("set_hint"):
					game_ui.set_hint("Comparing Shelf %d and %d (amber glow). Click them or choose YES/NO!" % [j_idx, j_idx + 1])

		State.GUIDED_FEEDBACK, State.PRACTICE_FEEDBACK:
			hide_panel()
			_setup_comparison()

		State.GUIDED_AFTER_DECISION, State.PRACTICE_AFTER_DECISION:
			hide_panel()
			_advance_j()

		State.GUIDED_PASS_COMPLETE:
			hide_panel()
			_advance_pass()

		State.PRACTICE_PASS_COMPLETE:
			hide_panel()
			_advance_practice_pass()

		State.PRACTICE_DONE:
			hide_panel()
			_p5_start()

		State.LEVEL_COMPLETE:
			state = State.FINISHED
			hide_panel()
			lesson_finished.emit()
