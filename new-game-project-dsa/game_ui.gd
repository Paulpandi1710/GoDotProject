## ============================================================
## DSA ACADEMY — GAME UI MASTER CONTROLLER
##
## A fully themed, story-driven UI system.
## - CODA Robot speaks to the student via story_panel
## - Quiz panel has real animated buttons (1/2/3 keys + click)
## - HUD changes color/icon per algorithm
## - Action bar shows live steps and formulas
## - Progress strip shows chapter completion
## - Chapter transition overlay for dramatic lesson changes
## ============================================================

extends CanvasLayer

# ─── PUBLIC STATE ────────────────────────────────────────────
var is_choice_active: bool  = false
var target_value: int       = 0
var modal_overlay: ColorRect  # kept for legacy .visible access by lessons
var _current_theme: Dictionary

# ─── FONT REFS ───────────────────────────────────────────────
var _bold_font:    Font
var _regular_font: Font

# ─── HUD (Top-Left) ──────────────────────────────────────────
var _hud_panel:            PanelContainer
var _hud_chapter:          Label
var _hud_topic:            Label
var _hud_objective:        Label
var _hud_target_lbl:       Label
var _hud_icon:             Label
var _hud_target_container: Control
var _hud_shortcuts_row:    HBoxContainer
var _hud_status_badge:     Label

# ─── PROGRESS STRIP (Top-Right) ──────────────────────────────
var _prog_strip_container: Control
var _prog_pills:   Array[Label] = []
var _prog_chapters := ["🔍 Linear Search", "⚡ Binary Search", "🔄 Bubble Sort"]
var _current_chapter_index: int = 0

# ─── ACTION BAR (Bottom) ─────────────────────────────────────
var _bar_panel:     PanelContainer
var _bar_step:      Label
var _bar_formula:   Label
var _bar_hint:      Label

# ─── STORY PANEL (Center Modal — CODA speaks) ────────────────
var _story_overlay: ColorRect
var _story_panel:   PanelContainer
var _story_chapter_badge: Label
var _coda_body:     Control    # drawn robot face
var _story_title:   Label
var _story_body:    Label
var _story_stats:   Label
var _story_hint:    Label
var _story_choice_btns: Array[Button] = []
var _story_choice_container: BoxContainer
var _story_code_panel: PanelContainer
var _story_code_lbl: RichTextLabel

# ─── ANIMATIC QUIZ SYSTEM ────────────────────────────────────
var _quiz_active: bool = false
var _quiz_answered: bool = false
var _current_quiz_q: Dictionary = {}
var _current_quiz_idx: int = 0
var _current_quiz_total: int = 0
var _story_feedback_card: PanelContainer
var _story_feedback_badge: Label
var _story_feedback_body: Label
var _story_feedback_retry_btn: Button
var _story_feedback_next_btn: Button

# ─── CHAPTER TRANSITION ──────────────────────────────────────
var _trans_overlay:  ColorRect
var _trans_chapter:  Label
var _trans_title:    Label
var _trans_subtitle: Label

# ─── STORY PANEL INTERNAL REFS (for retheme) ─────────────────
var _story_header_row: HBoxContainer

# ─── INTERACTIVE DECK & HANDBOOK REFS ────────────────────────
var _deck_container: PanelContainer
var _deck_play_btn: Button
var _deck_step_btn: Button
var _deck_reset_btn: Button
var _deck_speed_btn: Button
var _deck_target_btn: Button
var _deck_random_btn: Button
var _deck_book_btn: Button
var _is_auto_playing: bool = false
var _playback_speed: float = 1.0

var _handbook_panel: PanelContainer
var _handbook_visible: bool = false
var _handbook_code_lbl: RichTextLabel
var _handbook_active_line: int = -1
var _handbook_current_topic: String = "linear_search"
var _handbook_tab_buttons: Array[Button] = []
var _handbook_tab_containers: Array[Control] = []
var _handbook_var_container: VBoxContainer
var _watch_vars: Dictionary = {}
var _handbook_complexity_lbl: Label
var _handbook_meter_bar: ProgressBar
var _handbook_meter_label: Label
var _handbook_concepts_container: VBoxContainer
var _handbook_subtitle_lbl: Label
var _handbook_details_col: VBoxContainer

# ─── ARRAY RIBBON (Interactive HUD Visualizer) ───────────────
var _array_ribbon_container: PanelContainer
var _array_ribbon_hbox: HBoxContainer
var _array_ribbon_cards: Array[Control] = []

# ─── SIGNALS ─────────────────────────────────────────────────
signal action_emitted(action: String)
signal hub_topic_selected(index: int)
signal return_to_hub_requested()
signal deck_step_requested()
signal deck_play_toggled(is_playing: bool)
signal deck_reset_requested()
signal deck_speed_changed(multiplier: float)
signal deck_target_selected(val: int)
signal deck_randomize_requested()
signal handbook_toggled(is_open: bool)
signal ribbon_element_clicked(index: int, value: int)

# ─── HANDBOOK DATA DICTIONARY ────────────────────────────────
const HANDBOOK_DATA := {
	"linear_search": {
		"title": "SECTOR 01: LINEAR SEARCH",
		"subtitle": "Sequential Memory Scan • Time Complexity: O(n)",
		"code": [
			"// C Implementation: Linear Search",
			"int linear_search(int arr[], int n, int target) {",
			"    for (int i = 0; i < n; i++) {",
			"        if (arr[i] == target) {",
			"            return i;  // Target found at index i!",
			"        }",
			"    }",
			"    return -1;         // Traversed array; target not found",
			"}"
		],
		"complexity_big_o": "O(n) — Linear Growth",
		"complexity_desc": "In worst case (target at end or missing), CODA checks every shelf. 100 items = 100 comparisons.",
		"best_case": "O(1) — Target is at index 0",
		"avg_case": "O(n / 2) → O(n) Comparisons",
		"worst_case": "O(n) — Checked all n elements",
		"space_comp": "O(1) — Constant memory",
		"concepts": [
			{"title": "1. Sequential Traversal", "body": "Checks elements in exact index order (0 → 1 → 2 ...). Never skips any element to guarantee accuracy."},
			{"title": "2. Zero-Based Indexing", "body": "Array addresses start at index 0 in memory (arr[0]). The last element is always at index (n - 1)."},
			{"title": "3. Works On Unsorted Data", "body": "Does not require data to be sorted! Useful when the cost of sorting exceeds the cost of a direct scan."},
			{"title": "4. Early Exit Optimization", "body": "As soon as arr[i] == target matches, the function immediately returns i, saving remaining comparisons."}
		]
	},
	"binary_search": {
		"title": "SECTOR 02: BINARY SEARCH",
		"subtitle": "Bifurcation Matrix • Time Complexity: O(log n)",
		"code": [
			"// C Implementation: Binary Search",
			"int binary_search(int arr[], int n, int target) {",
			"    int left = 0, right = n - 1;",
			"    while (left <= right) {",
			"        int mid = left + (right - left) / 2;",
			"        if (arr[mid] == target)",
			"            return mid; // Match found at mid!",
			"        else if (arr[mid] < target)",
			"            left = mid + 1;  // Discard left half",
			"        else",
			"            right = mid - 1; // Discard right half",
			"    }",
			"    return -1; // Target not in array",
			"}"
		],
		"complexity_big_o": "O(log n) — Logarithmic Power",
		"complexity_desc": "Each step cuts candidates in half. 1,000,000 items takes at most ~20 comparisons!",
		"best_case": "O(1) — Target is at initial mid candidate",
		"avg_case": "O(log n) Comparisons",
		"worst_case": "O(log n) Halving steps",
		"space_comp": "O(1) Iterative",
		"concepts": [
			{"title": "1. Sorted Data Requirement", "body": "Binary Search ONLY works if data is in ascending sorted order. If scrambled, halving decisions would discard valid files."},
			{"title": "2. Mid Calculation Formula", "body": "mid = left + (right - left) / 2 avoids 32-bit integer overflow that can occur with (left + right) / 2."},
			{"title": "3. Divide and Conquer", "body": "By comparing with the middle value, we know immediately whether the target is in the left or right partition."},
			{"title": "4. Sub-linear Efficiency", "body": "Doubling array size only adds ONE single extra comparison!"}
		]
	},
	"bubble_sort": {
		"title": "SECTOR 03: BUBBLE SORT",
		"subtitle": "Entropy Stabilization • Time Complexity: O(n²)",
		"code": [
			"// C Implementation: Bubble Sort",
			"void bubble_sort(int arr[], int n) {",
			"    for (int i = 0; i < n - 1; i++) {",
			"        for (int j = 0; j < n - i - 1; j++) {",
			"            if (arr[j] > arr[j + 1]) {",
			"                int temp = arr[j];",
			"                arr[j] = arr[j + 1];",
			"                arr[j + 1] = temp; // Swap!",
			"            }",
			"        }",
			"    }",
			"}"
		],
		"complexity_big_o": "O(n²) — Quadratic Growth",
		"complexity_desc": "Nested loops make n*(n-1)/2 comparisons. Simple to understand and implement in-place with O(1) memory.",
		"best_case": "O(n) — With swapped flag if already sorted",
		"avg_case": "O(n²) Comparisons and Swaps",
		"worst_case": "O(n²) Reverse-sorted archive",
		"space_comp": "O(1) In-place auxiliary memory",
		"concepts": [
			{"title": "1. Adjacent Comparison", "body": "Only compares immediate neighbors (arr[j] and arr[j+1]). Swaps them if left > right."},
			{"title": "2. Bubbling Invariant", "body": "At the end of pass i, the largest unsorted element has floated to its final locked position at index (n - 1 - i)."},
			{"title": "3. Shrinking Window", "body": "Because the tail is locked after each pass, loop j only needs to run up to (n - i - 1)."},
			{"title": "4. Stability", "body": "Bubble Sort is a stable sort: elements with identical keys maintain their relative original order."}
		]
	}
}

# ─── HUB UI ──────────────────────────────────────────────────
var _hub_overlay: ColorRect
var _hub_btn: Button


# ============================================================
# READY
# ============================================================

func _ready():
	add_to_group("dsa_game_ui")
	_bold_font    = UITheme.make_font(700)
	_regular_font = UITheme.make_font(400)
	_current_theme = UITheme.for_algo("linear_search")
	_build_ui()
	show_hub()


# ============================================================
# BUILD
# ============================================================

func _build_ui():
	var root := Control.new()
	root.name = "UIRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_hud(root)
	_build_progress_strip(root)
	_build_interactive_deck(root)
	_build_array_ribbon(root)
	_build_action_bar(root)
	_build_story_panel(root)
	_build_handbook_panel(root)
	_build_chapter_transition(root)
	_build_hub_screen(root)

	# Legacy compat — lessons do `modal_overlay.visible = false` directly
	modal_overlay = _story_overlay


# ─── HUD ─────────────────────────────────────────────────────
func _build_hud(root: Control):
	var anchor := MarginContainer.new()
	anchor.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	anchor.add_theme_constant_override("margin_top",  18)
	anchor.add_theme_constant_override("margin_left", 20)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(anchor)

	_hud_panel = PanelContainer.new()
	_hud_panel.add_theme_stylebox_override("panel",
		UITheme.glass_card(_current_theme.accent, 16))
	anchor.add_child(_hud_panel)

	var m := _margin(_hud_panel, 14, 20)
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	m.add_child(main_vbox)

	# 1. Top Cyber Status Header
	var top_header := HBoxContainer.new()
	top_header.add_theme_constant_override("separation", 8)
	main_vbox.add_child(top_header)

	var pulse_dot := _label("●", 10, Color(0.0, 0.95, 1.0), true)
	top_header.add_child(pulse_dot)

	_hud_chapter = _label("CHAPTER 1", 11, UITheme.C_TEXT_MUTED, true)
	top_header.add_child(_hud_chapter)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_header.add_child(spacer)

	_hud_status_badge = _label("", 10, Color(0.2, 0.96, 0.5), true)
	top_header.add_child(_hud_status_badge)

	# 2. Main Row (Icon + Topic/Objective + Target Box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	main_vbox.add_child(row)

	_hud_icon = _label("🔍", 32, _current_theme.accent, true)
	row.add_child(_hud_icon)

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 4)
	row.add_child(text_col)

	_hud_topic = _label("Linear Search", 26, _current_theme.accent, true)
	text_col.add_child(_hud_topic)

	_hud_objective = _label("Objective: Find the target", 14, UITheme.C_TEXT_MAIN, false)
	_hud_objective.custom_minimum_size = Vector2(285, 0)
	_hud_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(_hud_objective)

	# 3. Target Display Box (Adaptive)
	_hud_target_container = HBoxContainer.new()
	_hud_target_container.add_theme_constant_override("separation", 10)
	_hud_target_container.visible = true
	row.add_child(_hud_target_container)

	var sep := VSeparator.new()
	sep.add_theme_color_override("color", Color(0.0, 0.8, 1.0, 0.45))
	_hud_target_container.add_child(sep)

	var tgt_card := PanelContainer.new()
	tgt_card.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.02, 0.08, 0.16, 0.90), Color(0.2, 0.96, 0.5, 0.6), 1, 10))
	_hud_target_container.add_child(tgt_card)
	var tgt_m := _margin(tgt_card, 6, 12)
	var tgt_col := VBoxContainer.new()
	tgt_col.add_theme_constant_override("separation", 1)
	tgt_m.add_child(tgt_col)

	var t_header := _label("TARGET", 10, UITheme.C_TEXT_MUTED, true)
	t_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tgt_col.add_child(t_header)

	_hud_target_lbl = _label("--", 28, UITheme.C_GREEN, true)
	_hud_target_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tgt_col.add_child(_hud_target_lbl)

	# 4. Hub Shortcuts (Quick select buttons)
	_hud_shortcuts_row = HBoxContainer.new()
	_hud_shortcuts_row.add_theme_constant_override("separation", 6)
	main_vbox.add_child(_hud_shortcuts_row)

	var chip_data := [
		{"key": "1", "name": "Linear Search"},
		{"key": "2", "name": "Binary Search"},
		{"key": "3", "name": "Bubble Sort"}
	]
	for cd in chip_data:
		var chip_btn := Button.new()
		chip_btn.text = " [%s] %s " % [cd["key"], cd["name"]]
		chip_btn.add_theme_font_override("font", _bold_font)
		chip_btn.add_theme_font_size_override("font_size", 11)
		chip_btn.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		chip_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.03, 0.09, 0.18, 0.85), Color(0.0, 0.65, 0.9, 0.6), 1, 8))
		chip_btn.add_theme_stylebox_override("hover",  UITheme.button_hover_style(Color(0.0, 0.85, 1.0), 8))
		var key_idx = int(cd["key"]) - 1
		chip_btn.pressed.connect(func():
			if is_inside_tree() and get_tree() != null:
				var lm = get_tree().get_first_node_in_group("lesson_manager")
				if lm and lm.has_method("launch_lesson"):
					lm.launch_lesson(key_idx)
		)
		_hud_shortcuts_row.add_child(chip_btn)

	_hud_shortcuts_row.visible = false

	# 5. In-Lesson Return Button
	_hub_btn = Button.new()
	_hub_btn.text = " 🌐 NEXUS HUB (H) "
	_hub_btn.add_theme_font_override("font", _bold_font)
	_hub_btn.add_theme_font_size_override("font_size", 12)
	_hub_btn.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
	_hub_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.02, 0.08, 0.18, 0.9), Color(0.0, 0.75, 1.0), 1, 10))
	_hub_btn.add_theme_stylebox_override("hover",  UITheme.button_hover_style(Color(0.0, 0.9, 1.0), 10))
	_hub_btn.pressed.connect(_on_hub_btn_pressed)
	_hub_btn.visible = true
	main_vbox.add_child(_hub_btn)


# ─── PROGRESS STRIP ──────────────────────────────────────────
func _build_progress_strip(root: Control):
	var anchor := MarginContainer.new()
	_prog_strip_container = anchor
	anchor.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	anchor.add_theme_constant_override("margin_top",   20)
	anchor.add_theme_constant_override("margin_right", 20)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor.visible = false
	root.add_child(anchor)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.05, 0.07, 0.12, 0.9), Color(0.2, 0.3, 0.4, 1.0), 1, 12))
	anchor.add_child(panel)

	var m := _margin(panel, 10, 14)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	m.add_child(row)

	_prog_pills.clear()
	for i in range(_prog_chapters.size()):
		var pill_bg := PanelContainer.new()
		var is_done  := (i < _current_chapter_index)
		var is_cur   := (i == _current_chapter_index)
		var bg_col   := Color(0.05, 0.1, 0.05, 1) if is_done else (Color(0.12, 0.04, 0.22, 1) if is_cur else Color(0.05, 0.05, 0.1, 1))
		var bd_col   := UITheme.C_GREEN if is_done else (Color(0.55, 0.15, 0.9) if is_cur else Color(0.15, 0.2, 0.3))
		pill_bg.add_theme_stylebox_override("panel", UITheme.styled_box(bg_col, bd_col, 1, 10))
		row.add_child(pill_bg)

		var pm := _margin(pill_bg, 6, 12)
		var prefix := "✓ " if is_done else ("● " if is_cur else "○ ")
		var lbl := _label(prefix + _prog_chapters[i], 12,
			UITheme.C_GREEN if is_done else (UITheme.C_WHITE if is_cur else UITheme.C_TEXT_MUTED), is_cur)
		pm.add_child(lbl)
		_prog_pills.append(lbl)


# ─── INTERACTIVE CONTROL DECK ────────────────────────────────
func _build_interactive_deck(root: Control):
	var anchor := MarginContainer.new()
	anchor.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	anchor.add_theme_constant_override("margin_top", 18)
	anchor.add_theme_constant_override("margin_right", 20)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(anchor)

	_deck_container = PanelContainer.new()
	_deck_container.name = "InteractiveDeck"
	_deck_container.add_theme_stylebox_override("panel",
		UITheme.glass_card(_current_theme.accent, 14))
	_deck_container.visible = false
	anchor.add_child(_deck_container)

	var m := _margin(_deck_container, 8, 14)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	m.add_child(row)

	# Mode label
	var mode_lbl := _label("⚡ LAB", 11, _current_theme.accent, true)
	row.add_child(mode_lbl)

	# 1. Play / Pause Button
	_deck_play_btn = Button.new()
	_deck_play_btn.text = " ▶ PLAY "
	_deck_play_btn.focus_mode = Control.FOCUS_NONE
	_deck_play_btn.add_theme_font_override("font", _bold_font)
	_deck_play_btn.add_theme_font_size_override("font_size", 12)
	_deck_play_btn.add_theme_color_override("font_color", UITheme.C_WHITE)
	_deck_play_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.04, 0.16, 0.10, 0.9), UITheme.C_GREEN, 1, 8))
	_deck_play_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_GREEN, 8))
	_deck_play_btn.pressed.connect(_on_deck_play_pressed)
	row.add_child(_deck_play_btn)

	# 2. Step Button
	_deck_step_btn = Button.new()
	_deck_step_btn.text = " ⏭ STEP (SPACE) "
	_deck_step_btn.focus_mode = Control.FOCUS_NONE
	_deck_step_btn.add_theme_font_override("font", _bold_font)
	_deck_step_btn.add_theme_font_size_override("font_size", 12)
	_deck_step_btn.add_theme_color_override("font_color", UITheme.C_WHITE)
	_deck_step_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.03, 0.10, 0.22, 0.9), _current_theme.accent, 1, 8))
	_deck_step_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(_current_theme.accent, 8))
	_deck_step_btn.pressed.connect(_on_deck_step_pressed)
	row.add_child(_deck_step_btn)

	# 3. Reset Button
	_deck_reset_btn = Button.new()
	_deck_reset_btn.text = " ↺ RESET (R) "
	_deck_reset_btn.focus_mode = Control.FOCUS_NONE
	_deck_reset_btn.add_theme_font_override("font", _bold_font)
	_deck_reset_btn.add_theme_font_size_override("font_size", 12)
	_deck_reset_btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	_deck_reset_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.12, 0.08, 0.04, 0.9), UITheme.C_ORANGE, 1, 8))
	_deck_reset_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_ORANGE, 8))
	_deck_reset_btn.pressed.connect(_on_deck_reset_pressed)
	row.add_child(_deck_reset_btn)

	# 4. Speed Button
	_deck_speed_btn = Button.new()
	_deck_speed_btn.text = " ⚡ 1.0x "
	_deck_speed_btn.focus_mode = Control.FOCUS_NONE
	_deck_speed_btn.add_theme_font_override("font", _bold_font)
	_deck_speed_btn.add_theme_font_size_override("font_size", 12)
	_deck_speed_btn.add_theme_color_override("font_color", UITheme.C_TEXT_MUTED)
	_deck_speed_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.06, 0.08, 0.14, 0.9), Color(0.2, 0.3, 0.4), 1, 8))
	_deck_speed_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_CYAN, 8))
	_deck_speed_btn.pressed.connect(_on_deck_speed_pressed)
	row.add_child(_deck_speed_btn)

	# 5. Target Picker Button
	_deck_target_btn = Button.new()
	_deck_target_btn.text = " 🎯 TGT: 40 ▾ "
	_deck_target_btn.focus_mode = Control.FOCUS_NONE
	_deck_target_btn.add_theme_font_override("font", _bold_font)
	_deck_target_btn.add_theme_font_size_override("font_size", 12)
	_deck_target_btn.add_theme_color_override("font_color", UITheme.C_CYAN)
	_deck_target_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.04, 0.12, 0.18, 0.9), Color(0.0, 0.6, 0.8), 1, 8))
	_deck_target_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_CYAN, 8))
	_deck_target_btn.pressed.connect(_on_deck_target_pressed)
	row.add_child(_deck_target_btn)

	# 6. Randomize Array Button
	_deck_random_btn = Button.new()
	_deck_random_btn.text = " 🎲 NEW ARRAY "
	_deck_random_btn.focus_mode = Control.FOCUS_NONE
	_deck_random_btn.add_theme_font_override("font", _bold_font)
	_deck_random_btn.add_theme_font_size_override("font_size", 12)
	_deck_random_btn.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0))
	_deck_random_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.08, 0.05, 0.15, 0.9), UITheme.C_PURPLE, 1, 8))
	_deck_random_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_PURPLE, 8))
	_deck_random_btn.pressed.connect(_on_deck_random_pressed)
	row.add_child(_deck_random_btn)

	# 7. Separator
	var sep := VSeparator.new()
	row.add_child(sep)

	# 8. Book Guide Button
	_deck_book_btn = Button.new()
	_deck_book_btn.text = " 📖 BOOK GUIDE (B) "
	_deck_book_btn.focus_mode = Control.FOCUS_NONE
	_deck_book_btn.add_theme_font_override("font", _bold_font)
	_deck_book_btn.add_theme_font_size_override("font_size", 12)
	_deck_book_btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.5))
	_deck_book_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.18, 0.14, 0.04, 0.9), UITheme.C_YELLOW, 1, 8))
	_deck_book_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_YELLOW, 8))
	_deck_book_btn.pressed.connect(_on_deck_book_pressed)
	row.add_child(_deck_book_btn)


# ─── ARRAY RIBBON (HUD Visualizer) ───────────────────────────
func _build_array_ribbon(root: Control):
	var anchor := MarginContainer.new()
	anchor.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	anchor.add_theme_constant_override("margin_bottom", 120)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(anchor)

	var centerer := CenterContainer.new()
	centerer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor.add_child(centerer)

	_array_ribbon_container = PanelContainer.new()
	_array_ribbon_container.name = "ArrayRibbon"
	_array_ribbon_container.add_theme_stylebox_override("panel",
		UITheme.glass_card(_current_theme.accent, 14))
	_array_ribbon_container.visible = false
	centerer.add_child(_array_ribbon_container)

	var m := _margin(_array_ribbon_container, 8, 14)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	m.add_child(col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	col.add_child(title_row)

	var r_lbl := _label("INTERACTIVE ARRAY STREAM • CLICK ANY NODE TO PROBE", 11, _current_theme.accent, true)
	title_row.add_child(r_lbl)

	_array_ribbon_hbox = HBoxContainer.new()
	_array_ribbon_hbox.add_theme_constant_override("separation", 8)
	col.add_child(_array_ribbon_hbox)


# ─── ACTION BAR ──────────────────────────────────────────────
func _build_action_bar(root: Control):
	var anchor := MarginContainer.new()
	anchor.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	anchor.add_theme_constant_override("margin_bottom", 24)
	anchor.add_theme_constant_override("margin_left",   24)
	anchor.add_theme_constant_override("margin_right",  24)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(anchor)

	var centerer := CenterContainer.new()
	centerer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor.add_child(centerer)

	_bar_panel = PanelContainer.new()
	_bar_panel.add_theme_stylebox_override("panel",
		UITheme.styled_box(_current_theme.bar_bg, _current_theme.border, 2, 14))
	centerer.add_child(_bar_panel)

	var m := _margin(_bar_panel, 14, 36)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	m.add_child(col)

	_bar_step    = _label("READY TO START", 17, _current_theme.accent, true)
	_bar_step.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_bar_step)

	_bar_formula = _label("", 20, UITheme.C_YELLOW, true)
	_bar_formula.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bar_formula.visible = false
	_bar_formula.custom_minimum_size = Vector2(700, 0)
	col.add_child(_bar_formula)

	_bar_hint = _label("Press SPACE / ENTER or click to continue.", 14, UITheme.C_TEXT_MUTED, false)
	_bar_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bar_hint.custom_minimum_size = Vector2(700, 0)
	_bar_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_bar_hint)


# ─── STORY PANEL (CODA speaks) ───────────────────────────────
func _build_story_panel(root: Control):
	_story_overlay = ColorRect.new()
	_story_overlay.color    = UITheme.C_BLACK_SCRIM
	_story_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_story_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_overlay.visible  = false
	root.add_child(_story_overlay)

	var bottom_anchor := MarginContainer.new()
	bottom_anchor.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_anchor.add_theme_constant_override("margin_bottom", 16)
	bottom_anchor.add_theme_constant_override("margin_left", 60)
	bottom_anchor.add_theme_constant_override("margin_right", 60)
	bottom_anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_overlay.add_child(bottom_anchor)

	_story_panel = PanelContainer.new()
	_story_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_story_panel.add_theme_stylebox_override("panel",
		UITheme.glass_card(_current_theme.accent, 16))
	bottom_anchor.add_child(_story_panel)

	var m := _margin(_story_panel, 12, 20)
	var outer_col := VBoxContainer.new()
	outer_col.add_theme_constant_override("separation", 8)
	m.add_child(outer_col)

	# ── Chapter badge ──
	_story_chapter_badge = _label("CHAPTER 1  •  LINEAR SEARCH", 12, UITheme.C_TEXT_MUTED, true)
	_story_chapter_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_col.add_child(_story_chapter_badge)

	# ── CODA avatar + title row ──
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 14)
	outer_col.add_child(header_row)
	_story_header_row = header_row

	_coda_body = _build_coda_avatar(_current_theme.accent)
	header_row.add_child(_coda_body)

	var title_col := VBoxContainer.new()
	title_col.add_theme_constant_override("separation", 4)
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title_col)

	_story_title = _label("MESSAGE TITLE", 18, _current_theme.accent, true)
	_story_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_col.add_child(_story_title)

	_story_body = _label("", 14, UITheme.C_TEXT_MAIN, false)
	_story_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_col.add_child(_story_body)

	_story_stats = _label("", 14, _current_theme.accent, true)
	_story_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_col.add_child(_story_stats)

	# ── C Code Display Panel ──
	_story_code_panel = PanelContainer.new()
	_story_code_panel.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.02, 0.04, 0.09, 0.96), _current_theme.border, 1, 14))
	_story_code_panel.visible = false
	outer_col.add_child(_story_code_panel)

	var code_margin := _margin(_story_code_panel, 12, 16)
	_story_code_lbl = RichTextLabel.new()
	_story_code_lbl.bbcode_enabled = true
	_story_code_lbl.fit_content = true
	_story_code_lbl.scroll_active = false
	_story_code_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_code_lbl.add_theme_font_size_override("normal_font_size", 14)
	_story_code_lbl.add_theme_font_size_override("bold_font_size", 14)
	_story_code_lbl.add_theme_font_size_override("italics_font_size", 14)
	code_margin.add_child(_story_code_lbl)

	# ── Quiz buttons container (horizontal row for non-intrusive bottom dock) ──
	_story_choice_container = HBoxContainer.new()
	_story_choice_container.add_theme_constant_override("separation", 12)
	_story_choice_container.visible = false
	outer_col.add_child(_story_choice_container)

	for i in range(3):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 46)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_override("font", _bold_font)
		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", UITheme.C_WHITE)
		btn.add_theme_color_override("font_hover_color", UITheme.C_WHITE)
		btn.add_theme_stylebox_override("normal",
			UITheme.button_style(Color(0.08, 0.14, 0.28, 0.85), _current_theme.border, 2, 12))
		btn.add_theme_stylebox_override("hover",
			UITheme.button_hover_style(_current_theme.accent, 12))
		btn.add_theme_stylebox_override("pressed",
			UITheme.button_correct_style(12))
		var idx := i
		btn.pressed.connect(func(): _on_quiz_button_pressed(idx))
		_story_choice_container.add_child(btn)
		_story_choice_btns.append(btn)

	# ── Animatic Feedback Card (In-place Explanation) ──
	_story_feedback_card = PanelContainer.new()
	_story_feedback_card.add_theme_stylebox_override("panel",
		UITheme.explanation_box(UITheme.C_GREEN, Color(0.03, 0.10, 0.06, 0.95)))
	_story_feedback_card.visible = false
	outer_col.add_child(_story_feedback_card)

	var fb_m := _margin(_story_feedback_card, 16, 20)
	var fb_col := VBoxContainer.new()
	fb_col.add_theme_constant_override("separation", 10)
	fb_m.add_child(fb_col)

	_story_feedback_badge = _label("🎉  EXCELLENT! THAT'S CORRECT!", 17, UITheme.C_GREEN, true)
	fb_col.add_child(_story_feedback_badge)

	_story_feedback_body = _label("", 16, UITheme.C_TEXT_MAIN, false)
	_story_feedback_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fb_col.add_child(_story_feedback_body)

	var fb_btn_row := HBoxContainer.new()
	fb_btn_row.add_theme_constant_override("separation", 14)
	fb_btn_row.alignment = BoxContainer.ALIGNMENT_END
	fb_col.add_child(fb_btn_row)

	_story_feedback_retry_btn = Button.new()
	_story_feedback_retry_btn.text = "↺  Try Another Option"
	_story_feedback_retry_btn.focus_mode = Control.FOCUS_NONE
	_story_feedback_retry_btn.add_theme_font_override("font", _bold_font)
	_story_feedback_retry_btn.add_theme_font_size_override("font_size", 14)
	_story_feedback_retry_btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	_story_feedback_retry_btn.add_theme_stylebox_override("normal",
		UITheme.button_style(Color(0.20, 0.15, 0.05, 0.9), UITheme.C_YELLOW, 2, 10))
	_story_feedback_retry_btn.add_theme_stylebox_override("hover",
		UITheme.button_hover_style(UITheme.C_YELLOW, 10))
	_story_feedback_retry_btn.pressed.connect(_on_quiz_retry_pressed)
	fb_btn_row.add_child(_story_feedback_retry_btn)

	_story_feedback_next_btn = Button.new()
	_story_feedback_next_btn.text = "Next Question → (SPACE)"
	_story_feedback_next_btn.focus_mode = Control.FOCUS_NONE
	_story_feedback_next_btn.add_theme_font_override("font", _bold_font)
	_story_feedback_next_btn.add_theme_font_size_override("font_size", 15)
	_story_feedback_next_btn.add_theme_color_override("font_color", UITheme.C_WHITE)
	_story_feedback_next_btn.add_theme_stylebox_override("normal",
		UITheme.button_correct_style(10))
	_story_feedback_next_btn.add_theme_stylebox_override("hover",
		UITheme.button_hover_style(UITheme.C_GREEN, 10))
	_story_feedback_next_btn.pressed.connect(_on_quiz_next_pressed)
	fb_btn_row.add_child(_story_feedback_next_btn)

	_story_hint = _label("SPACE = continue  |  1 / 2 / 3 = select option", 13, UITheme.C_TEXT_MUTED, false)
	_story_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_col.add_child(_story_hint)


# ─── INTERACTIVE DIGITAL HANDBOOK (Archive Codex & Live Lab) ─
func _build_handbook_panel(root: Control):
	var anchor := MarginContainer.new()
	anchor.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	anchor.add_theme_constant_override("margin_top", 72)
	anchor.add_theme_constant_override("margin_right", 20)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(anchor)

	_handbook_panel = PanelContainer.new()
	_handbook_panel.name = "HandbookPanel"
	_handbook_panel.custom_minimum_size = Vector2(440, 660)
	_handbook_panel.add_theme_stylebox_override("panel",
		UITheme.glass_card(_current_theme.accent, 18))
	_handbook_panel.visible = false
	anchor.add_child(_handbook_panel)

	var m := _margin(_handbook_panel, 16, 18)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	m.add_child(col)

	# 1. Header Row
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	col.add_child(header_row)

	var book_icon := _label("📖", 20, _current_theme.accent, true)
	header_row.add_child(book_icon)

	var title_lbl := _label("ARCHIVE CODEX & LIVE LAB", 16, UITheme.C_WHITE, true)
	header_row.add_child(title_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(spacer)

	var close_btn := Button.new()
	close_btn.text = " ✕ "
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_font_override("font", _bold_font)
	close_btn.add_theme_font_size_override("font_size", 13)
	close_btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.16, 0.04, 0.04, 0.8), UITheme.C_RED, 1, 6))
	close_btn.add_theme_stylebox_override("hover", UITheme.button_hover_style(UITheme.C_RED, 6))
	close_btn.pressed.connect(func(): toggle_handbook(false))
	header_row.add_child(close_btn)

	_handbook_subtitle_lbl = _label("Interactive Algorithm Companion", 12, UITheme.C_TEXT_MUTED, false)
	col.add_child(_handbook_subtitle_lbl)

	# 2. Tabs Row
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 4)
	col.add_child(tab_row)

	var tab_names := ["💻 Code", "🔍 Variables", "📊 Big-O", "📘 Concepts"]
	_handbook_tab_buttons.clear()
	_handbook_tab_containers.clear()

	for i in range(tab_names.size()):
		var t_btn := Button.new()
		t_btn.text = tab_names[i]
		t_btn.focus_mode = Control.FOCUS_NONE
		t_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t_btn.add_theme_font_override("font", _bold_font)
		t_btn.add_theme_font_size_override("font_size", 11)
		var t_idx = i
		t_btn.pressed.connect(func(): _switch_handbook_tab(t_idx))
		tab_row.add_child(t_btn)
		_handbook_tab_buttons.append(t_btn)

	# 3. Content Area
	var content_holder := PanelContainer.new()
	content_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_holder.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.02, 0.05, 0.12, 0.95), Color(0.08, 0.15, 0.28, 0.7), 1, 12))
	col.add_child(content_holder)
	var cm := _margin(content_holder, 12, 14)

	# ── Tab 0: Code Trace ──
	var code_tab := VBoxContainer.new()
	code_tab.add_theme_constant_override("separation", 8)
	code_tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cm.add_child(code_tab)
	_handbook_tab_containers.append(code_tab)

	var code_header := _label("C CODE EXECUTION TRACE", 11, _current_theme.accent, true)
	code_tab.add_child(code_header)

	var code_scroll := ScrollContainer.new()
	code_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_tab.add_child(code_scroll)

	_handbook_code_lbl = RichTextLabel.new()
	_handbook_code_lbl.bbcode_enabled = true
	_handbook_code_lbl.fit_content = true
	_handbook_code_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_handbook_code_lbl.add_theme_font_size_override("normal_font_size", 12)
	_handbook_code_lbl.add_theme_font_size_override("bold_font_size", 12)
	code_scroll.add_child(_handbook_code_lbl)

	# ── Tab 1: Variables Watch ──
	var var_tab := VBoxContainer.new()
	var_tab.add_theme_constant_override("separation", 8)
	var_tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var_tab.visible = false
	cm.add_child(var_tab)
	_handbook_tab_containers.append(var_tab)

	var var_header := _label("WATCH WINDOW • RUNTIME STATE", 11, UITheme.C_CYAN, true)
	var_tab.add_child(var_header)

	var var_scroll := ScrollContainer.new()
	var_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var_tab.add_child(var_scroll)

	_handbook_var_container = VBoxContainer.new()
	_handbook_var_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_handbook_var_container.add_theme_constant_override("separation", 6)
	var_scroll.add_child(_handbook_var_container)

	# ── Tab 2: Complexity ──
	var comp_tab := VBoxContainer.new()
	comp_tab.add_theme_constant_override("separation", 10)
	comp_tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	comp_tab.visible = false
	cm.add_child(comp_tab)
	_handbook_tab_containers.append(comp_tab)

	var comp_header := _label("COMPLEXITY & EFFICIENCY GAUGE", 11, UITheme.C_YELLOW, true)
	comp_tab.add_child(comp_header)

	_handbook_complexity_lbl = _label("O(n) Linear Time", 16, UITheme.C_YELLOW, true)
	comp_tab.add_child(_handbook_complexity_lbl)

	_handbook_meter_label = _label("Comparisons: 0 / 5", 12, UITheme.C_WHITE, false)
	comp_tab.add_child(_handbook_meter_label)

	_handbook_meter_bar = ProgressBar.new()
	_handbook_meter_bar.custom_minimum_size = Vector2(0, 14)
	_handbook_meter_bar.max_value = 100
	_handbook_meter_bar.value = 0
	_handbook_meter_bar.show_percentage = false
	comp_tab.add_child(_handbook_meter_bar)

	var comp_scroll := ScrollContainer.new()
	comp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	comp_tab.add_child(comp_scroll)

	_handbook_details_col = VBoxContainer.new()
	_handbook_details_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_handbook_details_col.add_theme_constant_override("separation", 6)
	comp_scroll.add_child(_handbook_details_col)

	# ── Tab 3: Concepts ──
	var conc_tab := VBoxContainer.new()
	conc_tab.add_theme_constant_override("separation", 8)
	conc_tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	conc_tab.visible = false
	cm.add_child(conc_tab)
	_handbook_tab_containers.append(conc_tab)

	var conc_header := _label("CORE ALGORITHMIC PRINCIPLES", 11, UITheme.C_GREEN, true)
	conc_tab.add_child(conc_header)

	var conc_scroll := ScrollContainer.new()
	conc_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	conc_tab.add_child(conc_scroll)

	_handbook_concepts_container = VBoxContainer.new()
	_handbook_concepts_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_handbook_concepts_container.add_theme_constant_override("separation", 8)
	conc_scroll.add_child(_handbook_concepts_container)

	_switch_handbook_tab(0)
	set_handbook_topic("linear_search")


# ─── HANDBOOK & DECK METHODS ─────────────────────────────────
func _switch_handbook_tab(idx: int):
	for i in range(_handbook_tab_containers.size()):
		var is_active = (i == idx)
		_handbook_tab_containers[i].visible = is_active
		if i < _handbook_tab_buttons.size():
			var btn = _handbook_tab_buttons[i]
			if is_active:
				btn.add_theme_stylebox_override("normal", UITheme.button_style(_current_theme.accent.darkened(0.5), _current_theme.accent, 2, 6))
				btn.add_theme_color_override("font_color", UITheme.C_WHITE)
			else:
				btn.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.04, 0.08, 0.16, 0.8), Color(0.12, 0.2, 0.3), 1, 6))
				btn.add_theme_color_override("font_color", UITheme.C_TEXT_MUTED)

func toggle_handbook(force_state = null):
	if force_state != null:
		_handbook_visible = force_state
	else:
		_handbook_visible = not _handbook_visible

	if _handbook_panel:
		_handbook_panel.visible = _handbook_visible

	if _deck_book_btn:
		if _handbook_visible:
			_deck_book_btn.text = " 📖 CLOSE GUIDE "
			_deck_book_btn.add_theme_color_override("font_color", UITheme.C_GREEN)
		else:
			_deck_book_btn.text = " 📖 BOOK GUIDE (B) "
			_deck_book_btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.5))

	if _handbook_visible:
		_release_mouse_for_ui()
	handbook_toggled.emit(_handbook_visible)

func is_handbook_open() -> bool:
	return _handbook_visible

func set_handbook_topic(topic_key: String):
	_handbook_current_topic = topic_key
	if not HANDBOOK_DATA.has(topic_key):
		return
	var d = HANDBOOK_DATA[topic_key]
	if _handbook_subtitle_lbl:
		_handbook_subtitle_lbl.text = d.get("subtitle", "")
	if _handbook_complexity_lbl:
		_handbook_complexity_lbl.text = d.get("complexity_big_o", "")
	_render_handbook_code()
	_render_handbook_complexity(d)
	_render_handbook_concepts(d)

func highlight_code_line(line_idx: int):
	_handbook_active_line = line_idx
	_render_handbook_code()

func _render_handbook_code():
	if not HANDBOOK_DATA.has(_handbook_current_topic):
		return
	var d = HANDBOOK_DATA[_handbook_current_topic]
	var lines: Array = d.get("code", [])
	var bb := ""
	for i in range(lines.size()):
		var line_str: String = lines[i]
		var line_num = "%2d  " % (i + 1)
		if i == _handbook_active_line:
			bb += "[bgcolor=#003d52][color=#55ffff][b]▶ %s%s[/b][/color][/bgcolor]\n" % [line_num, line_str]
		elif line_str.strip_edges().begins_with("//"):
			bb += "[color=#6a88a0][i]  %s%s[/i][/color]\n" % [line_num, line_str]
		else:
			bb += "[color=#d0e4f8]  %s%s[/color]\n" % [line_num, line_str]
	if _handbook_code_lbl:
		_handbook_code_lbl.text = bb

func _render_handbook_complexity(d: Dictionary):
	if _handbook_details_col == null: return
	for c in _handbook_details_col.get_children():
		c.queue_free()

	var desc_lbl := _label(d.get("complexity_desc", ""), 12, UITheme.C_TEXT_MUTED, false)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_handbook_details_col.add_child(desc_lbl)

	var items := [
		["Best Case", d.get("best_case", "O(1)"), UITheme.C_GREEN],
		["Average Case", d.get("avg_case", "O(n)"), UITheme.C_YELLOW],
		["Worst Case", d.get("worst_case", "O(n)"), UITheme.C_RED],
		["Space Complexity", d.get("space_comp", "O(1)"), UITheme.C_CYAN]
	]
	for it in items:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel",
			UITheme.styled_box(Color(0.04, 0.08, 0.16, 0.8), Color(0.12, 0.22, 0.35, 0.7), 1, 8))
		_handbook_details_col.add_child(card)
		var rm := _margin(card, 5, 8)
		var h := HBoxContainer.new()
		rm.add_child(h)
		h.add_child(_label(it[0], 11, UITheme.C_TEXT_MUTED, true))
		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(sp)
		h.add_child(_label(it[1], 12, it[2], true))

func _render_handbook_concepts(d: Dictionary):
	if _handbook_concepts_container == null: return
	for c in _handbook_concepts_container.get_children():
		c.queue_free()

	var concepts: Array = d.get("concepts", [])
	for c_data in concepts:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel",
			UITheme.styled_box(Color(0.03, 0.07, 0.16, 0.85), Color(0.1, 0.25, 0.45, 0.6), 1, 8))
		_handbook_concepts_container.add_child(card)

		var cm := _margin(card, 8, 10)
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		cm.add_child(col)

		col.add_child(_label(c_data.get("title", ""), 12, _current_theme.accent, true))
		var b_lbl := _label(c_data.get("body", ""), 11, UITheme.C_TEXT_MAIN, false)
		b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(b_lbl)

func set_watch_variables(vars: Dictionary):
	_watch_vars = vars.duplicate()
	if _handbook_var_container == null: return
	for c in _handbook_var_container.get_children():
		c.queue_free()

	for k in vars.keys():
		var row_card := PanelContainer.new()
		row_card.add_theme_stylebox_override("panel",
			UITheme.styled_box(Color(0.03, 0.08, 0.18, 0.85), Color(0.1, 0.3, 0.5, 0.6), 1, 8))
		_handbook_var_container.add_child(row_card)

		var rm := _margin(row_card, 6, 10)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 8)
		rm.add_child(h)

		var name_lbl := _label(str(k), 12, UITheme.C_TEXT_MUTED, true)
		h.add_child(name_lbl)

		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(sp)

		var val_str = str(vars[k])
		var val_col = UITheme.C_GREEN if ("Found" in val_str or "MATCH" in val_str or "SORTED" in val_str) else (UITheme.C_YELLOW if ("Swap" in val_str or "SWAP" in val_str) else UITheme.C_WHITE)
		var val_lbl := _label(val_str, 12, val_col, true)
		h.add_child(val_lbl)

func set_complexity_stats(comparisons: int, max_n: int, status_str: String = ""):
	if _handbook_meter_bar:
		_handbook_meter_bar.max_value = max(max_n, 1)
		_handbook_meter_bar.value = comparisons
	if _handbook_meter_label:
		_handbook_meter_label.text = "Comparisons: %d / %d items • %s" % [comparisons, max_n, status_str]

func update_array_ribbon(values: Array, active_idx: int, target_val: int, checked_indices: Array, found_idx: int = -1, sorted_indices: Array = []):
	if _array_ribbon_hbox == null: return
	for c in _array_ribbon_hbox.get_children():
		c.queue_free()

	for i in range(values.size()):
		var val = values[i]
		var card := Button.new()
		card.focus_mode = Control.FOCUS_NONE
		card.custom_minimum_size = Vector2(58, 62)

		var is_active = (i == active_idx)
		var is_found = (i == found_idx)
		var is_checked = (i in checked_indices)
		var is_sorted = (i in sorted_indices)

		var bg_col = Color(0.04, 0.18, 0.10, 0.9) if is_found else (Color(0.04, 0.16, 0.14, 0.9) if is_sorted else (Color(0.02, 0.12, 0.22, 0.9) if is_active else Color(0.02, 0.05, 0.12, 0.8)))
		var bd_col = UITheme.C_GREEN if (is_found or is_sorted) else (_current_theme.accent if is_active else (Color(0.2, 0.3, 0.4) if is_checked else Color(0.12, 0.2, 0.3)))
		var bw = 2 if (is_active or is_found) else 1
		card.add_theme_stylebox_override("normal", UITheme.styled_box(bg_col, bd_col, bw, 8))
		card.add_theme_stylebox_override("hover", UITheme.button_hover_style(_current_theme.accent, 8))

		var prefix := ""
		if is_found: prefix = "✓ "
		elif is_active: prefix = "▲ "
		elif is_sorted: prefix = "🔒 "
		elif is_checked: prefix = "✗ "

		card.text = "[%d]\n%s%s" % [i, prefix, str(val)]
		card.add_theme_font_override("font", _bold_font)
		card.add_theme_font_size_override("font_size", 12)
		var text_col = UITheme.C_GREEN if is_found else (_current_theme.accent if is_active else (UITheme.C_TEXT_MUTED if is_checked else UITheme.C_WHITE))
		card.add_theme_color_override("font_color", text_col)

		var el_idx = i
		var el_val = int(val)
		card.pressed.connect(func(): ribbon_element_clicked.emit(el_idx, el_val))
		_array_ribbon_hbox.add_child(card)

func _on_deck_play_pressed():
	_is_auto_playing = not _is_auto_playing
	if _deck_play_btn:
		_deck_play_btn.text = " ⏸ PAUSE " if _is_auto_playing else " ▶ PLAY "
		_deck_play_btn.add_theme_color_override("font_color", UITheme.C_YELLOW if _is_auto_playing else UITheme.C_WHITE)
	deck_play_toggled.emit(_is_auto_playing)

func _on_deck_step_pressed():
	deck_step_requested.emit()

func _on_deck_reset_pressed():
	_is_auto_playing = false
	if _deck_play_btn:
		_deck_play_btn.text = " ▶ PLAY "
	deck_reset_requested.emit()

func _on_deck_speed_pressed():
	if _playback_speed == 1.0: _playback_speed = 1.5
	elif _playback_speed == 1.5: _playback_speed = 2.0
	elif _playback_speed == 2.0: _playback_speed = 0.5
	else: _playback_speed = 1.0
	if _deck_speed_btn:
		_deck_speed_btn.text = " ⚡ %.1fx " % _playback_speed
	deck_speed_changed.emit(_playback_speed)

func _on_deck_target_pressed():
	var targets := [10, 25, 40, 15, 30, 99]
	var cur_idx = targets.find(target_value)
	var next_tgt = targets[(cur_idx + 1) % targets.size()] if cur_idx != -1 else 40
	target_value = next_tgt
	set_deck_target_label(next_tgt)
	deck_target_selected.emit(next_tgt)

func _on_deck_random_pressed():
	deck_randomize_requested.emit()

func _on_deck_book_pressed():
	toggle_handbook()

func toggle_play():
	_on_deck_play_pressed()

func set_playback_state(is_playing: bool):
	_is_auto_playing = is_playing
	if _deck_play_btn:
		_deck_play_btn.text = " ⏸ PAUSE " if _is_auto_playing else " ▶ PLAY "
		_deck_play_btn.add_theme_color_override("font_color", UITheme.C_YELLOW if _is_auto_playing else UITheme.C_WHITE)

func set_deck_target_label(val: int):
	target_value = val
	if _deck_target_btn:
		_deck_target_btn.text = " 🎯 TGT: %d ▾ " % val


# ─── CODA Robot Avatar ───────────────────────────────────────
func _build_coda_avatar(color: Color) -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(72, 88)
	container.name = "CodaAvatar"

	# Head
	var head := ColorRect.new()
	head.color = color.darkened(0.3)
	head.position = Vector2(8, 0)
	head.size = Vector2(56, 50)
	container.add_child(head)

	# Eyes
	for ex in [16, 36]:
		var eye := ColorRect.new()
		eye.color = UITheme.C_WHITE
		eye.position = Vector2(ex, 12)
		eye.size = Vector2(12, 14)
		container.add_child(eye)
		var pupil := ColorRect.new()
		pupil.color = color
		pupil.position = Vector2(ex + 3, 16)
		pupil.size = Vector2(6, 6)
		container.add_child(pupil)

	# Mouth line
	var mouth := ColorRect.new()
	mouth.color = color
	mouth.position = Vector2(18, 36)
	mouth.size = Vector2(36, 3)
	container.add_child(mouth)

	# Antenna
	var ant := ColorRect.new()
	ant.color = color
	ant.position = Vector2(32, -12)
	ant.size = Vector2(4, 14)
	container.add_child(ant)
	var ant_tip := ColorRect.new()
	ant_tip.color = UITheme.C_WHITE
	ant_tip.position = Vector2(29, -16)
	ant_tip.size = Vector2(10, 8)
	container.add_child(ant_tip)

	# Body
	var body := ColorRect.new()
	body.color = color.darkened(0.45)
	body.position = Vector2(12, 52)
	body.size = Vector2(48, 32)
	container.add_child(body)

	# Chest light
	var chest := ColorRect.new()
	chest.color = color
	chest.position = Vector2(28, 58)
	chest.size = Vector2(16, 16)
	container.add_child(chest)

	return container


# ─── CHAPTER TRANSITION OVERLAY ──────────────────────────────
func _build_chapter_transition(root: Control):
	_trans_overlay = ColorRect.new()
	_trans_overlay.color   = Color(0, 0, 0, 0.0)
	_trans_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_trans_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trans_overlay.visible = false
	_trans_overlay.z_index = 100
	root.add_child(_trans_overlay)

	var centerer := CenterContainer.new()
	centerer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centerer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trans_overlay.add_child(centerer)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	centerer.add_child(col)

	_trans_chapter  = _label("CHAPTER 2", 22, UITheme.C_TEXT_MUTED, true)
	_trans_chapter.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_trans_chapter)

	_trans_title    = _label("Binary Search", 64, UITheme.C_WHITE, true)
	_trans_title.horizontal_alignment    = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_trans_title)

	_trans_subtitle = _label("", 24, UITheme.C_TEXT_MUTED, false)
	_trans_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_trans_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_trans_subtitle)


# ============================================================
# INPUT
# ============================================================

func _visible_choice_count() -> int:
	var count := 0
	for btn in _story_choice_btns:
		if btn.visible:
			count += 1
	return count

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_ENTER:
				if _story_overlay.visible:
					if _quiz_active:
						if _quiz_answered:
							_on_quiz_next_pressed()
					elif is_choice_active:
						if _visible_choice_count() <= 1:
							_close_story_panel()
							_emit("FIRST")
						else:
							_emit("START")
					else:
						_close_story_panel()
						_emit("START")
				else:
					_on_deck_step_pressed()
					_emit("START")

			KEY_B:
				toggle_handbook()

			KEY_P:
				toggle_play()

			KEY_RIGHT:
				_on_deck_step_pressed()

			KEY_1:
				if _story_overlay.visible:
					if _quiz_active:
						if not _quiz_answered:
							_handle_quiz_selection(0)
					elif is_choice_active:
						_close_story_panel()
						_emit("FIRST")
					else:
						_close_story_panel()
						_emit("START")

			KEY_2:
				if _story_overlay.visible:
					if _quiz_active:
						if not _quiz_answered and _visible_choice_count() >= 2:
							_handle_quiz_selection(1)
					elif is_choice_active and _visible_choice_count() >= 2:
						_close_story_panel()
						_emit("MIDDLE")

			KEY_3:
				if _story_overlay.visible:
					if _quiz_active:
						if not _quiz_answered and _visible_choice_count() >= 3:
							_handle_quiz_selection(2)
					elif is_choice_active and _visible_choice_count() >= 3:
						_close_story_panel()
						_emit("LAST")

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_free := (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED)
		if _story_overlay.visible and mouse_free:
			if _quiz_active:
				pass
			elif not is_choice_active:
				_close_story_panel()
				_emit("START")
			elif _visible_choice_count() <= 1:
				_close_story_panel()
				_emit("FIRST")


func _on_quiz_button_pressed(idx: int):
	if _quiz_active:
		_handle_quiz_selection(idx)
	else:
		var actions := ["FIRST", "MIDDLE", "LAST"]
		_close_story_panel()
		_emit(actions[idx])

func _handle_quiz_selection(chosen_idx: int):
	if not _quiz_active or _quiz_answered:
		return
	_quiz_answered = true
	var correct_idx: int = _current_quiz_q.get("correct", -1)
	var is_correct: bool = (chosen_idx == correct_idx)

	var am = get_tree().root.get_node_or_null("AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx("correct" if is_correct else "error")

	var btn: Button = _story_choice_btns[chosen_idx]
	var opts: Array = _current_quiz_q.get("opts", [])
	var opt_text: String = opts[chosen_idx] if chosen_idx < opts.size() else ""

	if is_correct:
		btn.add_theme_stylebox_override("normal", UITheme.button_correct_style(12))
		btn.text = "✓ [ %d ]   %s" % [chosen_idx + 1, opt_text]
		for i in range(_story_choice_btns.size()):
			if i != chosen_idx:
				_story_choice_btns[i].modulate = Color(0.6, 0.6, 0.6, 0.45)
				_story_choice_btns[i].disabled = true

		_story_feedback_badge.text = "🎉  EXCELLENT! THAT'S CORRECT!"
		_story_feedback_badge.add_theme_color_override("font_color", UITheme.C_GREEN)
		_story_feedback_body.text = _current_quiz_q.get("explain", "Great job!")
		_story_feedback_card.add_theme_stylebox_override("panel",
			UITheme.explanation_box(UITheme.C_GREEN, Color(0.03, 0.12, 0.06, 0.95)))
		_story_feedback_retry_btn.visible = false
		_story_feedback_next_btn.visible = true
		_story_feedback_next_btn.text = "Next Question → (SPACE)"
		_story_hint.text = "Press SPACE or click Next to advance"
		_pulse_panel(UITheme.C_GREEN)
		_animate_feedback_card_in()
	else:
		btn.add_theme_stylebox_override("normal", UITheme.button_wrong_style(12))
		btn.text = "✗ [ %d ]   %s" % [chosen_idx + 1, opt_text]
		_shake_node(btn)

		_story_feedback_badge.text = "⚠️  NOT QUITE! HERE'S WHY:"
		_story_feedback_badge.add_theme_color_override("font_color", UITheme.C_YELLOW)
		_story_feedback_body.text = _current_quiz_q.get("explain", "Review the concept carefully.")
		_story_feedback_card.add_theme_stylebox_override("panel",
			UITheme.explanation_box(UITheme.C_RED, Color(0.14, 0.04, 0.04, 0.95)))
		_story_feedback_retry_btn.visible = true
		_story_feedback_next_btn.visible = true
		_story_feedback_next_btn.text = "Got It, Next → (SPACE)"
		_story_hint.text = "Choose ↺ Try Again to select another option, or press SPACE to advance"
		_animate_feedback_card_in()

func _on_quiz_retry_pressed():
	_quiz_answered = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	var t := _current_theme
	var opts: Array = _current_quiz_q.get("opts", [])
	for i in range(_story_choice_btns.size()):
		var b := _story_choice_btns[i]
		if i < opts.size():
			b.disabled = false
			b.modulate = Color(1.0, 1.0, 1.0, 1.0)
			b.text = "[ %d ]   %s" % [i + 1, str(opts[i])]
			b.add_theme_stylebox_override("normal",
				UITheme.button_style(Color(0.08, 0.14, 0.28, 0.85), t.border, 2, 12))
	_story_hint.text = "Press  [ 1 ]  [ 2 ]  [ 3 ]  or click an option"

func _on_quiz_next_pressed():
	_quiz_active = false
	_quiz_answered = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_close_story_panel()
	_emit("QUIZ_NEXT")

func _format_quiz_dots(cur_idx: int, total: int) -> String:
	var dots := ""
	for i in range(total):
		if i < cur_idx:
			dots += "● "
		elif i == cur_idx:
			dots += "◉ "
		else:
			dots += "○ "
	return dots.strip_edges()

func _animate_feedback_card_in():
	if _story_feedback_card == null: return
	_story_feedback_card.visible = true
	_story_feedback_card.modulate = Color(1, 1, 1, 0)
	var t := create_tween()
	t.tween_property(_story_feedback_card, "modulate", Color(1, 1, 1, 1), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _shake_node(node: Control):
	if node == null: return
	var orig_pos := node.position
	var t := create_tween()
	for _i in range(5):
		t.tween_property(node, "position",
			orig_pos + Vector2(randf_range(-7, 7), 0), 0.03)
	t.tween_property(node, "position", orig_pos, 0.04)

func _close_story_panel():
	_story_overlay.visible = false
	is_choice_active = false
	_quiz_active = false
	_quiz_answered = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_recapture_mouse()

func _emit(action: String):
	if is_inside_tree() and get_tree() != null:
		var managers = get_tree().get_nodes_in_group("lesson_manager")
		for m in managers:
			if m.has_method("handle_action"):
				m.handle_action(action)


# ============================================================
# PUBLIC API  ─  called by lessons
# ============================================================

## Apply a complete visual theme (e.g. "binary_search")
func apply_theme(theme_key: String):
	_current_theme = UITheme.for_algo(theme_key)
	_retheme_all()

## Re-skin all panels with the current theme
func _retheme_all():
	var t := _current_theme
	# HUD
	_hud_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 16))
	_hud_icon.text = t.icon
	_hud_icon.add_theme_color_override("font_color", t.accent)
	_hud_topic.add_theme_color_override("font_color", t.accent)
	_hud_chapter.text = t.chapter.to_upper()
	_hud_chapter.add_theme_color_override("font_color", UITheme.C_TEXT_MUTED)
	_hud_objective.add_theme_color_override("font_color", UITheme.C_TEXT_MAIN)
	# Action bar
	_bar_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 14))
	_bar_step.add_theme_color_override("font_color", t.accent)
	_bar_hint.add_theme_color_override("font_color", UITheme.C_TEXT_MUTED)
	# Story panel
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 20))
	_story_title.add_theme_color_override("font_color", t.accent)
	_story_body.add_theme_color_override("font_color", UITheme.C_TEXT_MAIN)
	_story_stats.add_theme_color_override("font_color", t.accent)
	# Quiz buttons
	for btn in _story_choice_btns:
		btn.add_theme_stylebox_override("normal",
			UITheme.button_style(Color(0.08, 0.14, 0.28, 0.85), t.border, 2, 12))
		btn.add_theme_stylebox_override("hover",
			UITheme.button_hover_style(t.accent, 12))
	# Rebuild CODA avatar in new color
	if _coda_body:
		_coda_body.queue_free()
	_coda_body = _build_coda_avatar(t.coda_color)
	if _story_header_row:
		_story_header_row.add_child(_coda_body)
		_story_header_row.move_child(_coda_body, 0)
	# Retheme deck & handbook
	if _deck_container:
		_deck_container.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 14))
	if _handbook_panel:
		_handbook_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 18))
	if _array_ribbon_container:
		_array_ribbon_container.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 14))
	# Rebuild progress strip
	_update_progress_pills()

## Update which chapter pill is active
func _update_progress_pills():
	var chapter_map := {
		"linear_search": 0,
		"binary_search": 1,
		"bubble_sort":   2
	}
	for key in chapter_map:
		if _current_theme == UITheme.for_algo(key):
			_current_chapter_index = chapter_map[key]
			break

func set_lesson(text: String):
	_hud_topic.text = text
	hide_hub()

func set_objective(text: String):
	var clean_text = text.trim_prefix("→ ").trim_prefix("→  ")
	if clean_text.begins_with("Objective:"):
		_hud_objective.text = clean_text
	else:
		_hud_objective.text = "Objective: " + clean_text

func set_target(value):
	target_value = int(value)
	if _hud_target_container:
		var header = _hud_target_container.find_child("TARGET", true, false)
		if header and header is Label:
			header.text = "TARGET"
		_hud_target_container.visible = true
	_hud_target_lbl.text = str(target_value)
	_hud_target_lbl.add_theme_color_override("font_color", UITheme.C_GREEN)

func set_sorting_pass(pass_num: int):
	if _hud_target_container:
		var header = _hud_target_container.find_child("TARGET", true, false)
		if header and header is Label:
			header.text = "PASS"
		_hud_target_container.visible = true
	_hud_target_lbl.text = str(pass_num)
	_hud_target_lbl.add_theme_color_override("font_color", UITheme.C_AMBER)

func hide_target():
	if _hud_target_container:
		_hud_target_container.visible = false

func set_hint(text: String):
	_bar_hint.text = "👉  " + text

func set_step(text: String):
	_bar_step.text = text

## Show a live formula in the action bar (Binary Search)
func set_formula(text: String):
	_bar_formula.text = text
	_bar_formula.visible = text.length() > 0

func hide_formula():
	_bar_formula.visible = false

func _get_array_system() -> Node:
	if is_inside_tree() and get_tree() != null:
		var arr = get_tree().get_first_node_in_group("array_system")
		if arr != null:
			return arr
		var lm = get_tree().get_first_node_in_group("lesson_manager")
		if lm != null and lm.get("array_system") != null:
			return lm.array_system
	return null

func _update_3d_question(title_text: String, options: Array):
	var arr = _get_array_system()
	if arr and arr.has_method("show_3d_question"):
		var title_hdr = "✦ " + _current_theme.name.to_upper() + " ✦"
		arr.show_3d_question(title_hdr, title_text, options, _current_theme.accent)

func _clear_3d_question():
	var arr = _get_array_system()
	if arr and arr.has_method("hide_3d_question"):
		arr.hide_3d_question()

## Close the story panel — call this instead of modal_overlay.visible = false
func hide_panel():
	_story_overlay.visible  = false
	is_choice_active        = false
	_quiz_active            = false
	_quiz_answered          = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	if _story_code_panel:
		_story_code_panel.visible = false
	_clear_3d_question()
	_recapture_mouse()

func panel_is_open() -> bool:
	return _story_overlay != null and _story_overlay.visible

## Release mouse for UI interaction (quiz buttons, etc.)
func _release_mouse_for_ui():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Re-capture mouse for 3D gameplay
func _recapture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ─── Story / CODA dialogue ───────────────────────────────────

func show_lesson_message(text: Variant):
	var t := _current_theme
	is_choice_active = false
	_quiz_active = false
	_quiz_answered = false
	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_story_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 16))
	_story_chapter_badge.text = t.chapter.to_upper() + "  •  " + t.name.to_upper()
	_story_chapter_badge.add_theme_color_override("font_color", t.accent)
	_story_title.text = "CODA says:"
	_story_title.add_theme_color_override("font_color", t.accent)
	_story_body.text  = str(text)
	_story_stats.text = ""
	_story_choice_container.visible = false
	_story_hint.text = "SPACE or click to continue"
	_update_3d_question(str(text), ["Continue (SPACE)"])

func show_choice_message(title_text: String, options: Array):
	var t := _current_theme
	is_choice_active = true
	_quiz_active = false
	_quiz_answered = false
	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_story_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 16))
	_story_chapter_badge.text = t.chapter.to_upper() + "  •  " + t.name.to_upper()
	_story_chapter_badge.add_theme_color_override("font_color", t.accent)
	_story_title.text = title_text
	_story_title.add_theme_color_override("font_color", t.accent)
	_story_body.text  = ""
	_story_stats.text = ""
	_story_choice_container.visible = true
	_story_hint.text = "Press  [ 1 ]  [ 2 ]  [ 3 ]  or click a button"

	for i in range(_story_choice_btns.size()):
		var btn := _story_choice_btns[i]
		if i < options.size():
			btn.text = "[ %d ]   %s" % [i + 1, str(options[i])]
			btn.visible = true
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			btn.add_theme_stylebox_override("normal",
				UITheme.button_style(Color(0.08, 0.14, 0.28, 0.85), t.border, 2, 12))
			btn.add_theme_stylebox_override("hover",
				UITheme.button_hover_style(t.accent, 12))
		else:
			btn.visible = false

	_update_3d_question(title_text, options)

## Show dedicated animated quiz question with in-place feedback and next progression
func show_quiz_question(q_data: Dictionary, current_index: int, total_count: int):
	var t := _current_theme
	_quiz_active = true
	_quiz_answered = false
	_current_quiz_q = q_data
	_current_quiz_idx = current_index
	_current_quiz_total = total_count
	is_choice_active = true

	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false

	_story_overlay.color = UITheme.C_BLACK_SCRIM
	_story_overlay.visible = true
	_release_mouse_for_ui()

	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(t.accent, 16))
	_story_chapter_badge.text = "%s  •  QUESTION %d OF %d" % [t.chapter.to_upper(), current_index + 1, total_count]
	_story_chapter_badge.add_theme_color_override("font_color", t.accent)
	_story_title.text = "Knowledge Check"
	_story_title.add_theme_color_override("font_color", t.accent)
	_story_body.text  = q_data.get("q", "")
	_story_stats.text = _format_quiz_dots(current_index, total_count)
	_story_stats.add_theme_color_override("font_color", t.accent)

	_story_choice_container.visible = true
	_story_hint.text = "Press  [ 1 ]  [ 2 ]  [ 3 ]  or click an option"

	var opts: Array = q_data.get("opts", [])
	for i in range(_story_choice_btns.size()):
		var btn := _story_choice_btns[i]
		if i < opts.size():
			btn.text = "[ %d ]   %s" % [i + 1, str(opts[i])]
			btn.visible = true
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			btn.add_theme_stylebox_override("normal",
				UITheme.button_style(Color(0.08, 0.14, 0.28, 0.85), t.border, 2, 12))
			btn.add_theme_stylebox_override("hover",
				UITheme.button_hover_style(t.accent, 12))
		else:
			btn.visible = false

	_update_3d_question(q_data.get("q", ""), opts)

## Show dedicated C code step with code highlight box and pulse animation
func show_c_code_step(title_text: String, c_code: String, explanation_text: String, next_label: String = "Next →"):
	var t := _current_theme
	is_choice_active = true
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.styled_box(t.bg_dark, t.border, 3, 20))
	_story_chapter_badge.text = t.chapter.to_upper() + "  •  " + t.name.to_upper()
	_story_chapter_badge.add_theme_color_override("font_color", t.accent)
	_story_title.text = title_text
	_story_title.add_theme_color_override("font_color", t.accent)
	_story_body.text  = explanation_text
	_story_stats.text = ""

	_format_and_display_code(c_code)
	_story_code_panel.visible = true
	_pulse_code_panel(t.accent)

	_story_choice_container.visible = true
	_story_hint.text = "Press  [ 1 ]  or  SPACE  or click below to continue"

	for i in range(_story_choice_btns.size()):
		var btn := _story_choice_btns[i]
		if i == 0:
			btn.text = "[ 1 ]   %s   (or press SPACE)" % next_label
			btn.visible = true
		else:
			btn.visible = false

func _format_and_display_code(c_code: String):
	var lines := c_code.split("\n")
	var formatted := ""

	for raw_line in lines:
		var line := raw_line
		var is_highlighted := false
		if line.strip_edges().begins_with(">"):
			is_highlighted = true
			line = line.replace(">", "")

		if is_highlighted:
			formatted += "[color=#55ffaa][b]▶ %s[/b][/color]\n" % line
		elif line.strip_edges().begins_with("//"):
			formatted += "[color=#7090b0][i]  %s[/i][/color]\n" % line
		else:
			formatted += "[color=#d8e8f8]  %s[/color]\n" % line

	_story_code_lbl.text = formatted

func _pulse_code_panel(color: Color):
	if _story_code_panel == null: return
	var t := create_tween()
	_story_code_panel.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.02, 0.04, 0.08, 0.96), color, 2, 12))
	t.tween_interval(0.35)
	t.tween_callback(func():
		if _story_code_panel and _story_overlay and _story_overlay.visible:
			_story_code_panel.add_theme_stylebox_override("panel",
				UITheme.styled_box(Color(0.03, 0.05, 0.10, 0.96), _current_theme.border.darkened(0.2), 1, 12))
	)

func show_choice_feedback(text: String):
	is_choice_active = false
	_quiz_active = false
	_quiz_answered = false
	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(_current_theme.accent, 20))
	_story_title.text = "⚠️  Not quite!"
	_story_title.add_theme_color_override("font_color", UITheme.C_YELLOW)
	_story_body.text  = str(text)
	_story_stats.text = ""
	_story_choice_container.visible = false
	_story_hint.text = "Think again — press SPACE to retry"
	_shake_panel()

func show_success_message(target, index, comparisons):
	is_choice_active = false
	_quiz_active = false
	_quiz_answered = false
	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(_current_theme.accent, 20))
	_story_title.text = "🎉  Found it!"
	_story_title.add_theme_color_override("font_color", UITheme.C_GREEN)
	_story_body.text  = "CODA: \"File #%s located at shelf %s! It took me just %s checks.\"\n\nPress SPACE to continue to the next chapter." % [str(target), str(index), str(comparisons)]
	_story_stats.text = "Index %s  |  %s comparison%s" % [str(index), str(comparisons), ("s" if int(comparisons) != 1 else "")]
	_story_stats.add_theme_color_override("font_color", UITheme.C_GREEN)
	_story_choice_container.visible = false
	_story_hint.text = "SPACE to continue"
	_pulse_panel(UITheme.C_GREEN)

func show_failure_message(target, comparisons):
	is_choice_active = false
	_quiz_active = false
	_quiz_answered = false
	if _story_code_panel:
		_story_code_panel.visible = false
	if _story_feedback_card:
		_story_feedback_card.visible = false
	_story_overlay.visible = true
	_release_mouse_for_ui()
	_story_panel.add_theme_stylebox_override("panel", UITheme.glass_card(_current_theme.accent, 20))
	_story_title.text = "🔍  Not here!"
	_story_title.add_theme_color_override("font_color", UITheme.C_RED)
	_story_body.text  = "CODA: \"I checked every single shelf — File #%s just isn't in this archive. That's %s checks wasted! Next time we need a smarter approach...\"" % [str(target), str(comparisons)]
	_story_stats.text = "Total checks: %s" % str(comparisons)
	_story_stats.add_theme_color_override("font_color", UITheme.C_RED)
	_story_choice_container.visible = false
	_story_hint.text = "SPACE to continue"

## Show a full-screen dramatic chapter transition.
## Emits chapter_transition_finished when the animation is done.
signal chapter_transition_finished

func show_chapter_transition(chapter: String, title: String, subtitle: String, color: Color):
	_trans_overlay.visible = true
	_trans_chapter.text = chapter.to_upper()
	_trans_chapter.add_theme_color_override("font_color", color.lightened(0.4))
	_trans_title.text = title
	_trans_title.add_theme_color_override("font_color", color)
	_trans_subtitle.text = subtitle

	var t := create_tween()
	t.tween_property(_trans_overlay, "color", Color(0, 0, 0, 0.92), 0.4)
	t.tween_interval(2.2)
	t.tween_property(_trans_overlay, "color", Color(0, 0, 0, 0.0), 0.5)
	t.tween_callback(func():
		_trans_overlay.visible = false
		chapter_transition_finished.emit()
	)


## Update the comparison step in the action bar
func update_comparison(index, value, target, comparisons):
	var is_match := int(value) == int(target)
	_bar_step.text = "Checking Index %d  →  value = %s" % [int(index), str(value)]
	if is_match:
		_bar_step.add_theme_color_override("font_color", UITheme.C_GREEN)
		_bar_hint.text = "✓ Match found!"
	else:
		_bar_step.add_theme_color_override("font_color", _current_theme.accent)
		_bar_hint.text = "%s ≠ %s  →  moving on..." % [str(value), str(target)]

func set_active_index(index):
	_bar_step.text = "Checking Index %d..." % int(index)
	_bar_step.add_theme_color_override("font_color", _current_theme.accent)

# ─── Animations ──────────────────────────────────────────────
func _shake_panel():
	var origin := _story_panel.position
	var t := create_tween()
	for _i in range(5):
		t.tween_property(_story_panel, "position",
			origin + Vector2(randf_range(-8, 8), randf_range(-4, 4)), 0.04)
	t.tween_property(_story_panel, "position", origin, 0.05)

func _pulse_panel(color: Color):
	var orig := _story_panel.get_theme_stylebox("panel")
	var t := create_tween()
	t.tween_callback(func():
		_story_panel.add_theme_stylebox_override("panel",
			UITheme.styled_box(_current_theme.bg_dark, color, 4, 20))
	)
	t.tween_interval(0.5)
	t.tween_callback(func():
		_story_panel.add_theme_stylebox_override("panel",
			UITheme.styled_box(_current_theme.bg_dark, _current_theme.border, 3, 20))
	)

# ─── Helpers ─────────────────────────────────────────────────
func _label(txt: String, size: int, col: Color, bold: bool) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_font_override("font", _bold_font if bold else _regular_font)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 3)
	return l

func _label_into(parent: Node, txt: String, size: int, col: Color, bold: bool) -> Label:
	var l := _label(txt, size, col, bold)
	parent.add_child(l)
	return l

func _margin(parent: Node, v: int, h: int) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_top",    v)
	m.add_theme_constant_override("margin_bottom", v)
	m.add_theme_constant_override("margin_left",   h)
	m.add_theme_constant_override("margin_right",  h)
	parent.add_child(m)
	return m

# ─── Hub Implementation ──────────────────────────────────────
func _build_hub_screen(root: Control):
	_hub_overlay = ColorRect.new()
	_hub_overlay.name = "HubOverlay"
	_hub_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hub_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_hub_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Background doesn't eat clicks
	_hub_overlay.visible = false
	root.add_child(_hub_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Pass through to children (buttons)
	_hub_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(980, 580)
	panel.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.02, 0.05, 0.12, 0.96), Color(0.0, 0.85, 1.0, 1.0), 3, 24))
	center.add_child(panel)

	var m := _margin(panel, 28, 36)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	m.add_child(col)

	# Title Banner
	var top_row := HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 12)
	col.add_child(top_row)

	var title_lbl := _label("✦ THE QUANTUM ARCHIVE ✦", 32, Color(0.0, 0.95, 1.0), true)
	top_row.add_child(title_lbl)

	var subtitle := _label("NEXUS COMMAND CENTER • CHOOSE AN ALGORITHMIC PROTOCOL TO RESTORE", 13, UITheme.C_TEXT_MUTED, true)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(subtitle)

	# Lore briefing
	var lore_box := PanelContainer.new()
	lore_box.add_theme_stylebox_override("panel",
		UITheme.styled_box(Color(0.04, 0.08, 0.18, 0.8), Color(0.0, 0.6, 0.8, 0.5), 1, 14))
	col.add_child(lore_box)
	var lm := _margin(lore_box, 12, 18)
	var lore_text := _label(
		"CODA: \"Welcome, Architect! The planetary memory cores have suffered timeline entropy.\n"
		+ "Select a recovery protocol below, or walk up to a physical warp pedestal in the atrium to begin!\"",
		15, UITheme.C_TEXT_MAIN, false
	)
	lore_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lm.add_child(lore_text)

	# 3 Topic Cards
	var cards_row := HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 20)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(cards_row)

	var sectors := [
		{
			"id": 0,
			"icon": "🔍",
			"title": "SECTOR 01\nLINEAR SEARCH",
			"complexity": "O(n) Complexity",
			"color": Color(0.0, 0.85, 1.0),
			"desc": "Sequential Memory Scan\nChecks nodes one by one until the target frequency matches."
		},
		{
			"id": 1,
			"icon": "⚡",
			"title": "SECTOR 02\nBINARY SEARCH",
			"complexity": "O(log n) Complexity",
			"color": Color(0.7, 0.3, 1.0),
			"desc": "Bifurcation Matrix\nHalves sorted memory on each cycle to locate high-density target."
		},
		{
			"id": 2,
			"icon": "🔄",
			"title": "SECTOR 03\nBUBBLE SORT",
			"complexity": "O(n²) Complexity",
			"color": Color(1.0, 0.65, 0.0),
			"desc": "Entropy Stabilization\nCompares and swaps adjacent nodes until equilibrium is reached."
		}
	]

	for s in sectors:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(280, 240)
		card.add_theme_stylebox_override("panel",
			UITheme.styled_box(Color(0.03, 0.06, 0.14, 0.9), s["color"], 2, 18))
		cards_row.add_child(card)

		var cm := _margin(card, 16, 18)
		var ccol := VBoxContainer.new()
		ccol.add_theme_constant_override("separation", 8)
		cm.add_child(ccol)

		var c_icon := _label(s["icon"], 32, s["color"], true)
		c_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ccol.add_child(c_icon)

		var c_title := _label(s["title"], 18, Color(1, 1, 1), true)
		c_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ccol.add_child(c_title)

		var c_comp := _label(s["complexity"], 12, s["color"], true)
		c_comp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ccol.add_child(c_comp)

		var c_desc := _label(s["desc"], 12, UITheme.C_TEXT_MUTED, false)
		c_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		c_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ccol.add_child(c_desc)

		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ccol.add_child(spacer)

		var btn := Button.new()
		btn.text = "✦ ENGAGE PROTOCOL ✦"
		btn.add_theme_font_override("font", _bold_font)
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_stylebox_override("normal", UITheme.button_style(s["color"].darkened(0.5), s["color"], 2, 10))
		btn.add_theme_stylebox_override("hover",  UITheme.button_style(s["color"], Color(1, 1, 1), 2, 10))
		btn.add_theme_stylebox_override("pressed",UITheme.button_style(s["color"].lightened(0.3), Color(1, 1, 1), 3, 10))
		var sec_id: int = s["id"]
		btn.pressed.connect(func(): _on_sector_selected(sec_id))
		ccol.add_child(btn)

	# Bottom Shortcut Bar
	var hint_row := HBoxContainer.new()
	hint_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hint_row.add_theme_constant_override("separation", 24)
	col.add_child(hint_row)

	var shortcuts := _label("HOTKEYS: [1] Linear Search   •   [2] Binary Search   •   [3] Bubble Sort   •   [H] Hub", 13, Color(0.5, 0.75, 0.9), false)
	hint_row.add_child(shortcuts)

func _on_hub_btn_pressed():
	return_to_hub_requested.emit()
	if is_inside_tree() and get_tree() != null:
		var lm = get_tree().get_first_node_in_group("lesson_manager")
		if lm != null and lm.has_method("return_to_hub"):
			lm.return_to_hub()

func _on_sector_selected(index: int):
	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("play_warp_sound"):
		audio.play_warp_sound()
	hub_topic_selected.emit(index)
	if is_inside_tree() and get_tree() != null:
		var lm = get_tree().get_first_node_in_group("lesson_manager")
		if lm != null and lm.has_method("launch_lesson"):
			lm.launch_lesson(index)

func show_hub():
	if _hub_overlay != null:
		_hub_overlay.visible = false
	if _story_overlay != null:
		_story_overlay.visible = false
	if _bar_panel != null:
		_bar_panel.visible = false
	if _prog_strip_container != null:
		_prog_strip_container.visible = false
	if _deck_container != null:
		_deck_container.visible = false
	if _handbook_panel != null:
		_handbook_panel.visible = false
	if _array_ribbon_container != null:
		_array_ribbon_container.visible = false
	if _hud_panel != null:
		_hud_panel.visible = true
	if _hud_chapter:
		_hud_chapter.text = "CENTRAL HUB"
	if _hud_topic:
		_hud_topic.text = "Select Algorithm"
	if _hud_icon:
		_hud_icon.text = "🏛️"
	if _hud_objective:
		_hud_objective.text = "Aim Crosshair & Click a Pedestal • [1] [2] [3]"
	if _hud_target_container:
		_hud_target_container.visible = false
	if _hud_shortcuts_row:
		_hud_shortcuts_row.visible = false
	if _hub_btn:
		_hub_btn.visible = false
	if _hud_status_badge:
		_hud_status_badge.text = "HUB"

func hide_hub():
	if _hub_overlay != null:
		_hub_overlay.visible = false
	if _bar_panel != null:
		_bar_panel.visible = true
	if _prog_strip_container != null:
		_prog_strip_container.visible = true
	if _deck_container != null:
		_deck_container.visible = true
	if _array_ribbon_container != null:
		_array_ribbon_container.visible = true
	if _hud_panel != null:
		_hud_panel.visible = true
	if _hud_target_container:
		_hud_target_container.visible = true
	if _hud_shortcuts_row:
		_hud_shortcuts_row.visible = false
	if _hub_btn:
		_hub_btn.visible = true
	if _hud_status_badge:
		_hud_status_badge.text = "ACTIVE"
		_hud_status_badge.add_theme_color_override("font_color", Color(0.2, 0.96, 0.5))
