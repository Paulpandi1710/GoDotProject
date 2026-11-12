## ============================================================
## SEARCH FEEDBACK (World-Space Instructional & Guidance HUD)
## ============================================================
## Clean, spatial, billboarded world banner positioned directly in
## the player's natural forward view. Communicates core objectives
## and non-punishing feedback without blocking the environment.
## ============================================================

extends Node3D
class_name SearchFeedback

var title_label: Label3D
var sub_label: Label3D
var warning_label: Label3D
var background_panel: MeshInstance3D
var border: MeshInstance3D
var option_nodes: Array[Node3D] = []

const C_CYAN := Color(0.0, 0.90, 1.0)
const C_AMBER := Color(1.0, 0.65, 0.1)
const C_WHITE := Color(0.92, 0.96, 1.0)
const C_GREEN := Color(0.2, 1.0, 0.45)

func _init():
	_ensure_built()

func _ready():
	_ensure_built()

func _ensure_built():
	if title_label != null:
		return

	# Background Frame
	background_panel = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(4.8, 1.1, 0.04)
	background_panel.mesh = box
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.02, 0.04, 0.08, 0.88)
	bg_mat.metallic = 0.2
	bg_mat.roughness = 0.25
	background_panel.material_override = bg_mat
	add_child(background_panel)

	# Border
	border = MeshInstance3D.new()
	var b_box := BoxMesh.new()
	b_box.size = Vector3(4.86, 1.16, 0.02)
	border.mesh = b_box
	var b_mat := StandardMaterial3D.new()
	b_mat.albedo_color = C_CYAN
	b_mat.emission_enabled = true
	b_mat.emission = C_CYAN
	b_mat.emission_energy_multiplier = 0.4
	border.material_override = b_mat
	border.position = Vector3(0, 0, -0.01)
	add_child(border)

	# Main Objective / Title
	title_label = Label3D.new()
	title_label.name = "FeedbackTitle"
	title_label.text = "✦ OBJECTIVE: FIND THE TARGET SIGNAL ✦"
	title_label.font_size = 32
	title_label.modulate = C_CYAN
	title_label.outline_size = 10
	title_label.outline_modulate = Color(0.01, 0.02, 0.05)
	title_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	title_label.no_depth_test = true
	title_label.render_priority = 15
	title_label.pixel_size = 0.0028
	title_label.position = Vector3(0, 0.24, 0.03)
	add_child(title_label)

	# Subtitle / Action Prompt
	sub_label = Label3D.new()
	sub_label.name = "FeedbackSub"
	sub_label.text = "Aim at the glowing candidate node and trigger to scan"
	sub_label.font_size = 20
	sub_label.modulate = C_WHITE
	sub_label.outline_size = 6
	sub_label.outline_modulate = Color(0.01, 0.02, 0.05)
	sub_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sub_label.no_depth_test = true
	sub_label.render_priority = 15
	sub_label.pixel_size = 0.0024
	sub_label.position = Vector3(0, -0.05, 0.03)
	add_child(sub_label)

	# Temporary Guidance / Warning Label
	warning_label = Label3D.new()
	warning_label.name = "FeedbackWarning"
	warning_label.text = ""
	warning_label.font_size = 19
	warning_label.modulate = C_AMBER
	warning_label.outline_size = 8
	warning_label.outline_modulate = Color(0.02, 0.02, 0.04)
	warning_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	warning_label.no_depth_test = true
	warning_label.render_priority = 15
	warning_label.pixel_size = 0.0022
	warning_label.position = Vector3(0, -0.32, 0.03)
	add_child(warning_label)

func set_prompt(title: String, subtitle: String, color: Color = C_CYAN):
	_ensure_built()
	if title_label:
		title_label.text = title
		title_label.modulate = color
	if sub_label:
		sub_label.text = subtitle
	if warning_label:
		warning_label.text = ""

func show_locked_guidance(current_idx: int, clicked_idx: int):
	_ensure_built()
	if warning_label:
		if clicked_idx > current_idx:
			warning_label.text = "⚠ FOLLOW THE SEARCH • Check index %d first (cannot skip ahead)" % current_idx
		else:
			warning_label.text = "⚠ ALREADY CHECKED • Index %d is done. Check index %d" % [clicked_idx, current_idx]
		warning_label.modulate = C_AMBER

		if is_inside_tree() and get_tree() != null:
			var tween = create_tween()
			if tween != null:
				tween.tween_property(warning_label, "scale", Vector3(1.15, 1.15, 1.15), 0.15)
				tween.tween_property(warning_label, "scale", Vector3.ONE, 0.25)
				tween.tween_interval(2.5)
				tween.tween_callback(func(): warning_label.text = "")
		else:
			warning_label.scale = Vector3.ONE

func show_success_summary(index: int, comparisons: int):
	_ensure_built()
	if title_label:
		title_label.text = "✦ TARGET ACQUIRED AT INDEX %d ✦" % index
		title_label.modulate = C_GREEN
	if sub_label:
		sub_label.text = "Total comparisons: %d | Traversal completed sequentially" % comparisons
	if warning_label:
		warning_label.text = ""

func reset():
	_ensure_built()
	visible = false
	if warning_label:
		warning_label.text = ""
	clear_3d_question()

func show_3d_question(_title: String, _question_text: String, _options: Array, _color: Color = C_CYAN):
	# Questions must NOT be showcased at the 3D array element box.
	# Keep the array box completely clean and clear.
	clear_3d_question()

func clear_3d_question():
	for opt in option_nodes:
		if is_instance_valid(opt):
			opt.queue_free()
	option_nodes.clear()

	# Restore default panel dimensions
	if background_panel:
		var box := BoxMesh.new()
		box.size = Vector3(4.8, 1.1, 0.04)
		background_panel.mesh = box
	if border:
		var b_box := BoxMesh.new()
		b_box.size = Vector3(4.86, 1.16, 0.02)
		border.mesh = b_box
	if title_label:
		title_label.position = Vector3(0, 0.24, 0.03)
	if sub_label:
		sub_label.position = Vector3(0, -0.05, 0.03)
		sub_label.width = 500.0

