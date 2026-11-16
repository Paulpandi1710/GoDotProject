## ============================================================
## SEARCH FEEDBACK — bright world-space lab board (above shelves)
## Primary teaching surface — must read clearly in desktop play.
## ============================================================

extends Node3D
class_name SearchFeedback

var title_label: Label3D
var sub_label: Label3D
var warning_label: Label3D
var background_panel: MeshInstance3D
var border: MeshInstance3D
var glow_light: OmniLight3D
var option_nodes: Array[Node3D] = []

const C_CYAN := Color(0.15, 0.95, 1.0)
const C_AMBER := Color(1.0, 0.88, 0.15)
const C_WHITE := Color(1.0, 1.0, 1.0)
const C_GREEN := Color(0.25, 1.0, 0.5)

func _init():
	_ensure_built()

func _ready():
	_ensure_built()

func _ensure_built():
	if title_label != null:
		return

	background_panel = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(6.4, 2.05, 0.08)
	background_panel.mesh = box
	var bg_mat := StandardMaterial3D.new()
	## Dark plate so amber/cyan text pops (was washed out by bright emission)
	bg_mat.albedo_color = Color(0.01, 0.02, 0.05, 1.0)
	bg_mat.emission_enabled = true
	bg_mat.emission = Color(0.02, 0.06, 0.12)
	bg_mat.emission_energy_multiplier = 0.9
	bg_mat.metallic = 0.05
	bg_mat.roughness = 0.45
	background_panel.material_override = bg_mat
	add_child(background_panel)

	border = MeshInstance3D.new()
	var b_box := BoxMesh.new()
	b_box.size = Vector3(6.6, 2.2, 0.045)
	border.mesh = b_box
	var b_mat := StandardMaterial3D.new()
	b_mat.albedo_color = C_AMBER
	b_mat.emission_enabled = true
	b_mat.emission = C_AMBER
	b_mat.emission_energy_multiplier = 3.2
	border.material_override = b_mat
	border.position = Vector3(0, 0, -0.03)
	add_child(border)

	glow_light = OmniLight3D.new()
	glow_light.light_color = Color(1.0, 0.85, 0.4)
	glow_light.light_energy = 0.85
	glow_light.omni_range = 3.5
	glow_light.position = Vector3(0, 0.15, 0.45)
	add_child(glow_light)

	title_label = Label3D.new()
	title_label.name = "FeedbackTitle"
	title_label.text = "LAB BOARD"
	title_label.font_size = 56
	title_label.modulate = Color(0.35, 1.0, 1.0)
	title_label.outline_size = 24
	title_label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	title_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	title_label.no_depth_test = true
	title_label.render_priority = 30
	title_label.pixel_size = 0.0048
	title_label.position = Vector3(0, 0.58, 0.06)
	add_child(title_label)

	sub_label = Label3D.new()
	sub_label.name = "FeedbackSub"
	sub_label.text = ""
	sub_label.font_size = 96
	sub_label.modulate = C_AMBER
	sub_label.outline_size = 28
	sub_label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	sub_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sub_label.no_depth_test = true
	sub_label.render_priority = 30
	sub_label.pixel_size = 0.0052
	sub_label.position = Vector3(0, 0.0, 0.06)
	add_child(sub_label)

	warning_label = Label3D.new()
	warning_label.name = "FeedbackWarning"
	warning_label.text = ""
	warning_label.font_size = 40
	warning_label.modulate = Color(1.0, 1.0, 1.0)
	warning_label.outline_size = 18
	warning_label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	warning_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	warning_label.no_depth_test = true
	warning_label.render_priority = 30
	warning_label.pixel_size = 0.0040
	warning_label.position = Vector3(0, -0.58, 0.06)
	add_child(warning_label)

func set_prompt(title: String, subtitle: String, color: Color = C_CYAN):
	_ensure_built()
	visible = true
	if title_label:
		title_label.text = title
		title_label.modulate = color
		title_label.font_size = 48
	if sub_label:
		sub_label.text = subtitle
		sub_label.modulate = C_WHITE
		sub_label.font_size = 36
	if warning_label:
		warning_label.text = ""
	_pulse_border(color)

## Big bright compare board — primary teaching surface (not the 2D exam UI)
func show_lab_compare(shelf_value: int, target_value: int, index: int):
	_ensure_built()
	visible = true
	if title_label:
		title_label.text = "COMPARE  •  INDEX %d" % index
		title_label.modulate = C_CYAN
		title_label.font_size = 46
	if sub_label:
		sub_label.text = "%d    ≟    %d" % [shelf_value, target_value]
		sub_label.modulate = C_AMBER
		sub_label.font_size = 100
	if warning_label:
		if shelf_value == target_value:
			warning_label.text = "[1] MATCH     or     [2] KEEP SEARCHING"
		else:
			warning_label.text = "[1] MATCH     or     [2] KEEP SEARCHING"
		warning_label.modulate = Color(1.0, 0.95, 0.55)
	if glow_light:
		glow_light.light_color = C_AMBER
		glow_light.light_energy = 1.1
	_pulse_border(C_AMBER)

func _pulse_border(color: Color):
	if border == null:
		return
	var mat := border.material_override as StandardMaterial3D
	if mat:
		mat.emission = color
		mat.albedo_color = color
		mat.emission_energy_multiplier = 5.0
	if is_inside_tree() and get_tree() != null:
		var tw := create_tween()
		if tw:
			tw.tween_property(self, "scale", Vector3(1.08, 1.08, 1.08), 0.14)
			tw.tween_property(self, "scale", Vector3.ONE, 0.22)

func show_locked_guidance(current_idx: int, clicked_idx: int):
	show_order_lock(current_idx, clicked_idx)

## Bright order lock — used when student tries to skip shelves
func show_order_lock(current_idx: int, clicked_idx: int):
	_ensure_built()
	visible = true
	if title_label:
		title_label.text = "NO SKIPPING  •  LINEAR ORDER"
		title_label.modulate = C_AMBER
		title_label.font_size = 44
	if sub_label:
		sub_label.text = "must check INDEX %d first" % current_idx
		sub_label.modulate = C_WHITE
		sub_label.font_size = 52
	if warning_label:
		if clicked_idx > current_idx:
			warning_label.text = "You clicked %d — that shelf is still LOCKED" % clicked_idx
		else:
			warning_label.text = "Already checked — return to INDEX %d" % current_idx
		warning_label.modulate = C_AMBER
	if glow_light:
		glow_light.light_color = C_AMBER
		glow_light.light_energy = 1.4
	_pulse_border(C_AMBER)

func show_success_summary(index: int, comparisons: int):
	_ensure_built()
	visible = true
	if title_label:
		title_label.text = "FOUND at INDEX %d" % index
		title_label.modulate = C_GREEN
	if sub_label:
		sub_label.text = "comparisons: %d" % comparisons
		sub_label.modulate = C_GREEN
		sub_label.font_size = 48
	if warning_label:
		warning_label.text = "The glowing shelf held the file!"
	if glow_light:
		glow_light.light_color = C_GREEN
		glow_light.light_energy = 2.6
	_pulse_border(C_GREEN)

func reset():
	_ensure_built()
	visible = false
	if warning_label:
		warning_label.text = ""
	if glow_light:
		glow_light.light_energy = 0.0
	clear_3d_question()

func show_3d_question(title: String, question_text: String, _options: Array, color: Color = C_CYAN):
	## Use the bright lab board — never hide the teaching prompt
	set_prompt(title, question_text, color)
	if warning_label:
		warning_label.text = "Decide with the actions below"
	if glow_light:
		glow_light.light_energy = 2.0

func clear_3d_question():
	for opt in option_nodes:
		if is_instance_valid(opt):
			opt.queue_free()
	option_nodes.clear()
