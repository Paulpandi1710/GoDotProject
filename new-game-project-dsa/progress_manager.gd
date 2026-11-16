## ============================================================
## PROGRESS MANAGER — Module 1 save / unlocks / badges
## Desktop-first. Persists to user://module1_progress.cfg
## ============================================================

extends Node

const SAVE_PATH := "user://module1_progress.cfg"
const CHAPTER_COUNT := 3
const CHAPTER_NAMES := ["Linear Search", "Binary Search", "Bubble Sort"]
const BADGE_NAMES := ["Sequential Finder", "Half-Space Operator", "Order Restorer"]

## Highest chapter index the trainee may start (0 = Chapter 1 only).
var highest_unlocked: int = 0
var completed: Array[bool] = [false, false, false]
var badges_earned: Array[bool] = [false, false, false]
var module1_complete: bool = false
var seen_opening: bool = false

func _ready() -> void:
	add_to_group("progress_manager")
	load_progress()

func is_chapter_unlocked(index: int) -> bool:
	if index < 0 or index >= CHAPTER_COUNT:
		return false
	if module1_complete:
		return true
	return index <= highest_unlocked

func mark_chapter_complete(index: int) -> void:
	if index < 0 or index >= CHAPTER_COUNT:
		return
	completed[index] = true
	badges_earned[index] = true
	if index + 1 < CHAPTER_COUNT and highest_unlocked < index + 1:
		highest_unlocked = index + 1
	if completed[0] and completed[1] and completed[2]:
		module1_complete = true
		highest_unlocked = CHAPTER_COUNT - 1
	save_progress()

func get_unlock_hint(index: int) -> String:
	if is_chapter_unlocked(index):
		return ""
	if index <= 0:
		return ""
	return "Complete Chapter %d (%s) first." % [index, CHAPTER_NAMES[index - 1]]

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("module1", "highest_unlocked", highest_unlocked)
	cfg.set_value("module1", "module1_complete", module1_complete)
	cfg.set_value("module1", "seen_opening", seen_opening)
	for i in CHAPTER_COUNT:
		cfg.set_value("module1", "completed_%d" % i, completed[i])
		cfg.set_value("module1", "badge_%d" % i, badges_earned[i])
	cfg.save(SAVE_PATH)

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	highest_unlocked = int(cfg.get_value("module1", "highest_unlocked", 0))
	module1_complete = bool(cfg.get_value("module1", "module1_complete", false))
	seen_opening = bool(cfg.get_value("module1", "seen_opening", false))
	for i in CHAPTER_COUNT:
		completed[i] = bool(cfg.get_value("module1", "completed_%d" % i, false))
		badges_earned[i] = bool(cfg.get_value("module1", "badge_%d" % i, false))

func reset_progress() -> void:
	highest_unlocked = 0
	completed = [false, false, false]
	badges_earned = [false, false, false]
	module1_complete = false
	seen_opening = false
	save_progress()
