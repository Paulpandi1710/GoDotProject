extends Control
class_name UIManager

# ============================================================
# UI MANAGER — Engine 2, Automation Foundry
# Builds all UI panels entirely in code.
# Now perfectly locked to 1920x1080 for the 3D Monitor!
# ============================================================

var screen_size: Vector2
var ui_scale: float = 1.0
var base_size: Vector2 = Vector2(1920.0, 1080.0)

var terminal_panel: Panel
var code_edit: CodeEdit
var compile_btn: Button
var output_label: RichTextLabel
var hint_btn: Button

var status_hud: Panel
var stage_label: Label
var laser_status: Label
var alarm_label: Label

var intro_panel: Panel
var story_label: RichTextLabel
var start_btn: Button

const C_BG_DARK     := Color(0.04, 0.06, 0.04, 0.95)
const C_BG_MID      := Color(0.06, 0.10, 0.07, 0.90)
const C_ACCENT      := Color(0.0,  0.85, 0.4,  1.0)
const C_WARN        := Color(1.0,  0.55, 0.0,  1.0)
const C_DANGER      := Color(1.0,  0.15, 0.05, 1.0)
const C_TEXT        := Color(0.85, 1.0,  0.85, 1.0)
const C_MUTED       := Color(0.45, 0.65, 0.45, 1.0)
const C_BORDER      := Color(0.0,  0.7,  0.3,  0.6)

var _built: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if _built:
		return
	build_all()

func build_all() -> void:
	if _built:
		return
	_built = true
	
	# 1. FIXED SCALING: Hardcode scale to 1.0 so it maps perfectly to the 3D screen
	ui_scale = 1.0
	screen_size = base_size
	
	# 2. FIXED BLACK SCREEN: Add a solid screen background so transparency doesn't break rendering
	var screen_bg := ColorRect.new()
	screen_bg.color = Color(0.01, 0.02, 0.01) # Very dark screen glass
	screen_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(screen_bg)
	
	_build_intro_panel()
	_build_terminal_panel()
	_build_status_hud()
	_connect_tab_navigation()


func _s(value: float) -> float: return value * ui_scale
func _sv(vec: Vector2) -> Vector2: return vec * ui_scale

func _make_panel(bg_color: Color, border_color: Color) -> Panel:
	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(int(_s(2.0)))
	style.corner_radius_top_left = int(_s(6.0))
	style.corner_radius_top_right = int(_s(6.0))
	style.corner_radius_bottom_left = int(_s(6.0))
	style.corner_radius_bottom_right = int(_s(6.0))
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_label(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", int(_s(font_size)))
	return label

func _make_rich_label() -> RichTextLabel:
	var lbl := RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.add_theme_color_override("default_color", C_TEXT)
	lbl.add_theme_font_size_override("normal_font_size", int(_s(14.0)))
	lbl.add_theme_font_size_override("bold_font_size", int(_s(15.0)))
	lbl.scroll_following = true
	return lbl

func _make_button(text: String, bg: Color, text_color: Color, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.set_border_width_all(int(_s(2.0)))
	normal.border_color = C_BORDER
	normal.corner_radius_top_left = int(_s(4.0))
	normal.corner_radius_top_right = int(_s(4.0))
	normal.corner_radius_bottom_left = int(_s(4.0))
	normal.corner_radius_bottom_right = int(_s(4.0))
	
	var hover := StyleBoxFlat.new()
	hover.bg_color = bg.lightened(0.15)
	hover.set_border_width_all(int(_s(2.0)))
	hover.border_color = C_ACCENT
	hover.corner_radius_top_left = int(_s(4.0))
	hover.corner_radius_top_right = int(_s(4.0))
	hover.corner_radius_bottom_left = int(_s(4.0))
	hover.corner_radius_bottom_right = int(_s(4.0))
	
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = bg.darkened(0.2)
	pressed_style.set_border_width_all(int(_s(2.0)))
	pressed_style.border_color = C_ACCENT
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_color_override("font_color", text_color)
	btn.add_theme_font_size_override("font_size", int(_s(font_size)))
	return btn

# ── INTRO PANEL ────────────────────────────────────────────
func _build_intro_panel() -> void:
	intro_panel = _make_panel(Color(0.03, 0.05, 0.03, 0.97), C_ACCENT)
	intro_panel.set_anchors_preset(Control.PRESET_CENTER)
	intro_panel.custom_minimum_size = _sv(Vector2(850, 560))
	intro_panel.position = _sv(Vector2(535, 260))
	add_child(intro_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", int(_s(16.0)))
	intro_panel.add_child(vbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(_s(32.0)))
	margin.add_theme_constant_override("margin_right", int(_s(32.0)))
	margin.add_theme_constant_override("margin_top", int(_s(24.0)))
	margin.add_theme_constant_override("margin_bottom", int(_s(24.0)))
	vbox.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", int(_s(14.0)))
	margin.add_child(inner)

	var header := _make_label("⚙ ENGINE 2 (Unit 3: Iteration) — The Automation Foundry", C_ACCENT, 20)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(header)

	var sep := HSeparator.new()
	inner.add_child(sep)

	story_label = _make_rich_label()
	story_label.custom_minimum_size = _sv(Vector2(0, 340))
	story_label.append_text("""[color=#ffdd44][b]THE STORY:[/b][/color]
The physical doors are too heavy to open manually; you must restore the automated assembly lines to progress deeper into the facility.

[color=#aaffcc][b]THE ENVIRONMENT:[/b][/color]
A vast, multi-level factory floor with inactive conveyor belts, giant robotic arms, and a massive vault door locked by a multi-tier laser grid. The C-terminal overlooks the heavy machinery that only responds to continuous, looping power signals.

[color=#ff8844][b]THE MECHANICS:[/b][/color]
You must write [b]for[/b] and [b]while[/b] loops. The machinery reacts in real-time to your loops.
► Correctly code a loop to generate Prime Numbers, and the laser grid sequentially shuts down, layer by layer, matching your loop iterations!

[color=#ff4444][b]⚠ WARNING:[/b][/color] If you write an [b]infinite loop[/b] by mistake, the robotic arms spin out of control, sparks fly, and the room goes into lockdown.

[color=#888888]CONTROLS:  [ENTER] = Start  |  [Ctrl+Enter] = Compile  |  [WASD] = Move Camera[/color]
""")
	inner.add_child(story_label)

	start_btn = _make_button("► INITIALIZE THE FOUNDRY  [ Press ENTER ]", Color(0.05, 0.3, 0.15), C_ACCENT, 18)
	start_btn.custom_minimum_size = _sv(Vector2(0, 50))
	inner.add_child(start_btn)

# ── TERMINAL PANEL ─────────────────────────────────────────
func _build_terminal_panel() -> void:
	terminal_panel = _make_panel(C_BG_DARK, C_BORDER)
	terminal_panel.anchor_left   = 0.0
	terminal_panel.anchor_top    = 0.0
	terminal_panel.anchor_right  = 0.45
	terminal_panel.anchor_bottom = 1.0
	terminal_panel.offset_left   = _s(12.0)
	terminal_panel.offset_top    = _s(12.0)
	terminal_panel.offset_right  = _s(-12.0)
	terminal_panel.offset_bottom = _s(-12.0)
	terminal_panel.visible = false
	add_child(terminal_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", int(_s(8.0)))
	terminal_panel.add_child(vbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(_s(12.0)))
	margin.add_theme_constant_override("margin_right", int(_s(12.0)))
	margin.add_theme_constant_override("margin_top", int(_s(10.0)))
	margin.add_theme_constant_override("margin_bottom", int(_s(10.0)))
	vbox.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", int(_s(8.0)))
	margin.add_child(inner)

	var title_bar := _make_panel(Color(0.0, 0.18, 0.08, 1.0), C_ACCENT)
	title_bar.custom_minimum_size = _sv(Vector2(0, 32))
	inner.add_child(title_bar)

	var title_lbl := _make_label("  C-TERMINAL  |  AUTOMATION FOUNDRY  |  gcc compiler v12.0", C_ACCENT, 12)
	title_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_bar.add_child(title_lbl)

	code_edit = CodeEdit.new()
	code_edit.custom_minimum_size = _sv(Vector2(0, 300))
	code_edit.add_theme_font_size_override("font_size", int(_s(14.0)))
	code_edit.add_theme_color_override("background_color", Color(0.03, 0.07, 0.04))
	code_edit.add_theme_color_override("font_color", Color(0.85, 1.0, 0.85))
	code_edit.add_theme_color_override("font_selected_color", Color.WHITE)
	code_edit.add_theme_color_override("selection_color", Color(0.0, 0.4, 0.2, 0.5))
	code_edit.add_theme_color_override("caret_color", C_ACCENT)
	code_edit.add_theme_constant_override("line_spacing", int(_s(4.0)))
	code_edit.syntax_highlighter = _build_c_syntax_highlighter()
	inner.add_child(code_edit)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", int(_s(10.0)))
	inner.add_child(btn_row)

	compile_btn = _make_button("⚡ COMPILE & EXECUTE  [Ctrl+Enter]", Color(0.05, 0.35, 0.15), C_ACCENT, 15)
	compile_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compile_btn.custom_minimum_size = _sv(Vector2(0, 44))
	btn_row.add_child(compile_btn)

	hint_btn = _make_button("💡 HINT", Color(0.25, 0.18, 0.0), C_WARN, 14)
	hint_btn.custom_minimum_size = _sv(Vector2(90, 44))
	btn_row.add_child(hint_btn)

	var output_title := _make_label("  OUTPUT CONSOLE", C_MUTED, 11)
	inner.add_child(output_title)

	output_label = _make_rich_label()
	output_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_label.add_theme_color_override("default_color", C_TEXT)
	var output_style := StyleBoxFlat.new()
	output_style.bg_color = Color(0.02, 0.04, 0.02)
	output_style.set_border_width_all(1)
	output_style.border_color = Color(0.0, 0.4, 0.2)
	output_label.add_theme_stylebox_override("normal", output_style)
	inner.add_child(output_label)

	var tab_hint := _make_label("  TAB = toggle camera / terminal focus", C_MUTED, 10)
	inner.add_child(tab_hint)

# ── STATUS HUD ─────────────────────────────────────────────
func _build_status_hud() -> void:
	status_hud = _make_panel(Color(0.03, 0.06, 0.03, 0.88), C_BORDER)
	status_hud.anchor_left   = 0.45
	status_hud.anchor_top    = 0.0
	status_hud.anchor_right  = 1.0
	status_hud.anchor_bottom = 0.0
	status_hud.offset_left   = _s(12.0)
	status_hud.offset_top    = _s(12.0)
	status_hud.offset_right  = _s(-12.0)
	status_hud.offset_bottom = _s(110.0)
	status_hud.visible = false
	add_child(status_hud)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", int(_s(20.0)))
	status_hud.add_child(hbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(_s(16.0)))
	margin.add_theme_constant_override("margin_right", int(_s(16.0)))
	margin.add_theme_constant_override("margin_top", int(_s(8.0)))
	margin.add_theme_constant_override("margin_bottom", int(_s(8.0)))
	hbox.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", int(_s(4.0)))
	margin.add_child(inner)

	stage_label = _make_label("STAGE 1 / 4  |  CHALLENGE 1 — Start the Conveyor Belt", C_ACCENT, 14)
	inner.add_child(stage_label)

	laser_status = _make_label("LASER LAYERS ACTIVE: 5 / 5", C_DANGER, 13)
	inner.add_child(laser_status)

	alarm_label = _make_label("⚠ LOCKDOWN — INFINITE LOOP DETECTED ⚠", C_DANGER, 14)
	alarm_label.visible = false
	alarm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(alarm_label)

	var alarm_tween := create_tween().set_loops()
	alarm_tween.tween_property(alarm_label, "modulate:a", 0.2, 0.4)
	alarm_tween.tween_property(alarm_label, "modulate:a", 1.0, 0.4)

func _build_c_syntax_highlighter() -> CodeHighlighter:
	var hl := CodeHighlighter.new()
	var kw_color := Color(0.5, 0.7, 1.0)
	for kw in ["int", "float", "char", "void", "for", "while", "if", "else",
			   "return", "break", "continue", "do", "struct", "include",
			   "printf", "scanf", "main", "switch", "case", "default"]:
		hl.add_keyword_color(kw, kw_color)
	hl.number_color = Color(0.9, 0.6, 0.2)
	hl.add_color_region('"', '"', Color(0.7, 0.9, 0.5))
	hl.add_color_region("//", "", Color(0.4, 0.6, 0.4), true)
	hl.add_color_region("/*", "*/", Color(0.4, 0.6, 0.4))
	hl.add_color_region("#", "", Color(0.8, 0.5, 0.8), true) 
	hl.symbol_color = Color(0.9, 0.9, 0.5)
	return hl

func _connect_tab_navigation() -> void:
	if compile_btn and hint_btn and code_edit:
		compile_btn.focus_neighbor_top = code_edit.get_path()
		hint_btn.focus_neighbor_top = code_edit.get_path()
