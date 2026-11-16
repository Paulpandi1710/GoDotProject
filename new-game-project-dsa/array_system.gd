## ============================================================
## DSA ACADEMY — ARRAY SYSTEM & SEARCH WORLD ARCHITECTURE
## ============================================================
## Visual and interactive manager for sequential and binary data
## structures in VR.
##
## Integrates:
## - SearchTarget: 3D Holographic Target Beacon (Gold frequency)
## - SearchPointer: Smooth glide down-facing indicator (Cyan)
## - SearchTrail: Cyber energy conduits connecting checked nodes
## - ComparisonVisualizer: In-world equality/inequality badge
## - SearchFeedback: Minimal, non-intrusive spatial guide banner
## ============================================================

extends Node3D

# ============================================================
# DATA & NODES
# ============================================================

const SearchTargetScript := preload("res://search_target.gd")
const SearchPointerScript := preload("res://search_pointer.gd")
const SearchTrailScript := preload("res://search_trail.gd")
const ComparisonVisualizerScript := preload("res://comparison_visualizer.gd")
const SearchFeedbackScript := preload("res://search_feedback.gd")

var values: Array = []
var element_bodies: Array = []

var search_target: Node3D
var search_pointer: Node3D
var search_trail: Node3D
var comparison_visualizer: Node3D
var search_feedback: Node3D

# ============================================================
# MATERIALS
# ============================================================

var normal_material: StandardMaterial3D
var active_material: StandardMaterial3D
var hover_material: StandardMaterial3D
var locked_material: StandardMaterial3D
var wrong_material: StandardMaterial3D
var correct_material: StandardMaterial3D
var checked_material: StandardMaterial3D
var comparing_material: StandardMaterial3D
var sorted_material: StandardMaterial3D
var capsule_trim_material: StandardMaterial3D
var plaque_material: StandardMaterial3D
var plaque_border_material: StandardMaterial3D
var eliminated_material: StandardMaterial3D
var eliminated_border_material: StandardMaterial3D
var float_time: float = 0.0

var is_sorting_mode: bool = false
var sorted_indices: Array[int] = []

# ============================================================
# SEARCH STATE
# ============================================================

var current_search_index: int = 0
var comparisons: int = 0
var search_started: bool = false
var search_completed: bool = false
var transition_in_progress: bool = false

# ============================================================
# SETTINGS
# ============================================================

const ELEMENT_WIDTH: float = 1.80
const ELEMENT_HEIGHT: float = 1.45
const ELEMENT_DEPTH: float = 0.65
const ELEMENT_GAP: float = 0.38
const ARRAY_Y: float = 1.55
const ARRAY_Z: float = 0.0

var target_value: int = 40
var is_binary_search: bool = false
var left_bound: int = 0
var right_bound: int = 0

## In front of shelves (camera-facing) so the board never sits dull/hidden behind them
const INFO_Z: float = 0.85
const FEEDBACK_Y: float = 3.45

# ============================================================
# READY & PROCESS
# ============================================================

func _ready():
	add_to_group("array_system")
	create_materials()
	_create_spatial_components()

func _create_spatial_components():
	if search_pointer == null:
		search_pointer = SearchPointerScript.new()
		search_pointer.name = "SearchPointer"
		search_pointer.visible = false
		add_child(search_pointer)

	if search_target == null:
		search_target = SearchTargetScript.new()
		search_target.name = "SearchTarget"
		search_target.visible = false
		add_child(search_target)

	if search_trail == null:
		search_trail = SearchTrailScript.new()
		search_trail.name = "SearchTrail"
		add_child(search_trail)

	if comparison_visualizer == null:
		comparison_visualizer = ComparisonVisualizerScript.new()
		comparison_visualizer.name = "ComparisonVisualizer"
		add_child(comparison_visualizer)

	if search_feedback == null:
		search_feedback = SearchFeedbackScript.new()
		search_feedback.name = "SearchFeedback"
		search_feedback.position = Vector3(0, FEEDBACK_Y, INFO_Z)
		add_child(search_feedback)

func _process(delta: float):
	if element_bodies.is_empty():
		return
	float_time += delta
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if is_instance_valid(el) and not transition_in_progress:
			var base_y: float = float(el.get_meta("base_y", ARRAY_Y))
			var is_active = (i == current_search_index and not search_completed)
			var lift = 0.12 if is_active else 0.0
			var bob = sin(float_time * 2.2 + i * 0.6) * 0.035
			el.position.y = base_y + lift + bob

# ============================================================
# MATERIALS
# ============================================================

func create_materials():
	normal_material = StandardMaterial3D.new()
	normal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	normal_material.albedo_color = Color(0.04, 0.08, 0.14, 0.72)
	normal_material.metallic = 0.20
	normal_material.roughness = 0.08
	normal_material.clearcoat_enabled = true
	normal_material.clearcoat = 1.0
	normal_material.clearcoat_roughness = 0.08
	normal_material.metallic_specular = 0.0

	active_material = StandardMaterial3D.new()
	active_material.albedo_color = Color(0.0, 0.85, 1.0)
	active_material.emission_enabled = true
	active_material.emission = Color(0.0, 0.85, 1.0)
	active_material.emission_energy_multiplier = 0.6
	active_material.metallic = 0.3
	active_material.roughness = 0.1

	hover_material = StandardMaterial3D.new()
	hover_material.albedo_color = Color(0.3, 0.95, 1.0)
	hover_material.emission_enabled = true
	hover_material.emission = Color(0.3, 0.95, 1.0)
	hover_material.emission_energy_multiplier = 0.8

	locked_material = StandardMaterial3D.new()
	locked_material.albedo_color = Color(0.03, 0.05, 0.08)
	locked_material.metallic = 0.2
	locked_material.roughness = 0.7

	wrong_material = StandardMaterial3D.new()
	wrong_material.albedo_color = Color(0.95, 0.25, 0.25)
	wrong_material.emission_enabled = true
	wrong_material.emission = Color(0.95, 0.25, 0.25)
	wrong_material.emission_energy_multiplier = 0.7

	correct_material = StandardMaterial3D.new()
	correct_material.albedo_color = Color(0.2, 0.95, 0.4)
	correct_material.emission_enabled = true
	correct_material.emission = Color(0.2, 0.95, 0.4)
	correct_material.emission_energy_multiplier = 0.8

	checked_material = StandardMaterial3D.new()
	checked_material.albedo_color = Color(0.08, 0.14, 0.18)
	checked_material.metallic = 0.3
	checked_material.roughness = 0.4
	checked_material.emission_enabled = true
	checked_material.emission = Color(0.05, 0.25, 0.20)
	checked_material.emission_energy_multiplier = 0.5

	capsule_trim_material = StandardMaterial3D.new()
	capsule_trim_material.albedo_color = Color(0.05, 0.08, 0.12)
	capsule_trim_material.metallic = 0.8
	capsule_trim_material.roughness = 0.2
	capsule_trim_material.emission_enabled = true
	capsule_trim_material.emission = Color(0.0, 0.75, 1.0)
	capsule_trim_material.emission_energy_multiplier = 0.3

	plaque_material = StandardMaterial3D.new()
	plaque_material.albedo_color = Color(0.02, 0.04, 0.08, 0.96)
	plaque_material.metallic = 0.1
	plaque_material.roughness = 0.2
	plaque_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	plaque_border_material = StandardMaterial3D.new()
	plaque_border_material.albedo_color = Color(0.0, 0.85, 1.0)
	plaque_border_material.emission_enabled = true
	plaque_border_material.emission = Color(0.0, 0.85, 1.0)
	plaque_border_material.emission_energy_multiplier = 1.2
	plaque_border_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	eliminated_material = StandardMaterial3D.new()
	eliminated_material.albedo_color = Color(0.015, 0.02, 0.03, 0.98)
	eliminated_material.metallic = 0.1
	eliminated_material.roughness = 0.95
	eliminated_material.emission_enabled = false

	eliminated_border_material = StandardMaterial3D.new()
	eliminated_border_material.albedo_color = Color(0.04, 0.05, 0.07, 0.3)
	eliminated_border_material.emission_enabled = false
	eliminated_border_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	comparing_material = StandardMaterial3D.new()
	comparing_material.albedo_color = Color(1.0, 0.58, 0.05)
	comparing_material.emission_enabled = true
	comparing_material.emission = Color(1.0, 0.58, 0.05)
	comparing_material.emission_energy_multiplier = 0.85
	comparing_material.metallic = 0.3
	comparing_material.roughness = 0.2

	sorted_material = StandardMaterial3D.new()
	sorted_material.albedo_color = Color(0.15, 0.95, 0.45)
	sorted_material.emission_enabled = true
	sorted_material.emission = Color(0.15, 0.95, 0.45)
	sorted_material.emission_energy_multiplier = 0.85
	sorted_material.metallic = 0.3
	sorted_material.roughness = 0.2

# ============================================================
# CREATE ARRAY
# ============================================================

func create_array(new_values: Array):
	values.clear()
	element_bodies.clear()
	current_search_index = 0
	comparisons = 0
	search_started = false
	search_completed = false
	transition_in_progress = false

	# Remove old element bodies only
	for child in get_children():
		if child != search_pointer and child != search_target and child != search_trail and child != comparison_visualizer and child != search_feedback:
			child.queue_free()

	values.append_array(new_values)
	create_materials()
	_create_spatial_components()

	clear_all_visualizers()

	# Compute layout
	var total_width: float = (values.size() * ELEMENT_WIDTH) + ((values.size() - 1) * ELEMENT_GAP)
	var start_x: float = -total_width / 2.0

	# Setup initial SearchTarget Beacon position (hidden until search actively requested)
	if search_target:
		search_target.visible = false
		search_target.position = Vector3(start_x + total_width + 1.8, 0.35, -0.2)
		search_target.set_target(target_value)

	# Position SearchFeedback
	if search_feedback:
		search_feedback.position = Vector3(0, FEEDBACK_Y, INFO_Z)
		search_feedback.visible = false

	# Create Elements
	for i in range(values.size()):
		var x: float = start_x + i * (ELEMENT_WIDTH + ELEMENT_GAP) + ELEMENT_WIDTH / 2.0
		var element_pos: Vector3 = Vector3(x, ARRAY_Y, ARRAY_Z)
		create_element(i, values[i], element_pos)

	# Set initial visual state based on mode
	if is_sorting_mode:
		for e in element_bodies:
			var mesh = e.get_node_or_null("ElementBody")
			if mesh: mesh.material_override = normal_material
			var collision = e.get_node_or_null("ElementCollision")
			if collision: collision.disabled = false
			var compare_label = e.get_node_or_null("CompareText")
			if compare_label:
				compare_label.text = ""
	else:
		# Lock all initially until search begins
		for e in element_bodies:
			var mesh = e.get_node_or_null("ElementBody")
			if mesh: mesh.material_override = locked_material
			var collision = e.get_node_or_null("ElementCollision")
			if collision: collision.disabled = true
			var compare_label = e.get_node_or_null("CompareText")
			if compare_label:
				compare_label.modulate = Color(0.5, 0.5, 0.5)
				compare_label.text = "🔒"

	if search_pointer:
		search_pointer.visible = false

# ============================================================
# START SEARCH
# ============================================================

func clear_all_visualizers():
	search_completed = false
	search_started = false
	if comparison_visualizer:
		comparison_visualizer.hide_comparison()
	if search_target:
		search_target.reset()
	if search_pointer:
		search_pointer.visible = false
	if search_trail:
		search_trail.clear_trail()
	if search_feedback:
		search_feedback.reset()

func start_search():
	search_completed = false
	is_binary_search = false
	search_started = true
	current_search_index = 0
	comparisons = 0
	transition_in_progress = false

	if comparison_visualizer:
		comparison_visualizer.hide_comparison()

	if search_target:
		search_target.visible = true
		search_target.set_target(target_value)

	if search_feedback:
		search_feedback.visible = true
		search_feedback.set_prompt("✦ OBJECTIVE: FIND SIGNAL %d ✦" % target_value, "Sequential scan in progress • Inspect node at index 0")

	update_active_element()
	update_ui_search_state()

func start_binary_search(target: int, left: int, right: int, mid: int):
	search_completed = false
	target_value = target
	is_binary_search = true
	search_started = true
	left_bound = left
	right_bound = right
	current_search_index = mid
	comparisons = 0
	transition_in_progress = false

	if comparison_visualizer:
		comparison_visualizer.hide_comparison()

	if search_target:
		search_target.visible = true
		search_target.set_target(target_value)

	if search_feedback:
		search_feedback.visible = true
		search_feedback.set_prompt("✦ BINARY SEARCH PROTOCOL ✦", "Inspect MID node at index %d • Halve the search space" % mid)

	update_active_element()
	update_ui_search_state()

func update_binary_bounds(left: int, right: int, mid: int):
	left_bound = left
	right_bound = right
	current_search_index = mid
	if comparison_visualizer:
		comparison_visualizer.hide_comparison()
	if search_feedback:
		search_feedback.visible = true
		search_feedback.set_prompt("✦ SEARCH SPACE: [%d ... %d] ✦" % [left, right], "Current MID candidate: index %d" % mid)
	update_active_element()

## ── BINARY SEARCH INTRO VISUALIZATIONS ──

func visualize_intro_sorted():
	transition_in_progress = false
	if search_target:
		search_target.visible = false
	if search_pointer:
		search_pointer.visible = false
	if search_feedback:
		search_feedback.set_prompt("✦ 1. SORTED ARCHIVE REQUIREMENT ✦", "10 < 15 < 25 < 30 < 40 < 55 < 60 • Ascending Order Confirmed")
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if is_instance_valid(el):
			var mesh = el.get_node_or_null("ElementBody")
			var cmp = el.get_node_or_null("CompareText")
			if mesh:
				mesh.material_override = normal_material
			if cmp:
				cmp.modulate = Color(0.15, 0.95, 0.45)
				cmp.text = "✓ SORTED"
	# Animate a sequential pulse sweep across elements
	var tween := create_tween()
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if is_instance_valid(el):
			tween.tween_callback(func():
				if is_instance_valid(el):
					var m = el.get_node_or_null("ElementBody")
					if m: m.material_override = active_material
			)
			tween.tween_interval(0.12)
			tween.tween_callback(func():
				if is_instance_valid(el):
					var m = el.get_node_or_null("ElementBody")
					if m: m.material_override = normal_material
			)

func visualize_intro_bounds(left_idx: int, right_idx: int):
	if search_feedback:
		search_feedback.set_prompt("✦ 2. DEFINE BOUNDARIES: [%d ... %d] ✦" % [left_idx, right_idx], "LEFT (index %d) ── SEARCH RANGE ── RIGHT (index %d)" % [left_idx, right_idx])
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if not is_instance_valid(el): continue
		var mesh = el.get_node_or_null("ElementBody")
		var cmp = el.get_node_or_null("CompareText")
		if i == left_idx:
			if mesh: mesh.material_override = active_material
			if cmp:
				cmp.modulate = Color(0.0, 0.95, 1.0)
				cmp.text = "◀ LEFT BOUND (%d)" % left_idx
		elif i == right_idx:
			if mesh: mesh.material_override = active_material
			if cmp:
				cmp.modulate = Color(0.78, 0.42, 1.0)
				cmp.text = "▶ RIGHT BOUND (%d)" % right_idx
		else:
			if mesh: mesh.material_override = normal_material
			if cmp:
				cmp.modulate = Color(0.8, 0.9, 1.0)
				cmp.text = "ACTIVE WINDOW"

func visualize_intro_halving(left_idx: int, right_idx: int, mid_idx: int, target: int):
	var mid_val = values[mid_idx] if mid_idx < values.size() else 0
	if search_pointer and mid_idx < element_bodies.size():
		search_pointer.visible = true
		var mid_body = element_bodies[mid_idx]
		if is_instance_valid(mid_body):
			var pos = mid_body.global_position if mid_body.is_inside_tree() else mid_body.position
			search_pointer.move_to_target(pos + Vector3(0, 1.8, 0), 0.35)
			search_pointer.set_index(mid_idx)
	if search_feedback:
		search_feedback.set_prompt("✦ 3. MID = (%d+%d)/2 = %d (Value %s) ✦" % [left_idx, right_idx, mid_idx, str(mid_val)], "%s < %d  →  Target is to the RIGHT! Left half ELIMINATED!" % [str(mid_val), target])
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if not is_instance_valid(el): continue
		var mesh = el.get_node_or_null("ElementBody")
		var cmp = el.get_node_or_null("CompareText")
		if i == mid_idx:
			if mesh: mesh.material_override = active_material
			if cmp:
				cmp.modulate = Color(1.0, 0.85, 0.2)
				cmp.text = "★ MID (%d)" % mid_idx
		elif i < mid_idx:
			if mesh: mesh.material_override = wrong_material
			if cmp:
				cmp.modulate = Color(1.0, 0.3, 0.3)
				cmp.text = "✂ ELIMINATED"
		else:
			if mesh: mesh.material_override = normal_material
			if cmp:
				cmp.modulate = Color(0.2, 0.95, 0.5)
				cmp.text = "REMAINING CANDIDATE"

func reset_element_visuals():
	for i in range(element_bodies.size()):
		var el = element_bodies[i]
		if not is_instance_valid(el): continue
		var mesh = el.get_node_or_null("ElementBody")
		var cmp = el.get_node_or_null("CompareText")
		if mesh: mesh.material_override = normal_material
		if cmp:
			cmp.modulate = Color(0.85, 0.95, 1.0)
			cmp.text = ""
	if search_pointer:
		search_pointer.visible = false

# ============================================================
# CREATE ELEMENT
# ============================================================

func create_element(index: int, value, element_position: Vector3):
	var body := StaticBody3D.new()
	body.name = "ArrayElement_%d" % index
	body.position = element_position
	add_child(body)
	element_bodies.append(body)

	# Main Capsule Box
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "ElementBody"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(ELEMENT_WIDTH, ELEMENT_HEIGHT, ELEMENT_DEPTH)
	mesh_instance.mesh = mesh
	mesh_instance.material_override = normal_material
	body.add_child(mesh_instance)

	# Collision Shape - enlarged hitbox covering full capsule, caps, brackets, and labels
	var collision := CollisionShape3D.new()
	collision.name = "ElementCollision"
	var shape := BoxShape3D.new()
	shape.size = Vector3(ELEMENT_WIDTH + 0.40, ELEMENT_HEIGHT + 0.50, ELEMENT_DEPTH + 0.60)
	collision.shape = shape
	body.add_child(collision)

	# Top and Bottom Caps
	var top_cap := MeshInstance3D.new()
	top_cap.name = "TopCap"
	var tc_mesh := BoxMesh.new()
	tc_mesh.size = Vector3(ELEMENT_WIDTH + 0.04, 0.08, ELEMENT_DEPTH + 0.04)
	top_cap.mesh = tc_mesh
	top_cap.material_override = capsule_trim_material
	top_cap.position = Vector3(0, ELEMENT_HEIGHT / 2.0 + 0.04, 0)
	body.add_child(top_cap)

	var bottom_cap := MeshInstance3D.new()
	bottom_cap.name = "BottomCap"
	var bc_mesh := BoxMesh.new()
	bc_mesh.size = Vector3(ELEMENT_WIDTH + 0.04, 0.08, ELEMENT_DEPTH + 0.04)
	bottom_cap.mesh = bc_mesh
	bottom_cap.material_override = capsule_trim_material
	bottom_cap.position = Vector3(0, -ELEMENT_HEIGHT / 2.0 - 0.04, 0)
	body.add_child(bottom_cap)

	# Left & Right Cyber Stabilizer Brackets
	for side: float in [-1.0, 1.0]:
		var bracket := MeshInstance3D.new()
		var b_mesh := BoxMesh.new()
		b_mesh.size = Vector3(0.06, ELEMENT_HEIGHT * 0.90, ELEMENT_DEPTH * 0.95)
		bracket.mesh = b_mesh
		bracket.material_override = capsule_trim_material
		bracket.position = Vector3(side * (ELEMENT_WIDTH / 2.0 + 0.02), 0, 0)
		body.add_child(bracket)

	# Holographic Ground Emitter Disc (Anchors the floating capsule to the 3D world)
	var emitter_disc := MeshInstance3D.new()
	emitter_disc.name = "GroundDisc"
	var d_cyl := CylinderMesh.new()
	d_cyl.top_radius = 0.70
	d_cyl.bottom_radius = 0.85
	d_cyl.height = 0.05
	emitter_disc.mesh = d_cyl
	var d_mat := StandardMaterial3D.new()
	d_mat.albedo_color = Color(0.04, 0.08, 0.14)
	d_mat.metallic = 0.8
	d_mat.roughness = 0.2
	emitter_disc.material_override = d_mat
	emitter_disc.position = Vector3(0, -element_position.y + 0.025, 0)
	body.add_child(emitter_disc)

	var e_ring := MeshInstance3D.new()
	e_ring.name = "GroundRing"
	var er_torus := TorusMesh.new()
	er_torus.inner_radius = 0.65
	er_torus.outer_radius = 0.72
	e_ring.mesh = er_torus
	var er_mat := StandardMaterial3D.new()
	er_mat.albedo_color = Color(0.0, 0.85, 1.0)
	er_mat.emission_enabled = true
	er_mat.emission = Color(0.0, 0.85, 1.0)
	er_mat.emission_energy_multiplier = 1.6
	e_ring.material_override = er_mat
	e_ring.position = Vector3(0, -element_position.y + 0.055, 0)
	body.add_child(e_ring)

	# Frosted Display Plaque
	var plaque := MeshInstance3D.new()
	plaque.name = "Plaque"
	var p_mesh := BoxMesh.new()
	p_mesh.size = Vector3(ELEMENT_WIDTH * 0.88, ELEMENT_HEIGHT * 0.80, 0.02)
	plaque.mesh = p_mesh
	plaque.material_override = plaque_material
	plaque.position = Vector3(0, 0, ELEMENT_DEPTH / 2.0 + 0.02)
	body.add_child(plaque)

	var plaque_border := MeshInstance3D.new()
	plaque_border.name = "PlaqueBorder"
	var pb_mesh := BoxMesh.new()
	pb_mesh.size = Vector3(ELEMENT_WIDTH * 0.90, ELEMENT_HEIGHT * 0.82, 0.01)
	plaque_border.mesh = pb_mesh
	plaque_border.material_override = plaque_border_material
	plaque_border.position = Vector3(0, 0, ELEMENT_DEPTH / 2.0 + 0.015)
	body.add_child(plaque_border)

	var front_z: float = ELEMENT_DEPTH / 2.0 + 0.06

	# Value Label
	var value_label := Label3D.new()
	value_label.name = "Value"
	value_label.text = str(value)
	value_label.font_size = 80
	value_label.modulate = Color(1.0, 1.0, 1.0)
	value_label.outline_size = 14
	value_label.outline_modulate = Color(0.01, 0.03, 0.07)
	value_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	value_label.no_depth_test = true
	value_label.render_priority = 10
	value_label.pixel_size = 0.0031
	value_label.position = Vector3(0, 0.02, front_z)
	body.add_child(value_label)

	# Index Label
	var index_label := Label3D.new()
	index_label.name = "Index"
	index_label.text = "INDEX %d" % index
	index_label.font_size = 30
	index_label.modulate = Color(0.0, 0.90, 1.0)
	index_label.outline_size = 8
	index_label.outline_modulate = Color(0.01, 0.03, 0.07)
	index_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	index_label.no_depth_test = true
	index_label.render_priority = 10
	index_label.pixel_size = 0.0024
	index_label.position = Vector3(0, 0.46, front_z)
	body.add_child(index_label)

	# Status Label on node
	var compare_label := Label3D.new()
	compare_label.name = "CompareText"
	compare_label.text = ""
	compare_label.font_size = 40
	compare_label.modulate = Color(1.0, 0.9, 0.2)
	compare_label.outline_size = 14
	compare_label.outline_modulate = Color(0.01, 0.03, 0.07)
	compare_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	compare_label.no_depth_test = true
	compare_label.render_priority = 20
	compare_label.pixel_size = 0.0028
	compare_label.position = Vector3(0, -0.40, front_z)
	body.add_child(compare_label)

	# Base accent line
	var line := MeshInstance3D.new()
	line.name = "AccentLine"
	var line_mesh := BoxMesh.new()
	line_mesh.size = Vector3(1.40, 0.035, 0.025)
	line.mesh = line_mesh
	line.position = Vector3(0, -0.54, front_z)
	line.material_override = plaque_border_material
	body.add_child(line)

	body.set_meta("array_system", self)
	body.set_meta("array_index", index)
	body.set_meta("array_value", value)
	body.set_meta("is_target", int(value) == target_value)
	body.set_meta("base_y", element_position.y)

# ============================================================
# UPDATE ACTIVE ELEMENT
# ============================================================

func update_active_element():
	if is_sorting_mode:
		if search_pointer != null:
			search_pointer.visible = false
		return

	# Update SearchPointer position
	if search_pointer != null:
		if current_search_index >= 0 and current_search_index < element_bodies.size():
			search_pointer.visible = true
			var active_element = element_bodies[current_search_index]
			if is_instance_valid(active_element):
				var target_pos := Vector3(
					active_element.position.x,
					active_element.position.y + ELEMENT_HEIGHT / 2.0 + 0.65,
					active_element.position.z
				)
				search_pointer.move_to_target(target_pos, 0.35)
				search_pointer.set_index(current_search_index)
		else:
			search_pointer.visible = false

	# Update elements state & collision
	for i in range(element_bodies.size()):
		var element = element_bodies[i]
		if not is_instance_valid(element):
			continue

		var mesh = element.get_node_or_null("ElementBody")
		var collision = element.get_node_or_null("ElementCollision")
		var compare_label = element.get_node_or_null("CompareText")
		if mesh == null:
			continue

		if is_binary_search:
			if i < left_bound or i > right_bound:
				_apply_eliminated_style(element)
			else:
				_apply_active_candidate_style(element, i == current_search_index, i == left_bound, i == right_bound)
		else:
			## Strict linear order: ONLY the current shelf is clickable
			if i == current_search_index:
				mesh.material_override = active_material
				if collision: collision.disabled = false
				if compare_label:
					compare_label.modulate = Color(0.0, 0.95, 1.0)
					compare_label.text = "SCANNING"
			elif i < current_search_index:
				mesh.material_override = checked_material
				if collision: collision.disabled = true
				if compare_label:
					compare_label.modulate = Color(0.2, 1.0, 0.45)
					compare_label.text = "✓ CHECKED"
			else:
				mesh.material_override = locked_material
				if collision: collision.disabled = true
				if compare_label:
					compare_label.modulate = Color(0.65, 0.72, 0.85)
					compare_label.text = "🔒 LOCKED"

func _apply_eliminated_style(element: Node3D):
	var mesh = element.get_node_or_null("ElementBody")
	if mesh: mesh.material_override = eliminated_material
	var plaque = element.get_node_or_null("Plaque")
	if plaque: plaque.material_override = eliminated_material
	var border = element.get_node_or_null("PlaqueBorder")
	if border: border.material_override = eliminated_border_material
	var line = element.get_node_or_null("AccentLine")
	if line: line.material_override = eliminated_border_material
	var ring = element.get_node_or_null("GroundRing")
	if ring: ring.visible = false
	var top_c = element.get_node_or_null("TopCap")
	if top_c: top_c.material_override = eliminated_material
	var bot_c = element.get_node_or_null("BottomCap")
	if bot_c: bot_c.material_override = eliminated_material
	var collision = element.get_node_or_null("ElementCollision")
	if collision: collision.disabled = true
	var val_lbl = element.get_node_or_null("Value")
	if val_lbl: val_lbl.modulate = Color(0.18, 0.18, 0.22, 0.25)
	var idx_lbl = element.get_node_or_null("Index")
	if idx_lbl: idx_lbl.modulate = Color(0.2, 0.2, 0.25, 0.3)
	var cmp_lbl = element.get_node_or_null("CompareText")
	if cmp_lbl:
		cmp_lbl.modulate = Color(0.55, 0.15, 0.15)
		cmp_lbl.text = "⛔ CLOSED"

func _apply_active_candidate_style(element: Node3D, is_mid: bool, is_left: bool, is_right: bool):
	var mesh = element.get_node_or_null("ElementBody")
	var plaque = element.get_node_or_null("Plaque")
	if plaque: plaque.material_override = plaque_material
	var border = element.get_node_or_null("PlaqueBorder")
	if border: border.material_override = plaque_border_material
	var line = element.get_node_or_null("AccentLine")
	if line: line.material_override = plaque_border_material
	var ring = element.get_node_or_null("GroundRing")
	if ring: ring.visible = true
	var top_c = element.get_node_or_null("TopCap")
	if top_c: top_c.material_override = capsule_trim_material
	var bot_c = element.get_node_or_null("BottomCap")
	if bot_c: bot_c.material_override = capsule_trim_material
	var collision = element.get_node_or_null("ElementCollision")
	if collision: collision.disabled = false
	var val_lbl = element.get_node_or_null("Value")
	if val_lbl: val_lbl.modulate = Color(1.0, 1.0, 1.0)
	var idx_lbl = element.get_node_or_null("Index")
	if idx_lbl: idx_lbl.modulate = Color(0.0, 0.90, 1.0)
	var cmp_lbl = element.get_node_or_null("CompareText")

	if is_mid:
		if mesh: mesh.material_override = active_material
		if cmp_lbl:
			cmp_lbl.modulate = Color(1.0, 0.85, 0.2)
			cmp_lbl.text = "★ MID CANDIDATE"
	elif is_left and is_right:
		if mesh: mesh.material_override = normal_material
		if cmp_lbl:
			cmp_lbl.modulate = Color(0.2, 0.95, 0.5)
			cmp_lbl.text = "◀ LEFT = RIGHT ▶"
	elif is_left:
		if mesh: mesh.material_override = normal_material
		if cmp_lbl:
			cmp_lbl.modulate = Color(0.0, 0.95, 1.0)
			cmp_lbl.text = "◀ LEFT BOUND"
	elif is_right:
		if mesh: mesh.material_override = normal_material
		if cmp_lbl:
			cmp_lbl.modulate = Color(0.78, 0.42, 1.0)
			cmp_lbl.text = "▶ RIGHT BOUND"
	else:
		if mesh: mesh.material_override = normal_material
		if cmp_lbl:
			cmp_lbl.modulate = Color(0.85, 0.95, 1.0)
			cmp_lbl.text = "POSSIBLE"

# ============================================================
# HOVER & UNHOVER
# ============================================================

func on_element_hover(element):
	if element == null or search_completed or transition_in_progress:
		return
	var index: int = int(element.get_meta("array_index", -1))
	## Only the active shelf reacts to hover — locked shelves stay locked
	if not is_binary_search and not is_sorting_mode and index != current_search_index:
		return
	var mesh = element.get_node_or_null("ElementBody")
	if mesh:
		mesh.material_override = hover_material

func on_element_unhover(element):
	if element == null:
		return
	## Restore correct locked/checked/active look (don't wipe to normal)
	if not is_binary_search and not is_sorting_mode:
		update_active_element()
		return
	var index: int = int(element.get_meta("array_index", -1))
	var mesh = element.get_node_or_null("ElementBody")
	if mesh:
		if index == current_search_index:
			mesh.material_override = active_material
		else:
			mesh.material_override = normal_material

# ============================================================
# INTERACT WITH ELEMENT
# ============================================================

func interact_with_element(element):
	if element == null or transition_in_progress:
		return

	var index: int = int(element.get_meta("array_index", -1))
	var value = element.get_meta("array_value", 0)

	## Hard block ahead-of-order clicks in linear mode (even if collision somehow enabled)
	if not is_binary_search and not is_sorting_mode and search_started and not search_completed:
		if index != current_search_index:
			if search_feedback and search_feedback.has_method("show_order_lock"):
				search_feedback.visible = true
				search_feedback.show_order_lock(current_search_index, index)
			var audio_block = get_node_or_null("/root/AudioManager")
			if audio_block != null and audio_block.has_method("play_wrong_sound"):
				audio_block.play_wrong_sound()
			var lesson_managers_block = get_tree().get_nodes_in_group("lesson_manager")
			if lesson_managers_block.size() > 0 and lesson_managers_block[0].has_method("element_selected"):
				lesson_managers_block[0].element_selected(index, value)
			return

	# Sound feedback
	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("play_click_sound"):
		audio.play_click_sound()

	# Selection visual bounce animation on the clicked element
	var tween = create_tween()
	tween.tween_property(element, "scale", Vector3(1.15, 1.15, 1.15), 0.10)
	tween.tween_property(element, "scale", Vector3.ONE, 0.16)

	# Always forward to lesson manager so it can process the student's action
	var lesson_managers = get_tree().get_nodes_in_group("lesson_manager")
	if lesson_managers.size() > 0:
		var manager = lesson_managers[0]
		if manager.has_method("element_selected"):
			manager.element_selected(index, value)

# ============================================================
# EXECUTE COMPARISON
# ============================================================

func execute_comparison(index: int, value: int):
	transition_in_progress = true
	search_started = true
	comparisons += 1

	if is_inside_tree():
		var audio = get_node_or_null("/root/AudioManager")
		if audio and audio.has_method("play_comparison_sound"):
			audio.play_comparison_sound()

	var element = null
	for e in element_bodies:
		if is_instance_valid(e) and e.get_meta("array_index", -1) == index:
			element = e
			break

	if element == null:
		transition_in_progress = false
		return

	var mesh = element.get_node_or_null("ElementBody")
	var compare_label = element.get_node_or_null("CompareText")

	# Add search trail connection segment
	if search_trail and index > 0 and index < element_bodies.size():
		var prev_el = element_bodies[index - 1]
		if is_instance_valid(prev_el):
			search_trail.add_segment(prev_el.position, element.position)

	# --------------------------------------------------------
	# TARGET FOUND
	# --------------------------------------------------------
	if int(value) == target_value:
		search_completed = true

		if is_inside_tree():
			var success_audio = get_node_or_null("/root/AudioManager")
			if success_audio and success_audio.has_method("play_success_sound"):
				success_audio.play_success_sound()

		if mesh:
			mesh.material_override = correct_material

		if compare_label:
			compare_label.modulate = Color(0.2, 1.0, 0.4)
			compare_label.text = "%d == %d\nFOUND!" % [value, target_value]

		# Visualizer & spatial reactions
		if comparison_visualizer:
			comparison_visualizer.show_comparison(element.position, value, target_value, true, 1.2)

		if search_target:
			search_target.celebrate_found()

		if search_trail:
			search_trail.illuminate_success()

		if search_pointer:
			search_pointer.pulse_match()

		if search_feedback:
			search_feedback.show_success_summary(index, comparisons)

		disable_all_collisions()

		# Celebratory Element Bounce & Spin
		if is_instance_valid(element) and is_inside_tree() and get_tree() != null:
			var tween = get_tree().create_tween()
			tween.set_parallel(true)
			tween.tween_property(element, "position:y", element.position.y + 0.5, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(element, "rotation_degrees:y", 360.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		var ui = get_game_ui()
		if ui != null:
			if ui.has_method("highlight_found_index"):
				ui.highlight_found_index(index)
			if ui.has_method("complete_target"):
				ui.complete_target(index, value)

		transition_in_progress = false
		return

	# --------------------------------------------------------
	# WRONG VALUE / MISMATCH
	# --------------------------------------------------------
	if is_inside_tree():
		var wrong_audio = get_node_or_null("/root/AudioManager")
		if wrong_audio and wrong_audio.has_method("play_wrong_sound"):
			wrong_audio.play_wrong_sound()

	if mesh:
		mesh.material_override = wrong_material

	if compare_label:
		compare_label.modulate = Color(1.0, 0.3, 0.3)
		compare_label.text = "%d ≠ %d\nNO MATCH" % [value, target_value]

	if comparison_visualizer:
		comparison_visualizer.show_comparison(element.position, value, target_value, false, 0.7)

	if search_pointer:
		search_pointer.pulse_mismatch()

	var ui = get_game_ui()
	if ui and ui.has_method("show_search_message"):
		ui.show_search_message(index, value, target_value, comparisons)

	# Brief comfortable pause before advancing
	if is_inside_tree() and get_tree() != null:
		await get_tree().create_timer(0.65).timeout

	if search_completed:
		transition_in_progress = false
		return

	# Advance to next index
	if not is_binary_search:
		current_search_index += 1

	# End of array check (Not Found)
	if current_search_index >= values.size():
		search_completed = true
		disable_all_collisions()
		if search_feedback:
			search_feedback.set_prompt("✦ SEARCH COMPLETE: TARGET NOT FOUND ✦", "All %d elements verified • Target not present" % values.size(), Color(1.0, 0.4, 0.2))
		if ui and ui.has_method("show_failure_message"):
			ui.show_failure_message(target_value, comparisons)
		var lm_list = get_tree().get_nodes_in_group("lesson_manager")
		if lm_list.size() > 0 and lm_list[0].has_method("search_failed"):
			lm_list[0].search_failed()

	transition_in_progress = false
	update_active_element()
	update_ui_search_state()

# ============================================================
# HELPER & COMPATIBILITY METHODS
# ============================================================

func disable_all_collisions():
	for element in element_bodies:
		if is_instance_valid(element):
			var coll = element.get_node_or_null("ElementCollision")
			if coll: coll.disabled = true

func update_ui_search_state():
	var ui = get_game_ui()
	if ui == null: return
	if is_binary_search:
		if ui.has_method("show_binary_search_state"):
			ui.show_binary_search_state(left_bound, right_bound, current_search_index, comparisons)
	else:
		if ui.has_method("show_search_state"):
			ui.show_search_state(current_search_index, comparisons)

func get_game_ui():
	if is_inside_tree() and get_tree() != null:
		return get_tree().get_first_node_in_group("dsa_game_ui")
	return null

func set_instruction_text(text: String):
	if search_feedback:
		search_feedback.set_prompt("✦ OBJECTIVE ✦", text)

func set_status_text(text: String, color: Color = Color(0.0, 0.85, 1.0)):
	if search_feedback:
		search_feedback.set_prompt("✦ STATUS ✦", text, color)

func set_array_texts(title: String, desc: String):
	if search_feedback:
		search_feedback.visible = true
		search_feedback.set_prompt(title, desc)

## Bright lab compare: board above shelves + label on the active shelf
func show_lab_compare(index: int, value: int, target: int):
	if search_feedback and search_feedback.has_method("show_lab_compare"):
		search_feedback.visible = true
		search_feedback.show_lab_compare(value, target, index)
	set_element_compare_text(index, "%d ≟ %d" % [value, target], Color(1.0, 0.9, 0.15))

func show_3d_question(title: String, question_text: String, options: Array, color: Color = Color(0.0, 0.9, 1.0)):
	if search_feedback and search_feedback.has_method("show_3d_question"):
		search_feedback.visible = true
		search_feedback.show_3d_question(title, question_text, options, color)

func hide_3d_question():
	if search_feedback and search_feedback.has_method("clear_3d_question"):
		search_feedback.clear_3d_question()

func set_element_compare_text(index: int, text: String, color: Color = Color(1, 1, 1)):
	for element in element_bodies:
		if is_instance_valid(element) and element.get_meta("array_index", -1) == index:
			var label = element.get_node_or_null("CompareText")
			if label:
				label.text = text
				label.modulate = color
				label.font_size = 48
				label.outline_size = 14
			break

func set_element_state(index: int, state: String):
	for element in element_bodies:
		if is_instance_valid(element) and element.get_meta("array_index", -1) == index:
			var mesh = element.get_node_or_null("ElementBody")
			var collision = element.get_node_or_null("ElementCollision")
			if mesh:
				match state:
					"active": mesh.material_override = active_material
					"locked": mesh.material_override = locked_material
					"normal":
						if index in sorted_indices:
							mesh.material_override = sorted_material
						else:
							mesh.material_override = normal_material
					"correct", "sorted": mesh.material_override = sorted_material
					"comparing": mesh.material_override = comparing_material
					"wrong": mesh.material_override = wrong_material
					"hover": mesh.material_override = hover_material
					"checked": mesh.material_override = checked_material
			if collision:
				collision.disabled = (state == "locked")
			break

func set_sorting_mode(enabled: bool):
	is_sorting_mode = enabled
	is_binary_search = false
	sorted_indices.clear()
	if search_pointer:
		search_pointer.visible = false
	if search_target:
		search_target.visible = false
	if search_trail:
		search_trail.clear_trail()
	if search_feedback:
		search_feedback.visible = enabled
		if enabled:
			search_feedback.set_prompt("✦ BUBBLE SORT PROTOCOL ✦", "Compare adjacent pairs • Swap if left > right")
	if enabled:
		for element in element_bodies:
			if is_instance_valid(element):
				var mesh = element.get_node_or_null("ElementBody")
				if mesh: mesh.material_override = normal_material
				var collision = element.get_node_or_null("ElementCollision")
				if collision: collision.disabled = false
				var compare_label = element.get_node_or_null("CompareText")
				if compare_label: compare_label.text = ""

func highlight_bubble_pair(idx1: int, idx2: int, val1: int, val2: int):
	set_element_state(idx1, "comparing")
	set_element_state(idx2, "comparing")
	set_element_compare_text(idx1, str(val1), Color(1.0, 0.7, 0.2))
	set_element_compare_text(idx2, str(val2), Color(1.0, 0.7, 0.2))
	if search_feedback:
		search_feedback.set_prompt("✦ COMPARING: [%d] vs [%d] ✦" % [val1, val2], "Shelf %d (%d) ⟷ Shelf %d (%d)" % [idx1, val1, idx2, val2])

func clear_bubble_pair(idx1: int, idx2: int):
	if idx1 in sorted_indices:
		set_element_state(idx1, "sorted")
		set_element_compare_text(idx1, "SORTED ✓", Color(0.2, 1.0, 0.45))
	else:
		set_element_state(idx1, "normal")
		set_element_compare_text(idx1, "")

	if idx2 in sorted_indices:
		set_element_state(idx2, "sorted")
		set_element_compare_text(idx2, "SORTED ✓", Color(0.2, 1.0, 0.45))
	else:
		set_element_state(idx2, "normal")
		set_element_compare_text(idx2, "")

func mark_element_sorted(index: int):
	if not sorted_indices.has(index):
		sorted_indices.append(index)
	set_element_state(index, "sorted")
	set_element_compare_text(index, "SORTED ✓", Color(0.2, 1.0, 0.45))

func celebrate_array_sorted():
	for i in range(element_bodies.size()):
		mark_element_sorted(i)
	if search_feedback:
		search_feedback.set_prompt("✦ ARCHIVE FULLY SORTED! ✦", "All elements in ascending order • Equilibrium restored!", Color(0.2, 1.0, 0.45))
	if is_inside_tree() and get_tree() != null:
		var audio = get_node_or_null("/root/AudioManager")
		if audio and audio.has_method("play_success_sound"):
			audio.play_success_sound()
		for i in range(element_bodies.size()):
			var el = element_bodies[i]
			if is_instance_valid(el):
				var tween = create_tween()
				tween.tween_property(el, "position:y", el.position.y + 0.35, 0.22).set_delay(i * 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(el, "position:y", el.position.y, 0.22).set_ease(Tween.EASE_IN_OUT)

func swap_elements(index1: int, index2: int, duration: float = 0.5) -> Tween:
	if index1 < 0 or index1 >= element_bodies.size() or index2 < 0 or index2 >= element_bodies.size():
		return null
	var el1 = element_bodies[index1]
	var el2 = element_bodies[index2]
	if not is_instance_valid(el1) or not is_instance_valid(el2):
		return null

	var pos1 = el1.position
	var pos2 = el2.position

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(el1, "position:x", pos2.x, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(el2, "position:x", pos1.x, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	element_bodies[index1] = el2
	element_bodies[index2] = el1
	var temp_val = values[index1]
	values[index1] = values[index2]
	values[index2] = temp_val

	el1.set_meta("array_index", index2)
	el2.set_meta("array_index", index1)

	var idx_lbl1 = el1.get_node_or_null("Index")
	var idx_lbl2 = el2.get_node_or_null("Index")
	if idx_lbl1: idx_lbl1.text = "INDEX %d" % index2
	if idx_lbl2: idx_lbl2.text = "INDEX %d" % index1

	return tween
