## Base class for all DSA Academy lessons.
## Extend this in linear_search_lesson.gd, binary_search_lesson.gd, etc.
## Provides: setup(), modal_is_open(), hide_panel()

extends Node
class_name Lesson

var lesson_manager
var array_system
var game_ui

signal lesson_finished

func setup(manager, array_sys, ui):
	lesson_manager = manager
	array_system   = array_sys
	game_ui        = ui

func start_lesson():
	pass

func handle_action(action: String):
	pass

func element_selected(index: int, value: int):
	pass

func search_failed():
	pass

## Convenience — hides the story panel
func hide_panel():
	if game_ui and game_ui.has_method("hide_panel"):
		game_ui.hide_panel()
	elif game_ui and game_ui.has_method("clear_lesson_message"):
		game_ui.clear_lesson_message()

## True if the story panel is visible
func panel_open() -> bool:
	if game_ui == null:
		return false
	if game_ui.has_method("panel_is_open"):
		return game_ui.panel_is_open()
	return false

## Apply a visual theme key ("linear_search", "binary_search", "bubble_sort")
func apply_theme(key: String):
	if game_ui and game_ui.has_method("apply_theme"):
		game_ui.apply_theme(key)

## Show the live formula in the action bar
func set_formula(text: String):
	if game_ui and game_ui.has_method("set_formula"):
		game_ui.set_formula(text)

func hide_formula():
	if game_ui and game_ui.has_method("hide_formula"):
		game_ui.hide_formula()

func set_step(text: String):
	if game_ui and game_ui.has_method("set_step"):
		game_ui.set_step(text)

func show_c_code_step(title_text: String, c_code: String, explanation: String, next_label: String = "Next →"):
	if game_ui and game_ui.has_method("show_c_code_step"):
		game_ui.show_c_code_step(title_text, c_code, explanation, next_label)
	elif game_ui and game_ui.has_method("show_choice_message"):
		game_ui.show_choice_message(title_text + "\n\n" + c_code + "\n\n" + explanation, [next_label])

## ── Interactive Algorithm Lab Controls ──
func step_interactive():
	pass

func set_auto_play(_is_playing: bool):
	pass

func reset_interactive():
	pass

func set_target_interactive(_val: int):
	pass

func randomize_interactive():
	pass

func set_playback_speed(_speed: float):
	pass
