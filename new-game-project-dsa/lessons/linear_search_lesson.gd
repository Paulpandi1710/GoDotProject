## ============================================================
## DSA ACADEMY — LEVEL 01: LINEAR SEARCH (COMPREHENSIVE)
##
## PHASE 1:  Introduction  (what is array/index/target/algorithm)
## PHASE 2:  Guided Search  (teach each comparison step by step)
## PHASE 3:  Reflection Quiz  (why index 0?)
## PHASE 4:  Independent Practice  (student drives)
## PHASE 4B: Not-Found Scenario  (target does not exist)
## PHASE 5:  Knowledge Check  (5 quiz questions)
## PHASE 6:  Pseudocode
## PHASE 7:  Code Connection  (C language, 3-step walkthrough)
## PHASE 8:  Complexity Introduction  (O(n) with examples)
## PHASE 8B: Mini Challenge  (predict comparisons)
## PHASE 9:  Level Complete + Reward
## ============================================================

extends Lesson
class_name LinearSearchLesson

# ═══════════════════════════════════════════════════════════
# STATE MACHINE
# ═══════════════════════════════════════════════════════════
enum State {
	# ── Phase 1: Introduction
	INTRO_WELCOME,
	INTRO_ARRAY,
	INTRO_ELEMENT,
	INTRO_INDEX,
	INTRO_INDEX_ZERO,
	INTRO_TARGET,
	INTRO_SEARCH_CONCEPT,
	INTRO_ALGORITHM,

	# ── Phase 2: Guided Search
	GUIDED_PRE_QUIZ,      # "Where should search begin?"
	GUIDED_SEARCHING,     # waiting for student to click active element
	GUIDED_COMPARE_SHOW,  # comparison quiz / result shown
	GUIDED_RESULT_SHOWN,  # result explanation visible, waiting to advance

	# ── Phase 3: Reflection
	REFLECT_QUIZ,
	REFLECT_CORRECT,

	# ── Phase 4: Independent Practice
	PRACTICE_INTRO,
	PRACTICE_SEARCHING,
	PRACTICE_DONE,

	# ── Phase 4B: Not-Found Scenario
	NOT_FOUND_INTRO,
	NOT_FOUND_SEARCHING,
	NOT_FOUND_DONE,
	NOT_FOUND_EXPLAIN,

	# ── Phase 5: Knowledge Check
	KC_ACTIVE,
	KC_CORRECT_EXPLAIN,

	# ── Phase 6-9: Theory + Finish
	PSEUDOCODE,
	CODE_SHOW_1,
	CODE_SHOW_2,
	CODE_SHOW_3,
	COMPLEXITY,

	# ── Phase 8B: Mini Challenge
	CHALLENGE_INTRO,
	CHALLENGE_PREDICT,
	CHALLENGE_SEARCHING,
	CHALLENGE_RESULT,

	# ── Phase 9: Complete
	LEVEL_COMPLETE,
	FINISHED
}

# ═══════════════════════════════════════════════════════════
# DATA
# ═══════════════════════════════════════════════════════════

var state: State = State.INTRO_WELCOME

## Guided search — [10, 25, 40, 15, 30], target = 40
const GUIDED_ARRAY   := [10, 25, 40, 15, 30]
const GUIDED_TARGET  := 40

## Independent practice — [15, 50, 20, 35, 70], target = 35
const PRACTICE_ARRAY  := [15, 50, 20, 35, 70]
const PRACTICE_TARGET := 35

## Not-Found scenario — same array, impossible target
const NOT_FOUND_ARRAY  := [10, 25, 40, 15, 30]
const NOT_FOUND_TARGET := 99

## Mini Challenge — [55, 12, 80, 25, 90, 30], target = 90
const CHALLENGE_ARRAY  := [55, 12, 80, 25, 90, 30]
const CHALLENGE_TARGET := 90

var guided_index:        int = 0
var guided_comparisons:  int = 0
var practice_index:      int = 0
var practice_comparisons:int = 0
var not_found_index:     int = 0
var not_found_comparisons:int = 0
var challenge_index:     int = 0
var challenge_comparisons:int = 0
var challenge_prediction: int = -1

## Track whether the guided comparison quiz has been answered
var _guided_quiz_answered: bool = false
var _guided_pending_index: int  = -1
var _guided_pending_value: int  = -1

## Interactive Lab State
var interactive_array: Array = [10, 25, 40, 15, 30]
var interactive_target: int = 40
var interactive_index: int = 0
var interactive_comparisons: int = 0
var interactive_checked: Array = []
var interactive_found_idx: int = -1
var _auto_playing: bool = false
var _auto_timer: float = 0.0
var _playback_speed: float = 1.0

## Knowledge check
var _kc_index: int = 0
var _kc_started: bool = false
const KC_QUESTIONS := [
	{
		"q":       "What is an ARRAY?",
		"opts":    ["A collection of values stored in an ordered sequence",
					"A single number stored in memory",
					"A loop that repeats instructions"],
		"correct": 0,
		"explain": "An ARRAY is a collection of values stored in a fixed order. Each value is called an element, and each element has a position called an index."
	},
	{
		"q":       "What INDEX does the FIRST element of an array have?",
		"opts":    ["Index 1",
					"Index 0",
					"It depends on the array size"],
		"correct": 1,
		"explain": "Array indexing ALWAYS starts at 0. The first element is at index 0, the second at index 1, and so on. This is true in almost every programming language."
	},
	{
		"q":       "Where does Linear Search START?",
		"opts":    ["At the last element (highest index)",
					"At the middle element",
					"At index 0 — the very first element"],
		"correct": 2,
		"explain": "Linear Search always starts at index 0. If it started anywhere else, it would risk missing the target. The algorithm must check every element in order."
	},
	{
		"q":       "What does Linear Search do when the current element does NOT match the target?",
		"opts":    ["It stops — the target is not in the array",
					"It jumps to a random element",
					"It moves to the NEXT element (index + 1) and compares again"],
		"correct": 2,
		"explain": "When the current element doesn't match, Linear Search moves to the next index (index + 1) and tries again. It repeats this until a match is found or the array ends."
	},
	{
		"q":       "In the WORST case, how many elements does Linear Search check?",
		"opts":    ["Just 1 element — the first one is always the target",
					"Half the elements — it skips every other one",
					"ALL elements — it may check every single one"],
		"correct": 2,
		"explain": "In the worst case (target is last, or not in the array), Linear Search checks EVERY element. If the array has N elements, it makes N comparisons. Programmers write this as O(n)."
	},
]

## Hint system
var _hint_timer: float = 0.0
var _hint_level: int = 0
const HINT_TIMEOUT: float = 8.0


# ═══════════════════════════════════════════════════════════
# START
# ═══════════════════════════════════════════════════════════

func start_lesson():
	apply_theme("linear_search")
	_reset_vars()
	state = State.INTRO_WELCOME
	_p1_welcome()


func _reset_vars():
	guided_index          = 0
	guided_comparisons    = 0
	practice_index        = 0
	practice_comparisons  = 0
	not_found_index       = 0
	not_found_comparisons = 0
	challenge_index       = 0
	challenge_comparisons = 0
	challenge_prediction  = -1
	_guided_quiz_answered = false
	_guided_pending_index = -1
	_guided_pending_value = -1
	_kc_index             = 0
	_kc_started           = false
	_hint_timer           = 0.0
	_hint_level           = 0


# ═══════════════════════════════════════════════════════════
# HINT SYSTEM — progressive hints on idle
# ═══════════════════════════════════════════════════════════

func _process(delta):
	if _auto_playing:
		_auto_timer += delta
		var delay = 1.0 / max(_playback_speed, 0.25)
		if _auto_timer >= delay:
			_auto_timer = 0.0
			step_interactive()

	if state in [State.GUIDED_SEARCHING, State.PRACTICE_SEARCHING,
				 State.NOT_FOUND_SEARCHING, State.CHALLENGE_SEARCHING]:
		if not panel_open():
			_hint_timer += delta
			if _hint_timer >= HINT_TIMEOUT:
				_hint_timer = 0.0
				_show_progressive_hint()

# ─── INTERACTIVE LAB CONTROLS ───
func step_interactive():
	if state == State.GUIDED_SEARCHING:
		if guided_index < GUIDED_ARRAY.size():
			element_selected(guided_index, GUIDED_ARRAY[guided_index])
		return
	elif state == State.GUIDED_COMPARE_SHOW:
		handle_action("FIRST" if GUIDED_ARRAY[guided_index] == GUIDED_TARGET else "MIDDLE")
		return
	elif state == State.GUIDED_RESULT_SHOWN:
		handle_action("START")
		return
	elif state == State.PRACTICE_SEARCHING:
		if practice_index < PRACTICE_ARRAY.size():
			element_selected(practice_index, PRACTICE_ARRAY[practice_index])
		return
	elif state == State.NOT_FOUND_SEARCHING:
		if not_found_index < NOT_FOUND_ARRAY.size():
			element_selected(not_found_index, NOT_FOUND_ARRAY[not_found_index])
		return
	elif state == State.CHALLENGE_SEARCHING:
		if challenge_index < CHALLENGE_ARRAY.size():
			element_selected(challenge_index, CHALLENGE_ARRAY[challenge_index])
		return

	# General Interactive Sandbox Step
	if interactive_array.is_empty():
		interactive_array = [10, 25, 40, 15, 30]

	if interactive_found_idx != -1 or interactive_index >= interactive_array.size():
		reset_interactive()
		return

	var idx = interactive_index
	var val = interactive_array[idx]
	interactive_comparisons += 1
	var is_match: bool = (val == interactive_target)

	if array_system:
		array_system.current_search_index = idx
		array_system.update_active_element()
		array_system.execute_comparison(idx, val)

	if game_ui:
		game_ui.highlight_code_line(2 if not is_match else 3)
		game_ui.set_watch_variables({
			"Active Index (i)": idx,
			"Array Element arr[i]": val,
			"Target Value": interactive_target,
			"Comparisons": interactive_comparisons,
			"Live Status": "MATCH FOUND! ✅" if is_match else "Mismatch (%d ≠ %d) ❌" % [val, interactive_target]
		})
		game_ui.set_complexity_stats(interactive_comparisons, interactive_array.size(), "O(n) Linear scan")
		game_ui.update_array_ribbon(interactive_array, idx, interactive_target, interactive_checked, idx if is_match else -1)
		game_ui.set_step("Probing Index %d: Value %d with Target %d" % [idx, val, interactive_target])
		game_ui.set_formula(
			("✅ MATCH FOUND! arr[%d] = %d" % [idx, val]) if is_match else ("❌ %d ≠ %d → Moving to index %d" % [val, interactive_target, idx + 1])
		)

	if is_match:
		interactive_found_idx = idx
		set_auto_play(false)
	else:
		interactive_checked.append(idx)
		interactive_index += 1
		if interactive_index >= interactive_array.size():
			if game_ui:
				game_ui.highlight_code_line(6)
				game_ui.set_step("Target %d not found after checking all %d elements" % [interactive_target, interactive_array.size()])
			set_auto_play(false)

func set_auto_play(is_playing: bool):
	_auto_playing = is_playing
	_auto_timer = 0.0
	if game_ui:
		game_ui.set_playback_state(is_playing)

func reset_interactive():
	_auto_playing = false
	interactive_index = 0
	interactive_comparisons = 0
	interactive_checked.clear()
	interactive_found_idx = -1
	if array_system:
		array_system.target_value = interactive_target
		array_system.create_array(interactive_array)
		array_system.start_search()
	if game_ui:
		game_ui.set_playback_state(false)
		game_ui.highlight_code_line(1)
		game_ui.set_watch_variables({
			"Active Index (i)": 0,
			"Array Element arr[i]": interactive_array[0] if interactive_array.size() > 0 else "--",
			"Target Value": interactive_target,
			"Comparisons": 0,
			"Live Status": "Ready to Scan"
		})
		game_ui.set_complexity_stats(0, interactive_array.size(), "Ready")
		game_ui.update_array_ribbon(interactive_array, 0, interactive_target, [])
		game_ui.set_step("Interactive Lab: Press [⏭ STEP] or [▶ PLAY]")
		game_ui.set_formula("Array size = %d | Target = %d" % [interactive_array.size(), interactive_target])

func set_target_interactive(val: int):
	interactive_target = val
	reset_interactive()

func randomize_interactive():
	var new_arr := []
	var pool := [10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 80, 90]
	pool.shuffle()
	for i in range(5):
		new_arr.append(pool[i])
	interactive_array = new_arr
	interactive_target = new_arr[randi() % new_arr.size()]
	if game_ui:
		game_ui.set_deck_target_label(interactive_target)
	reset_interactive()

func set_playback_speed(speed: float):
	_playback_speed = speed


func _show_progressive_hint():
	_hint_level += 1
	match _hint_level:
		1:
			game_ui.set_hint("💡 HINT: Start with the active element.")
		2:
			game_ui.set_hint("💡 HINT: Compare its value with the target.")
		3:
			game_ui.set_hint("💡 HINT: Look at the value on the target panel.")
		_:
			game_ui.set_hint("💡 HINT: Click the highlighted (glowing) element.")
			_hint_level = 0


func _reset_hints():
	_hint_timer = 0.0
	_hint_level = 0


# ═══════════════════════════════════════════════════════════
# PHASE 1 — INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p1_welcome():
	if array_system:
		array_system.target_value = GUIDED_TARGET
		array_system.create_array(GUIDED_ARRAY)
	game_ui.set_lesson("Level 01 — Linear Search")
	game_ui.set_objective("Learn how computers search for a value")
	game_ui.set_target(GUIDED_TARGET)
	game_ui.set_step("Welcome to DSA Academy")
	game_ui.hide_formula()
	game_ui.show_lesson_message(
		"DSA ACADEMY  🎓\n\n"
		+ "LEVEL  01  ―  FIND THE TARGET\n\n"
		+ "CODA: \"Hello! I'm CODA — your personal Archive Robot.\"\n\n"
		+ "\"Someone lost a file deep inside this data archive. "
		+ "We need to find it!\"\n\n"
		+ "\"In this lesson you will learn exactly how a computer "
		+ "searches for a value inside an array. No prior knowledge "
		+ "needed — I'll guide you through every single step!\""
	)
	game_ui.set_hint("SPACE / ENTER to continue")


func _p1_array():
	state = State.INTRO_ARRAY
	game_ui.set_step("Concept 1 of 6 — What is an ARRAY?")
	game_ui.set_formula("Array  =  a row of boxes, each holding one value")
	game_ui.show_lesson_message(
		"CODA: \"Look at the row of boxes in front of you! 📦\"\n\n"
		+ "Together they form an  ARRAY.\n\n"
		+ "  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐\n"
		+ "  │ 10 │  │ 25 │  │ 40 │  │ 15 │  │ 30 │\n"
		+ "  └────┘  └────┘  └────┘  └────┘  └────┘\n\n"
		+ "An ARRAY is a collection of values stored in a "
		+ "fixed, ordered sequence.\n\n"
		+ "Think of it like a row of shelves in an archive — "
		+ "each shelf holds exactly ONE file."
	)


func _p1_element():
	state = State.INTRO_ELEMENT
	game_ui.set_step("Concept 2 of 6 — What is an ELEMENT?")
	game_ui.set_formula("Each box is one ELEMENT  →  a single value in the array")
	game_ui.show_lesson_message(
		"CODA: \"Each box holds exactly ONE value.\"\n\n"
		+ "That value is called an  ELEMENT.\n\n"
		+ "In our array:\n\n"
		+ "  Element 1  →  value  10\n"
		+ "  Element 2  →  value  25\n"
		+ "  Element 3  →  value  40\n"
		+ "  Element 4  →  value  15\n"
		+ "  Element 5  →  value  30\n\n"
		+ "We have 5 elements in total.\n\n"
		+ "But how do we tell the computer WHICH element we mean? "
		+ "We need a way to number them..."
	)


func _p1_index():
	state = State.INTRO_INDEX
	game_ui.set_step("Concept 3 of 6 — What is an INDEX?")
	game_ui.set_formula("Index:  0     1     2     3     4")
	game_ui.show_lesson_message(
		"CODA: \"Every element has a position called its INDEX.\"\n\n"
		+ "  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐\n"
		+ "  │ 10 │  │ 25 │  │ 40 │  │ 15 │  │ 30 │\n"
		+ "  └────┘  └────┘  └────┘  └────┘  └────┘\n"
		+ "   [0]    [1]    [2]    [3]    [4]\n\n"
		+ "The INDEX tells us where each element is:\n\n"
		+ "  array[0] = 10\n"
		+ "  array[1] = 25\n"
		+ "  array[2] = 40\n"
		+ "  array[3] = 15\n"
		+ "  array[4] = 30\n\n"
		+ "But wait... why does it start at 0 and not 1?"
	)


func _p1_index_zero():
	state = State.INTRO_INDEX_ZERO
	game_ui.set_step("Concept 4 of 6 — Why does INDEX start at 0?")
	game_ui.set_formula("FIRST element → INDEX 0  |  SECOND → INDEX 1  |  THIRD → INDEX 2")
	game_ui.show_lesson_message(
		"CODA: \"This is one of the most important rules!\"\n\n"
		+ "⚠  The FIRST element is at INDEX 0.\n\n"
		+ "Not index 1 — index ZERO.\n\n"
		+ "  FIRST element   →  INDEX 0  →  value 10\n"
		+ "  SECOND element  →  INDEX 1  →  value 25\n"
		+ "  THIRD element   →  INDEX 2  →  value 40\n\n"
		+ "This is true in almost every programming language\n"
		+ "in the world: C, Python, Java, JavaScript...\n\n"
		+ "\"Think of it like building floors — "
		+ "the ground floor is floor 0!\""
	)


func _p1_target():
	state = State.INTRO_TARGET
	game_ui.set_step("Concept 5 of 6 — What is the TARGET?")
	game_ui.set_formula("TARGET = 40   ←   this is the file CODA needs to find")
	game_ui.show_lesson_message(
		"CODA: \"I need to find File #40.\"\n\n"
		+ "The value I'm searching for is called the  TARGET.\n\n"
		+ "  TARGET  =  40\n\n"
		+ "Check the top-left HUD — the target is shown there in green.\n\n"
		+ "My goal is to find which element in the array has value 40.\n\n"
		+ "But how? I can't just look at all of them at once — "
		+ "I need a systematic way to search!"
	)


func _p1_search_concept():
	state = State.INTRO_SEARCH_CONCEPT
	game_ui.set_step("Concept 6 of 6 — How should we search?")
	game_ui.set_formula("SEARCHING = checking elements to find the target")
	game_ui.show_lesson_message(
		"CODA: \"How should we find File #40?\"\n\n"
		+ "We could check elements randomly...\n"
		+ "but we might check the same one twice!\n\n"
		+ "We could start from the end...\n"
		+ "but that's just as slow!\n\n"
		+ "The simplest approach:\n\n"
		+ "  START  →  INDEX 0\n"
		+ "     ↓\n"
		+ "  CHECK  →  INDEX 1\n"
		+ "     ↓\n"
		+ "  CHECK  →  INDEX 2\n"
		+ "     ↓\n"
		+ "  CHECK  →  INDEX 3\n"
		+ "     ↓\n"
		+ "  CHECK  →  INDEX 4\n\n"
		+ "Check every element in order — one by one!\n"
		+ "This approach has a name..."
	)


func _p1_algorithm():
	state = State.INTRO_ALGORITHM
	game_ui.set_step("LINEAR SEARCH — The Algorithm")
	game_ui.set_formula("Linear Search: index 0 → 1 → 2 → ... → compare each with target")
	game_ui.show_lesson_message(
		"CODA: \"This method is called  LINEAR SEARCH.\"\n\n"
		+ "The rules:\n\n"
		+ "  1.  Start at INDEX 0 — the very first element.\n"
		+ "  2.  COMPARE the current value with the target.\n"
		+ "  3.  If they  MATCH  →  target found!  ✅\n"
		+ "  4.  If they  DON'T match  →  move to INDEX + 1.\n"
		+ "  5.  Repeat until found, or the array ends.\n\n"
		+ "⚠  We NEVER skip elements.\n"
		+ "⚠  We ALWAYS go left to right, in order.\n\n"
		+ "\"Linear\" means \"in a line\" — checking one after another.\n\n"
		+ "Now let's experience it together!"
	)


# ═══════════════════════════════════════════════════════════
# PHASE 2 — GUIDED SEARCH
# ═══════════════════════════════════════════════════════════

func _p2_start():
	guided_index       = 0
	guided_comparisons = 0
	state              = State.GUIDED_PRE_QUIZ
	if array_system:
		array_system.target_value = GUIDED_TARGET
		array_system.create_array(GUIDED_ARRAY)
	game_ui.set_lesson("Guided Search — CODA teaches")
	game_ui.set_objective("Find File #%d in the array" % GUIDED_TARGET)
	game_ui.set_target(GUIDED_TARGET)
	game_ui.set_step("Guided Search — Where do we start?")
	game_ui.set_formula("Array: [10, 25, 40, 15, 30]   |   Target: %d" % GUIDED_TARGET)
	game_ui.show_choice_message(
		"CODA: \"We're ready to search for File #%d!\"\n\nWhere should Linear Search BEGIN?" % GUIDED_TARGET,
		[
			"At INDEX 0 — the very first element  ✅",
			"At INDEX 2 — the middle element",
			"At whichever element looks biggest"
		]
	)


func _p2_begin_search():
	state = State.GUIDED_SEARCHING
	hide_panel()
	if array_system:
		array_system.start_search()
	_update_guided_bar()
	game_ui.set_step("→  Click the GLOWING element (Index %d) or press [⏭ STEP]" % guided_index)
	game_ui.set_hint("Point at and click the highlighted element in 3D, or use the STEP button")
	_reset_hints()
	if game_ui:
		game_ui.highlight_code_line(1)
		game_ui.set_watch_variables({
			"Active Index (i)": guided_index,
			"Array Element arr[i]": GUIDED_ARRAY[guided_index] if guided_index < GUIDED_ARRAY.size() else "--",
			"Target Value": GUIDED_TARGET,
			"Comparisons": guided_comparisons,
			"Status": "Searching Index %d" % guided_index
		})
		game_ui.set_complexity_stats(guided_comparisons, GUIDED_ARRAY.size(), "Sequential scan")
		game_ui.update_array_ribbon(GUIDED_ARRAY, guided_index, GUIDED_TARGET, range(guided_index))


func _update_guided_bar():
	if guided_index < GUIDED_ARRAY.size():
		game_ui.set_formula(
			"Searching Index %d  |  Value = %d  |  Target = %d  |  Comparisons: %d" % [
				guided_index, GUIDED_ARRAY[guided_index], GUIDED_TARGET, guided_comparisons
			]
		)


func _p2_element_clicked(index: int, value: int):
	# Enforce sequential order
	if index != guided_index:
		game_ui.show_choice_feedback(
			("CODA: \"Hold on! We are at INDEX %d right now.\"\n\n"
			+ "You clicked Index %d — but that hasn't been reached yet!\n\n"
			+ "Linear Search NEVER skips elements. Click the GLOWING box.") % [
				guided_index, index
			]
		)
		return

	_guided_pending_index = index
	_guided_pending_value = value
	_guided_quiz_answered = false
	state                 = State.GUIDED_COMPARE_SHOW

	# ── Step 1: Show CURRENT VALUE
	game_ui.set_step("CURRENT VALUE: %d" % value)

	var is_match := (value == GUIDED_TARGET)
	game_ui.set_formula(
		"Comparing:  %d  %s  %d  →  %s" % [
			value,
			"=" if is_match else "≠",
			GUIDED_TARGET,
			"✅  MATCH!" if is_match else "❌  Not a match"
		]
	)

	if game_ui:
		game_ui.highlight_code_line(2 if not is_match else 3)
		game_ui.set_watch_variables({
			"Active Index (i)": index,
			"Array Element arr[i]": value,
			"Target Value": GUIDED_TARGET,
			"Comparisons": guided_comparisons + 1,
			"Status": "MATCH! Found" if is_match else "Mismatch (%d ≠ %d)" % [value, GUIDED_TARGET]
		})
		game_ui.set_complexity_stats(guided_comparisons + 1, GUIDED_ARRAY.size(), "Scanning")
		game_ui.update_array_ribbon(GUIDED_ARRAY, index, GUIDED_TARGET, range(index), index if is_match else -1)

	# ── Step 2: Ask student to predict — forces active thinking
	game_ui.show_choice_message(
		("CODA checks Index %d  →  value is  %d\n\n"
		+ "CURRENT VALUE:  %d\n"
		+ "TARGET:  %d\n\n"
		+ "Is  %d  equal to  %d?") % [index, value, value, GUIDED_TARGET, value, GUIDED_TARGET],
		["YES — %d matches File #%d!" % [value, GUIDED_TARGET],
		 "NO  — %d is not %d" % [value, GUIDED_TARGET]]
	)


func _p2_handle_compare_quiz(action: String):
	var value     := _guided_pending_value
	var index     := _guided_pending_index
	var is_match  := (value == GUIDED_TARGET)

	if _guided_quiz_answered:
		# Result already shown — student pressed SPACE/click to advance
		if action == "START":
			_p2_after_comparison()
		return

	# Student answering the quiz
	var answered_yes  := (action == "FIRST")
	var answered_no   := (action == "MIDDLE")
	var correct_yes   := is_match and answered_yes
	var correct_no    := not is_match and answered_no

	if correct_yes or correct_no:
		_guided_quiz_answered  = true
		guided_comparisons    += 1
		if array_system:
			array_system.execute_comparison(index, value)

		if is_match:
			state = State.GUIDED_RESULT_SHOWN
			game_ui.show_lesson_message(
				("✅  Correct!  %d  =  %d  →  MATCH FOUND!\n\n"
				+ "CODA: \"That's it! %d equals my target %d.\"\n\n"
				+ "\"The file is at INDEX %d!\"\n"
				+ "\"It took me %d comparison%s.\"\n\n"
				+ "We did NOT jump directly to %d.\n"
				+ "We checked the elements IN ORDER:\n\n"
				+ "  10 → 25 → 40\n"
				+ "  CHECK → CHECK → FOUND\n\n"
				+ "This is the CORE of Linear Search.") % [
					value, GUIDED_TARGET,
					value, GUIDED_TARGET,
					index,
					guided_comparisons,
					"s" if guided_comparisons != 1 else "",
					GUIDED_TARGET
				]
			)
		else:
			state = State.GUIDED_RESULT_SHOWN
			var next := index + 1
			game_ui.show_lesson_message(
				("✅  Correct!  %d  ≠  %d  →  Not a match.\n\n"
				+ "CODA: \"%d is not File #%d — moving to Index %d.\"\n\n"
				+ "Linear Search: when the current element doesn't match,\n"
				+ "move to the NEXT index (index + 1) and compare again.\n\n"
				+ "Comparisons so far: %d") % [
					value, GUIDED_TARGET,
					value, GUIDED_TARGET, next,
					guided_comparisons
				]
			)
	else:
		# Wrong quiz answer — teach through the mistake
		if answered_yes and not is_match:
			game_ui.show_choice_feedback(
				("CODA: \"Look carefully! %d ≠ %d — they are different numbers.\"\n\n"
				+ "A match only happens when the two values are EXACTLY equal.\n"
				+ "%d is not the same as %d.") % [value, GUIDED_TARGET, value, GUIDED_TARGET]
			)
		elif answered_no and is_match:
			game_ui.show_choice_feedback(
				("CODA: \"Look again! %d = %d — they ARE the same!\"\n\n"
				+ "This IS the target we've been searching for!") % [value, GUIDED_TARGET]
			)


func _p2_after_comparison():
	hide_panel()
	var found := (_guided_pending_value == GUIDED_TARGET)
	_guided_quiz_answered = false

	if found:
		# Show the important conceptual moment (Spec §37)
		state = State.REFLECT_QUIZ
		game_ui.show_success_message(GUIDED_TARGET, _guided_pending_index, guided_comparisons)
	else:
		guided_index += 1
		if guided_index >= GUIDED_ARRAY.size():
			state = State.REFLECT_QUIZ
			game_ui.show_failure_message(GUIDED_TARGET, guided_comparisons)
		else:
			state = State.GUIDED_SEARCHING
			game_ui.set_step("→  Now click Index %d (value = %d)" % [guided_index, GUIDED_ARRAY[guided_index]])
			_update_guided_bar()
			_reset_hints()


# ═══════════════════════════════════════════════════════════
# PHASE 3 — REFLECTION
# ═══════════════════════════════════════════════════════════

func _p3_show_reflection():
	state = State.REFLECT_QUIZ
	game_ui.set_step("Reflection Question")
	game_ui.set_formula("Think about what you just experienced...")
	game_ui.show_choice_message(
		"CODA: \"Great work! Now a quick question...\"\n\n"
		+ "WHY did Linear Search start at INDEX 0?",
		[
			"Because it must check from the beginning to guarantee nothing is missed",
			"Because index 0 is always the fastest to reach",
			"Because Linear Search always skips the first element"
		]
	)


# ═══════════════════════════════════════════════════════════
# PHASE 4 — INDEPENDENT PRACTICE
# ═══════════════════════════════════════════════════════════

func _p4_intro():
	state = State.PRACTICE_INTRO
	if array_system:
		array_system.clear_all_visualizers()
		array_system.target_value = PRACTICE_TARGET
		array_system.create_array(PRACTICE_ARRAY)
	game_ui.set_lesson("Practice — Your Turn! 💪")
	game_ui.set_objective("Find File #%d on your own" % PRACTICE_TARGET)
	game_ui.set_target(PRACTICE_TARGET)
	game_ui.set_step("Independent Practice")
	game_ui.set_formula("New array: %s   |   Target: %d" % [str(PRACTICE_ARRAY), PRACTICE_TARGET])
	game_ui.show_lesson_message(
		("CODA: \"Your turn — I'll step back and let you drive!\"\n\n"
		+ "New archive:  [ 15, 50, 20, 35, 70 ]\n"
		+ "Target:       File  #%d\n\n"
		+ "Remember the rules:\n"
		+ "  ▶  Start at INDEX 0\n"
		+ "  ▶  Click the HIGHLIGHTED element\n"
		+ "  ▶  If it doesn't match, the next element activates\n"
		+ "  ▶  Continue until you find File #%d!\n\n"
		+ "I'll only hint if you need help.") % [PRACTICE_TARGET, PRACTICE_TARGET]
	)


func _p4_begin():
	practice_index        = 0
	practice_comparisons  = 0
	state                 = State.PRACTICE_SEARCHING
	hide_panel()
	if array_system:
		array_system.start_search()
	game_ui.set_step("→  Click the highlighted element — Index 0")
	game_ui.set_hint("Click each highlighted element in order — LEFT to RIGHT")
	_update_practice_bar()
	_reset_hints()


func _update_practice_bar():
	game_ui.set_formula(
		"Searching Index %d  |  Target: %d  |  Comparisons: %d" % [
			practice_index, PRACTICE_TARGET, practice_comparisons
		]
	)


func _p4_element_clicked(index: int, value: int):
	# Enforce sequential order — this is the core teaching mechanic
	if index != practice_index:
		game_ui.show_choice_feedback(
			("Hint: Linear Search is at INDEX %d.\n\n"
			+ "Click the GLOWING element — not Index %d.") % [practice_index, index]
		)
		return

	practice_comparisons += 1
	var is_match := (value == PRACTICE_TARGET)
	if array_system:
		array_system.execute_comparison(index, value)

	game_ui.set_formula(
		"Index %d: %d %s %d  |  Comparisons: %d" % [
			index, value,
			"=" if is_match else "≠",
			PRACTICE_TARGET,
			practice_comparisons
		]
	)

	if is_match:
		state = State.PRACTICE_DONE
		game_ui.set_step("🎉  TARGET FOUND at Index %d!" % index)
		game_ui.show_lesson_message(
			("🎯  TARGET FOUND!\n\n"
			+ "CODA: \"Spectacular job! You located File #%d at Index %d!\"\n\n"
			+ "• Total Comparisons: %d\n"
			+ "• Strategy: Checked sequentially from Index 0\n\n"
			+ "You've proven you understand finding existing data.\n\n"
			+ "Next: What happens when an item is MISSING from the archive? Let's find out!") % [
				PRACTICE_TARGET, index, practice_comparisons
			]
		)
	else:
		practice_index += 1
		if practice_index < PRACTICE_ARRAY.size():
			game_ui.set_step("Not a match — click Index %d (value = %d)" % [
				practice_index, PRACTICE_ARRAY[practice_index]
			])
			_reset_hints()
		else:
			state = State.PRACTICE_DONE
			game_ui.set_step("Array exhausted — File #%d not found" % PRACTICE_TARGET)
			game_ui.show_lesson_message(
				("CODA: \"Search exhausted without a match!\"\n\n"
				+ "File #%d was not found in %d comparisons.") % [
					PRACTICE_TARGET, practice_comparisons
				]
			)


func search_failed():
	if state == State.PRACTICE_SEARCHING:
		state = State.PRACTICE_DONE
		game_ui.set_step("Search exhausted — file not found")
	elif state == State.NOT_FOUND_SEARCHING:
		state = State.NOT_FOUND_DONE
		game_ui.set_step("Search exhausted — target not in array")
	elif state == State.CHALLENGE_SEARCHING:
		state = State.CHALLENGE_RESULT
		game_ui.set_step("Challenge search complete")


# ═══════════════════════════════════════════════════════════
# PHASE 4B — NOT-FOUND SCENARIO (Spec §46-47)
# ═══════════════════════════════════════════════════════════

func _p4b_intro():
	state = State.NOT_FOUND_INTRO
	if array_system:
		array_system.clear_all_visualizers()
		array_system.target_value = NOT_FOUND_TARGET
		array_system.create_array(NOT_FOUND_ARRAY)
	game_ui.set_lesson("What If Target Is Missing?")
	game_ui.set_objective("Search for File #%d (it's NOT there!)" % NOT_FOUND_TARGET)
	game_ui.set_target(NOT_FOUND_TARGET)
	game_ui.set_step("Not-Found Scenario")
	game_ui.set_formula("Array: %s   |   Target: %d (does NOT exist!)" % [str(NOT_FOUND_ARRAY), NOT_FOUND_TARGET])
	game_ui.show_lesson_message(
		("CODA: \"What happens when the target is NOT in the array?\"\n\n"
		+ "Let's find out! Try searching for File #%d.\n\n"
		+ "Array:   [ 10, 25, 40, 15, 30 ]\n"
		+ "Target:  %d\n\n"
		+ "Hint: %d is NOT in this array!\n"
		+ "What will Linear Search do?\n\n"
		+ "Perform the search to find out.") % [
			NOT_FOUND_TARGET, NOT_FOUND_TARGET, NOT_FOUND_TARGET
		]
	)


func _p4b_begin():
	not_found_index       = 0
	not_found_comparisons = 0
	state                 = State.NOT_FOUND_SEARCHING
	hide_panel()
	if array_system:
		array_system.start_search()
	game_ui.set_step("→  Click Index 0 — search for %d" % NOT_FOUND_TARGET)
	game_ui.set_hint("This target doesn't exist in the array. See what happens!")
	_reset_hints()


func _p4b_element_clicked(index: int, value: int):
	if index != not_found_index:
		game_ui.show_choice_feedback(
			"Linear Search is at INDEX %d.\nClick the GLOWING element." % not_found_index
		)
		return

	not_found_comparisons += 1
	if array_system:
		array_system.execute_comparison(index, value)

	game_ui.set_formula(
		"Index %d: %d ≠ %d  |  Comparisons: %d / %d" % [
			index, value, NOT_FOUND_TARGET,
			not_found_comparisons, NOT_FOUND_ARRAY.size()
		]
	)

	var is_match := (value == NOT_FOUND_TARGET)
	if is_match:
		state = State.NOT_FOUND_DONE
		game_ui.set_step("Unexpected: Target found!")
	else:
		not_found_index += 1
		if not_found_index < NOT_FOUND_ARRAY.size():
			game_ui.set_step("Not a match — check Index %d" % not_found_index)
			_reset_hints()
		else:
			state = State.NOT_FOUND_DONE
			game_ui.set_step("✗ Array ended — Target %d NOT FOUND" % NOT_FOUND_TARGET)
			game_ui.set_hint("Array ended with no match. SPACE to see explanation.")


func _p4b_explain():
	state = State.NOT_FOUND_EXPLAIN
	game_ui.set_step("Understanding: Target Not Found")
	game_ui.set_formula("Checked ALL %d elements — no match — target NOT in array" % NOT_FOUND_ARRAY.size())
	game_ui.show_lesson_message(
		("SEARCH COMPLETE — TARGET NOT FOUND\n\n"
		+ "CODA: \"We checked EVERY element.\"\n\n"
		+ "  10 ≠ %d  ✗\n"
		+ "  25 ≠ %d  ✗\n"
		+ "  40 ≠ %d  ✗\n"
		+ "  15 ≠ %d  ✗\n"
		+ "  30 ≠ %d  ✗\n\n"
		+ "\"No element matched the target.\"\n"
		+ "\"Therefore, the target is NOT in the array.\"\n\n"
		+ "Total comparisons: %d\n\n"
		+ "This is the WORST CASE for Linear Search —\n"
		+ "checking every single element without finding the target.") % [
			NOT_FOUND_TARGET, NOT_FOUND_TARGET, NOT_FOUND_TARGET,
			NOT_FOUND_TARGET, NOT_FOUND_TARGET,
			not_found_comparisons
		]
	)


# ═══════════════════════════════════════════════════════════
# PHASE 5 — KNOWLEDGE CHECK
# ═══════════════════════════════════════════════════════════

func _p5_start():
	_kc_index = 0
	_kc_started = true
	state     = State.KC_ACTIVE
	game_ui.set_lesson("Knowledge Check 📝")
	game_ui.set_objective("Test your understanding of Linear Search")
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
	if chosen < 0:
		return

	if chosen == q["correct"]:
		_kc_index     += 1
		state          = State.KC_CORRECT_EXPLAIN
		hide_panel()
		var done_all   := (_kc_index >= KC_QUESTIONS.size())
		game_ui.show_lesson_message(
			"✅  Correct!\n\n" + q["explain"] + (
				"\n\n🎉  All questions answered! Moving to the next section..." if done_all else ""
			)
		)
	else:
		game_ui.show_choice_feedback(
			"Not quite.\n\n" + q["explain"] + "\n\nTry again!"
		)


# ═══════════════════════════════════════════════════════════
# PHASE 6 — PSEUDOCODE
# ═══════════════════════════════════════════════════════════

func _p6_pseudocode():
	state = State.PSEUDOCODE
	game_ui.set_lesson("Pseudocode — The Algorithm in Plain English")
	game_ui.set_step("Phase 6 — Pseudocode")
	game_ui.set_formula("FOR each element → IF match → FOUND    ELSE → next element")
	game_ui.show_lesson_message(
		"CODA: \"Let's write out exactly what you just DID!\"\n\n"
		+ "════════════════════════════════\n"
		+ "LINEAR SEARCH — PSEUDOCODE\n"
		+ "════════════════════════════════\n\n"
		+ "SET   index = 0\n\n"
		+ "FOR each element in the array:\n\n"
		+ "    IF  array[index]  ==  target:\n"
		+ "        RETURN  index    ← FOUND!\n\n"
		+ "    ELSE:\n"
		+ "        index = index + 1\n\n"
		+ "IF loop ends with no match:\n"
		+ "    RETURN  -1           ← NOT FOUND\n\n"
		+ "════════════════════════════════\n\n"
		+ "Every click you made maps to one step of this pseudocode!"
	)


# ═══════════════════════════════════════════════════════════
# PHASE 7 — CODE CONNECTION
# ═══════════════════════════════════════════════════════════

func _p7_code_1():
	state = State.CODE_SHOW_1
	game_ui.set_step("Phase 7 — Real Code in C (Step 1)")
	game_ui.set_formula("The loop runs from 0 to N-1")
	game_ui.show_c_code_step(
		"Linear Search in C — The Loop",
		"int linear_search(int array[], int size, int target) {\n"
		+ ">   for (int i = 0; i < size; i++) {\n"
		+ "        // compare and return\n"
		+ "    }\n"
		+ "    return -1;\n"
		+ "}",
		"CODA: \"The 'for' loop starts at index i = 0, exactly like we checked box 0 first!\"\n\n"
		+ "• array[]  →  the collection of values\n"
		+ "• size  →  how many elements\n"
		+ "• target  →  the value we want to find\n"
		+ "• i = 0  →  start from the BEGINNING",
		"Next: The Comparison →"
	)

func _p7_code():
	_p7_code_1()

func _p7_code_2():
	state = State.CODE_SHOW_2
	game_ui.set_step("Phase 7 — Real Code in C (Step 2)")
	game_ui.set_formula("array[i] == target   ←   comparison made every step!")
	game_ui.show_c_code_step(
		"Linear Search in C — The Comparison",
		"int linear_search(int array[], int size, int target) {\n"
		+ "    for (int i = 0; i < size; i++) {\n"
		+ ">       if (array[i] == target) {\n"
		+ ">           return i;\n"
		+ "        }\n"
		+ "    }\n"
		+ "    return -1;\n"
		+ "}",
		"CODA: \"Inside the loop: if array[i] matches target, return index i immediately!\"\n\n"
		+ "• i = current box index\n"
		+ "• array[i] = value inside the box\n"
		+ "• == means \"is equal to?\"\n"
		+ "• return i = \"Found! It's at position i!\"\n\n"
		+ "This is exactly what you did when you clicked each box!",
		"Next: What If Not Found? →"
	)

func _p7_code_3():
	state = State.CODE_SHOW_3
	game_ui.set_step("Phase 7 — Real Code in C (Step 3)")
	game_ui.set_formula("return -1   ←   means target was not found")
	game_ui.show_c_code_step(
		"Linear Search in C — Returning -1",
		"int linear_search(int array[], int size, int target) {\n"
		+ "    for (int i = 0; i < size; i++) {\n"
		+ "        if (array[i] == target) {\n"
		+ "            return i;\n"
		+ "        }\n"
		+ "    }\n"
		+ ">   return -1;\n"
		+ "}",
		("CODA: \"If we check every box and never find the target, the loop ends.\"\n\n"
		+ "• return -1 = \"NOT FOUND\"\n"
		+ "• -1 is used because it's not a valid index\n"
		+ "• This is a universal programming convention\n\n"
		+ "Remember when you searched for %d and checked every element?\n"
		+ "That's exactly when this 'return -1' would execute!") % NOT_FOUND_TARGET,
		"Understood! →"
	)


# ═══════════════════════════════════════════════════════════
# PHASE 8 — COMPLEXITY INTRODUCTION
# ═══════════════════════════════════════════════════════════

func _p8_complexity():
	state = State.COMPLEXITY
	game_ui.set_step("Phase 8 — How Efficient is Linear Search?")
	game_ui.set_formula("Worst Case: O(n)   →   N elements = up to N comparisons")
	game_ui.show_lesson_message(
		"CODA: \"How many comparisons does Linear Search need?\"\n\n"
		+ "It depends on WHERE the target is:\n\n"
		+ "  Array: [ 10, 20, 30, 40, 50 ]   Target: 10\n"
		+ "  → Found in  1  comparison!   (BEST case)\n\n"
		+ "  Array: [ 10, 20, 30, 40, 50 ]   Target: 30\n"
		+ "  → Found in  3  comparisons.\n\n"
		+ "  Array: [ 10, 20, 30, 40, 50 ]   Target: 50\n"
		+ "  → Found in  5  comparisons!  (WORST case)\n\n"
		+ "  Array: [ 10, 20, 30, 40, 50 ]   Target: 99\n"
		+ "  → All 5 checked — NOT FOUND.  (Also worst case)\n\n"
		+ "The farther the target from the beginning,\n"
		+ "the more elements Linear Search must check.\n\n"
		+ "In the worst case: check EVERY element.\n\n"
		+ "If the array has  N  elements,\n"
		+ "Linear Search makes at most  N  comparisons.\n\n"
		+ "Programmers write this as:   O(n)\n\n"
		+ "(\"Big-Oh of n\" — n = number of elements)"
	)


# ═══════════════════════════════════════════════════════════
# PHASE 8B — MINI CHALLENGE (Spec §76-77)
# ═══════════════════════════════════════════════════════════

func _p8b_challenge_intro():
	state = State.CHALLENGE_INTRO
	game_ui.set_lesson("Mini Challenge 🏆")
	game_ui.set_objective("Predict how many comparisons are needed")
	game_ui.set_step("Challenge Time!")
	game_ui.set_formula("New array: %s   |   Target: %d" % [str(CHALLENGE_ARRAY), CHALLENGE_TARGET])
	game_ui.show_lesson_message(
		("CODA: \"Time for a challenge!\"\n\n"
		+ "New array:  [ 55, 12, 80, 25, 90, 30 ]\n"
		+ "Target:     %d\n\n"
		+ "BEFORE searching, I want you to THINK:\n\n"
		+ "\"How many comparisons will Linear Search need\n"
		+ " to find %d in this array?\"\n\n"
		+ "Count the position yourself, then make your prediction!") % [
			CHALLENGE_TARGET, CHALLENGE_TARGET
		]
	)


func _p8b_predict():
	state = State.CHALLENGE_PREDICT
	game_ui.set_step("Make Your Prediction")
	game_ui.show_choice_message(
		("How many comparisons will Linear Search need to find %d\n"
		+ "in  [ 55, 12, 80, 25, 90, 30 ]?") % CHALLENGE_TARGET,
		[
			"3 comparisons",
			"5 comparisons",
			"6 comparisons"
		]
	)


func _p8b_begin_search():
	challenge_index       = 0
	challenge_comparisons = 0
	state                 = State.CHALLENGE_SEARCHING
	if array_system:
		array_system.target_value = CHALLENGE_TARGET
		array_system.create_array(CHALLENGE_ARRAY)
		array_system.start_search()
	game_ui.set_target(CHALLENGE_TARGET)
	game_ui.set_step("→  Perform the search — verify your prediction!")
	game_ui.set_hint("Search for %d to see if your prediction was correct" % CHALLENGE_TARGET)
	_reset_hints()


func _p8b_element_clicked(index: int, value: int):
	if index != challenge_index:
		game_ui.show_choice_feedback(
			"Linear Search is at INDEX %d. Click the GLOWING element." % challenge_index
		)
		return

	challenge_comparisons += 1
	if array_system:
		array_system.execute_comparison(index, value)

	game_ui.set_formula(
		"Index %d: %d %s %d  |  Comparisons: %d" % [
			index, value,
			"=" if value == CHALLENGE_TARGET else "≠",
			CHALLENGE_TARGET,
			challenge_comparisons
		]
	)

	if value == CHALLENGE_TARGET:
		state = State.CHALLENGE_RESULT
		game_ui.set_step("🎯  TARGET FOUND!")
	else:
		challenge_index += 1
		if challenge_index < CHALLENGE_ARRAY.size():
			game_ui.set_step("Check Index %d" % challenge_index)
			_reset_hints()
		else:
			state = State.CHALLENGE_RESULT
			game_ui.set_step("Search complete")


func _p8b_show_result():
	game_ui.set_step("Challenge Result")
	var prediction_str := str(challenge_prediction)
	var actual_str := str(challenge_comparisons)
	var correct := (challenge_prediction == challenge_comparisons)

	game_ui.set_formula(
		"Prediction: %s  |  Actual: %s  |  %s" % [
			prediction_str, actual_str,
			"✅ CORRECT!" if correct else "Close! Keep practicing."
		]
	)
	game_ui.show_lesson_message(
		("CHALLENGE RESULT\n\n"
		+ "YOUR PREDICTION:  %s comparisons\n"
		+ "ACTUAL RESULT:    %s comparisons\n\n"
		+ "%s\n\n"
		+ "CODA: \"The target %d was at INDEX %d.\"\n"
		+ "\"So Linear Search needed %s comparisons.\"\n\n"
		+ "\"Every comparison = checking one element.\n"
		+ "The position of the target determines how many checks!\"\n\n"
		+ "%s") % [
			prediction_str, actual_str,
			"🎉  Perfect prediction!" if correct else "Not quite — but you're learning!",
			CHALLENGE_TARGET,
			CHALLENGE_ARRAY.find(CHALLENGE_TARGET),
			actual_str,
			"🏆  CHALLENGE COMPLETE" if correct else "Try to predict next time!"
		]
	)


# ═══════════════════════════════════════════════════════════
# PHASE 9 — LEVEL COMPLETE
# ═══════════════════════════════════════════════════════════

func _p9_complete():
	state = State.FINISHED
	game_ui.set_step("🎓  Level 01 Complete!")
	game_ui.set_formula("Linear Search: O(n)  |  Always starts at index 0  |  Checks each element in order")

	# Play level complete sound
	if is_inside_tree():
		var audio = get_node_or_null("/root/AudioManager")
		if audio != null and audio.has_method("play_level_complete_sound"):
			audio.play_level_complete_sound()

	game_ui.show_lesson_message(
		"🎉  LEVEL  01  COMPLETE!\n\n"
		+ "CODA: \"Outstanding! Here's everything you learned today:\"\n\n"
		+ "  ✅  An ARRAY stores values in an ordered sequence\n"
		+ "  ✅  Each value is an ELEMENT\n"
		+ "  ✅  Every element has an INDEX starting from 0\n"
		+ "  ✅  The TARGET is the value we're searching for\n"
		+ "  ✅  Linear Search checks elements ONE BY ONE, left to right\n"
		+ "  ✅  It COMPARES each value with the target\n"
		+ "  ✅  When found, it RETURNS the INDEX\n"
		+ "  ✅  If no match exists, the search ends → NOT FOUND\n"
		+ "  ✅  Worst case: checks ALL N elements → O(n)\n\n"
		+ "You didn't just READ about Linear Search...\n"
		+ "You EXPERIENCED the algorithm step by step!\n\n"
		+ "🏅  BADGE UNLOCKED: \"LINEAR SEARCH EXPLORER\"\n\n"
		+ "CODA: \"Ready for Level 02?  →  Binary Search!\"\n"
		+ "\"(Hint: it's MUCH faster, but requires a sorted array!)\""
	)


# ═══════════════════════════════════════════════════════════
# MAIN DISPATCH — handle_action
# ═══════════════════════════════════════════════════════════

func handle_action(action: String):
	match state:

		# ── Phase 1: Introduction ────────────────────────────
		State.INTRO_WELCOME:
			if action == "START":
				_p1_array()

		State.INTRO_ARRAY:
			if action == "START":
				_p1_element()

		State.INTRO_ELEMENT:
			if action == "START":
				_p1_index()

		State.INTRO_INDEX:
			if action == "START":
				_p1_index_zero()

		State.INTRO_INDEX_ZERO:
			if action == "START":
				_p1_target()

		State.INTRO_TARGET:
			if action == "START":
				_p1_search_concept()

		State.INTRO_SEARCH_CONCEPT:
			if action == "START":
				_p1_algorithm()

		State.INTRO_ALGORITHM:
			if action == "START":
				_p2_start()

		# ── Phase 2: Guided Search ───────────────────────────
		State.GUIDED_PRE_QUIZ:
			if action == "FIRST":    # Correct — index 0
				_p2_begin_search()
			elif action in ["MIDDLE", "LAST"]:
				game_ui.show_choice_feedback(
					"CODA: \"Not quite! Linear Search always begins at INDEX 0.\"\n\n"
					+ "If we started at the middle or end, we would skip elements "
					+ "and might miss the target entirely. Always start from the BEGINNING!"
				)

		State.GUIDED_COMPARE_SHOW:
			_p2_handle_compare_quiz(action)

		State.GUIDED_RESULT_SHOWN:
			if action == "START":
				_p2_after_comparison()

		# ── Phase 3: Reflection ──────────────────────────────
		State.REFLECT_QUIZ:
			if action == "START":
				_p3_show_reflection()
			elif action == "FIRST":   # Correct answer
				state = State.REFLECT_CORRECT
				hide_panel()
				game_ui.show_lesson_message(
					"✅  Exactly right!\n\n"
					+ "CODA: \"Linear Search MUST start at index 0 to guarantee "
					+ "it doesn't miss any element. Starting anywhere else would "
					+ "mean potentially skipping over the target!\"\n\n"
					+ "\"Now — your turn to try alone.\"\n"
					+ "\"New array, same algorithm. You've got this!\""
				)
			elif action in ["MIDDLE", "LAST"]:
				game_ui.show_choice_feedback(
					"CODA: \"Not quite! Linear Search starts at index 0 because "
					+ "it must guarantee no element is skipped. Starting later "
					+ "would risk missing the target if it was near the beginning.\""
				)

		State.REFLECT_CORRECT:
			if action == "START":
				_p4_intro()

		# ── Phase 4: Practice ────────────────────────────────
		State.PRACTICE_INTRO:
			if action == "START":
				_p4_begin()

		State.PRACTICE_DONE:
			if action == "START":
				_p4b_intro()

		# ── Phase 4B: Not-Found ──────────────────────────────
		State.NOT_FOUND_INTRO:
			if action == "START":
				_p4b_begin()

		State.NOT_FOUND_DONE:
			if action == "START":
				_p4b_explain()

		State.NOT_FOUND_EXPLAIN:
			if action == "START":
				# Transition to knowledge check intro
				hide_panel()
				game_ui.show_lesson_message(
					"CODA: \"Now you've seen BOTH outcomes:\"\n\n"
					+ "  ✅  Target FOUND — search stops early\n"
					+ "  ✗  Target NOT FOUND — check every element\n\n"
					+ "Let's test your understanding with a short quiz!"
				)
				state = State.KC_ACTIVE

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

		# ── Phase 6-9: Theory + Finish ───────────────────────
		State.PSEUDOCODE:
			if action in ["START", "FIRST"]:
				_p7_code_1()

		State.CODE_SHOW_1:
			if action in ["FIRST", "START"]:
				_p7_code_2()

		State.CODE_SHOW_2:
			if action in ["FIRST", "START"]:
				_p7_code_3()

		State.CODE_SHOW_3:
			if action in ["FIRST", "START"]:
				_p8_complexity()

		State.COMPLEXITY:
			if action in ["START", "FIRST"]:
				_p8b_challenge_intro()

		# ── Phase 8B: Mini Challenge ─────────────────────────
		State.CHALLENGE_INTRO:
			if action == "START":
				_p8b_predict()

		State.CHALLENGE_PREDICT:
			if action == "FIRST":
				challenge_prediction = 3
				_p8b_begin_search()
			elif action == "MIDDLE":
				challenge_prediction = 5
				_p8b_begin_search()
			elif action == "LAST":
				challenge_prediction = 6
				_p8b_begin_search()

		State.CHALLENGE_RESULT:
			if action == "START":
				_p8b_show_result()
				state = State.LEVEL_COMPLETE

		State.LEVEL_COMPLETE:
			if action in ["START", "FIRST"]:
				_p9_complete()

		# ── Finish ───────────────────────────────────────────
		State.FINISHED:
			if action in ["START", "FIRST"]:
				hide_panel()
				lesson_finished.emit()


# ═══════════════════════════════════════════════════════════
# ELEMENT SELECTED (from 3D world clicks)
# ═══════════════════════════════════════════════════════════

func element_selected(index: int, value: int):
	_reset_hints()
	match state:
		State.GUIDED_PRE_QUIZ:
			if index == 0:
				_p2_begin_search()
			else:
				game_ui.show_choice_feedback(
					"CODA: \"Answer the question first! "
					+ "Where should Linear Search begin?\""
				)

		State.GUIDED_SEARCHING:
			_p2_element_clicked(index, value)

		State.PRACTICE_SEARCHING:
			_p4_element_clicked(index, value)

		State.NOT_FOUND_SEARCHING:
			_p4b_element_clicked(index, value)

		State.CHALLENGE_SEARCHING:
			_p8b_element_clicked(index, value)
