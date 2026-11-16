## ============================================================
## LESSON MANAGER — Module 1 only
## Hub + chapter playlist + unlocks + story vs single-chapter play
## ============================================================

extends Node
class_name LessonManager

var array_system
var game_ui

var current_lesson_index: int = 0

## Story Mode: Chapter 1 → 2 → 3 with transitions.
## Single-chapter hub picks return to hub after finish.
var story_mode: bool = false

## Each entry: [script_path, chapter_label, chapter_title, subtitle, accent_color]
const LESSON_PLAYLIST := [
	[
		"res://lessons/linear_search_lesson.gd",
		"Chapter 1",
		"Linear Search",
		"Find the lost file — check every shelf, one by one.",
		Color(0.0, 0.75, 1.0)
	],
	[
		"res://lessons/binary_search_lesson.gd",
		"Chapter 2",
		"Binary Search",
		"Sorted shelves let CODA cut the search in half!",
		Color(0.65, 0.25, 1.0)
	],
	[
		"res://lessons/bubble_sort_lesson.gd",
		"Chapter 3",
		"Bubble Sort",
		"The Scramble Fault disordered the Archive — restore order!",
		Color(1.0, 0.55, 0.0)
	],
]

var active_lesson: Lesson = null
var in_hub: bool = true
var is_transitioning: bool = false

func _ready():
	add_to_group("lesson_manager")

func setup(array_ref, ui_ref):
	array_system = array_ref
	game_ui = ui_ref
	if game_ui:
		if not game_ui.deck_step_requested.is_connected(_on_deck_step):
			game_ui.deck_step_requested.connect(_on_deck_step)
		if not game_ui.deck_play_toggled.is_connected(_on_deck_play):
			game_ui.deck_play_toggled.connect(_on_deck_play)
		if not game_ui.deck_reset_requested.is_connected(_on_deck_reset):
			game_ui.deck_reset_requested.connect(_on_deck_reset)
		if not game_ui.deck_speed_changed.is_connected(_on_deck_speed):
			game_ui.deck_speed_changed.connect(_on_deck_speed)
		if not game_ui.deck_target_selected.is_connected(_on_deck_target):
			game_ui.deck_target_selected.connect(_on_deck_target)
		if not game_ui.deck_randomize_requested.is_connected(_on_deck_randomize):
			game_ui.deck_randomize_requested.connect(_on_deck_randomize)
		if not game_ui.ribbon_element_clicked.is_connected(_on_ribbon_clicked):
			game_ui.ribbon_element_clicked.connect(_on_ribbon_clicked)

func _progress():
	return get_node_or_null("/root/ProgressManager")

func can_launch(index: int) -> bool:
	var pm = _progress()
	if pm == null:
		return index == 0
	return pm.is_chapter_unlocked(index)

func try_launch_lesson(index: int) -> bool:
	if not can_launch(index):
		var pm = _progress()
		var hint := "Complete the previous chapter first."
		if pm and pm.has_method("get_unlock_hint"):
			hint = pm.get_unlock_hint(index)
		if game_ui and game_ui.has_method("show_choice_message"):
			game_ui.show_choice_message(
				"CODA: \"Not yet, Trainee.\"\n\n%s\n\nWalk the Archive in order — Linear Search first." % hint,
				["Back to Hub"]
			)
		return false
	launch_lesson(index)
	return true

func _on_deck_step():
	if active_lesson and active_lesson.has_method("step_interactive"):
		active_lesson.step_interactive()
	elif active_lesson:
		handle_action("START")

func _on_deck_play(is_playing: bool):
	if active_lesson and active_lesson.has_method("set_auto_play"):
		active_lesson.set_auto_play(is_playing)

func _on_deck_reset():
	if active_lesson and active_lesson.has_method("reset_interactive"):
		active_lesson.reset_interactive()

func _on_deck_speed(speed: float):
	if active_lesson and active_lesson.has_method("set_playback_speed"):
		active_lesson.set_playback_speed(speed)

func _on_deck_target(target_val: int):
	if active_lesson and active_lesson.has_method("set_target_interactive"):
		active_lesson.set_target_interactive(target_val)

func _on_deck_randomize():
	if active_lesson and active_lesson.has_method("randomize_interactive"):
		active_lesson.randomize_interactive()

func _on_ribbon_clicked(index: int, value: int):
	element_selected(index, value)

func step_interactive():
	_on_deck_step()

func set_auto_play(is_playing: bool):
	_on_deck_play(is_playing)

func reset_interactive():
	_on_deck_reset()

func set_playback_speed(speed: float):
	_on_deck_speed(speed)

func set_target_interactive(target_val: int):
	_on_deck_target(target_val)

func randomize_interactive():
	_on_deck_randomize()

func start_lesson():
	start_hub()

func start_hub():
	in_hub = true
	is_transitioning = false
	story_mode = false

	if active_lesson != null:
		if active_lesson.lesson_finished.is_connected(_on_lesson_finished):
			active_lesson.lesson_finished.disconnect(_on_lesson_finished)
		active_lesson.queue_free()
		active_lesson = null

	if array_system:
		array_system.visible = false
		if array_system.has_method("disable_all_collisions"):
			array_system.disable_all_collisions()

	if game_ui:
		if game_ui.has_method("show_hub"):
			game_ui.show_hub()

	if is_inside_tree() and get_tree() != null:
		var world = get_tree().get_first_node_in_group("dsa_world")
		if world and world.has_method("set_hub_active"):
			world.set_hub_active(true)
		if world and world.has_method("refresh_hub_unlock_labels"):
			world.refresh_hub_unlock_labels()

	_maybe_show_opening()

func _maybe_show_opening():
	var pm = _progress()
	if pm == null or pm.seen_opening:
		return
	pm.seen_opening = true
	pm.save_progress()
	if game_ui and game_ui.has_method("show_choice_message"):
		game_ui.show_choice_message(
			"Welcome to DSA Academy, Trainee.\n\n"
			+ "I'm CODA — your Archive Robot.\n"
			+ "Last night, a Scramble Fault hit the Quantum Archive. Files are scattered, and some shelves are out of order.\n\n"
			+ "Together we'll learn how computers search and sort — one shelf at a time.\n"
			+ "Start with Chapter 1: Linear Search (press 1 or click the cyan pedestal).",
			["I'm ready"]
		)

func launch_lesson(index: int):
	if not can_launch(index):
		try_launch_lesson(index)
		return

	in_hub = false
	current_lesson_index = index
	## Chapter 1 starts Story Mode (auto-continue). Later chapters from hub are single play.
	story_mode = (index == 0)

	if game_ui:
		if game_ui.has_method("hide_hub"):
			game_ui.hide_hub()

	if array_system:
		array_system.visible = true

	if is_inside_tree() and get_tree() != null:
		var world = get_tree().get_first_node_in_group("dsa_world")
		if world and world.has_method("set_hub_active"):
			world.set_hub_active(false)

	load_lesson(index)

func return_to_hub():
	start_hub()

func load_lesson(index: int):
	in_hub = false
	if index >= LESSON_PLAYLIST.size():
		_show_all_complete()
		return

	if active_lesson != null:
		active_lesson.queue_free()
		active_lesson = null

	var entry = LESSON_PLAYLIST[index]
	var script = load(entry[0]) as Script
	if script == null:
		push_error("[LessonManager] Could not load: " + str(entry[0]))
		return

	var topic_keys := ["linear_search", "binary_search", "bubble_sort"]
	if index < topic_keys.size() and game_ui and game_ui.has_method("set_handbook_topic"):
		game_ui.set_handbook_topic(topic_keys[index])

	active_lesson = script.new() as Lesson
	active_lesson.name = "ActiveLesson"
	add_child(active_lesson)
	active_lesson.setup(self, array_system, game_ui)
	active_lesson.lesson_finished.connect(_on_lesson_finished)
	active_lesson.start_lesson()

func handle_action(action: String):
	if is_transitioning:
		return
	if in_hub:
		## Opening / lock / badge panels: close, then wait for pedestal or [1][2][3].
		if action == "FIRST" or action == "START" or action == "MIDDLE" or action == "LAST":
			if game_ui and game_ui.has_method("hide_panel"):
				game_ui.hide_panel()
		return
	if current_lesson_index >= LESSON_PLAYLIST.size():
		return_to_hub()
		return
	if active_lesson != null:
		active_lesson.handle_action(action)

func element_selected(index: int, value: int):
	if is_transitioning:
		return
	if active_lesson != null:
		active_lesson.element_selected(index, value)

func search_failed():
	if is_transitioning:
		return
	if active_lesson != null and active_lesson.has_method("search_failed"):
		active_lesson.search_failed()

func _on_lesson_finished():
	if is_transitioning:
		return
	is_transitioning = true

	if active_lesson != null and active_lesson.lesson_finished.is_connected(_on_lesson_finished):
		active_lesson.lesson_finished.disconnect(_on_lesson_finished)

	var finished_index := current_lesson_index
	var pm = _progress()
	if pm and pm.has_method("mark_chapter_complete"):
		pm.mark_chapter_complete(finished_index)

	## Single-chapter hub play → return to hub, then show badge
	if not story_mode:
		is_transitioning = false
		return_to_hub()
		if game_ui and game_ui.has_method("show_choice_message"):
			var badge := "Chapter Clear"
			if pm and finished_index < pm.BADGE_NAMES.size():
				badge = str(pm.BADGE_NAMES[finished_index])
			game_ui.show_choice_message(
				"CODA: \"Chapter complete! Badge unlocked: %s.\"\n\nPress SPACE when you're ready." % badge,
				["Back to Hub"]
			)
		return

	current_lesson_index = finished_index + 1
	if current_lesson_index >= LESSON_PLAYLIST.size():
		_show_all_complete()
		is_transitioning = false
		return

	var entry = LESSON_PLAYLIST[current_lesson_index]
	if game_ui and game_ui.has_method("show_chapter_transition"):
		game_ui.show_chapter_transition(
			str(entry[1]), str(entry[2]), str(entry[3]), entry[4]
		)
		await game_ui.chapter_transition_finished

	load_lesson(current_lesson_index)
	is_transitioning = false

func _show_all_complete():
	story_mode = false
	var pm = _progress()
	if pm:
		pm.module1_complete = true
		pm.save_progress()

	if game_ui:
		game_ui.set_lesson("DSA Academy — Module 1")
		game_ui.set_objective("Module 1 complete")
		game_ui.show_choice_message(
			"CODA: \"Module 1: Foundations — cleared.\"\n\n"
			+ "You restored the Quantum Archive.\n\n"
			+ "🔍  Linear Search — check every element (O(n))\n"
			+ "⚡  Binary Search — halve the search space (O(log n))\n"
			+ "🔄  Bubble Sort — swap neighbours to sort (O(n²))\n\n"
			+ "Golden rule: Search power depends on data order.\n"
			+ "Sorting is how we create that order.\n\n"
			+ "Clearance: Archive Operator — Rank 1.\n"
			+ "Future modules stay locked until we build them.",
			["Return to Hub"]
		)

func restart_current_lesson():
	if is_transitioning or in_hub:
		return

	if active_lesson != null:
		if active_lesson.lesson_finished.is_connected(_on_lesson_finished):
			active_lesson.lesson_finished.disconnect(_on_lesson_finished)
		active_lesson.queue_free()
		active_lesson = null

	if game_ui and game_ui.has_method("hide_panel"):
		game_ui.hide_panel()

	load_lesson(current_lesson_index)
