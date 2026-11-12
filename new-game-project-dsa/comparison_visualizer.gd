## ============================================================
## COMPARISON VISUALIZER (3D Holographic Comparison Engine)
## ============================================================
## Animates values in 3D world space when an element is checked:
## Value vs Target -> Equality/Inequality symbol -> State feedback.
## Keeps student informed without freezing gameplay or blocking view.
## ============================================================

extends Node3D
class_name ComparisonVisualizer

var badge_node: Node3D
var label: Label3D
var background_box: MeshInstance3D
var border_mesh: MeshInstance3D
var border_mat: StandardMaterial3D
var light: OmniLight3D
var _active_tween: Tween = null

const C_MISMATCH := Color(1.0, 0.35, 0.35)
const C_MATCH := Color(0.2, 1.0, 0.45)
const C_NEUTRAL := Color(0.0, 0.85, 1.0)

func _ready():
	_ensure_built()

func _ensure_built():
	if badge_node != null:
		return

	badge_node = Node3D.new()
	badge_node.name = "ComparisonBadge"
	add_child(badge_node)

	# Holographic border
	border_mesh = MeshInstance3D.new()
	var b_quad := QuadMesh.new()
	b_quad.size = Vector2(1.86, 0.74)
	border_mesh.mesh = b_quad
	border_mat = StandardMaterial3D.new()
	border_mat.albedo_color = Color(0.0, 0.75, 1.0, 0.7)
	border_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	border_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	border_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	border_mat.billboard_keep_scale = true
	border_mat.render_priority = 14
	border_mesh.material_override = border_mat
	badge_node.add_child(border_mesh)

	# Holographic Card Background
	background_box = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.8, 0.68)
	background_box.mesh = quad
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.02, 0.05, 0.12, 0.88)
	bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	bg_mat.billboard_keep_scale = true
	bg_mat.render_priority = 15
	background_box.material_override = bg_mat
	badge_node.add_child(background_box)

	# Comparison Text Label
	label = Label3D.new()
	label.name = "ComparisonLabel"
	label.font_size = 38
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 16
	label.pixel_size = 0.003
	label.position = Vector3(0, 0, 0.02)
	badge_node.add_child(label)

	# Flash light
	light = OmniLight3D.new()
	light.light_energy = 0.0
	light.omni_range = 3.0
	badge_node.add_child(light)

	badge_node.visible = false

func show_comparison(world_pos: Vector3, value: int, target: int, is_match: bool, duration: float = 0.8):
	_ensure_built()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

	badge_node.visible = true
	badge_node.position = world_pos + Vector3(0, 1.1, 0)
	badge_node.scale = Vector3(0.3, 0.3, 0.3)

	if is_match:
		label.text = "%d  =  %d\n✓ MATCH FOUND" % [value, target]
		label.modulate = C_MATCH
		label.outline_modulate = Color(0.02, 0.15, 0.05)
		light.light_color = C_MATCH
		light.light_energy = 1.8
		if border_mat:
			border_mat.albedo_color = Color(0.2, 1.0, 0.45, 0.8)
	else:
		label.text = "%d  ≠  %d\n✗ NO MATCH" % [value, target]
		label.modulate = C_MISMATCH
		label.outline_modulate = Color(0.15, 0.02, 0.02)
		light.light_color = C_MISMATCH
		light.light_energy = 1.0
		if border_mat:
			border_mat.albedo_color = Color(1.0, 0.35, 0.35, 0.6)

	if is_inside_tree() and get_tree() != null:
		_active_tween = create_tween()
		if _active_tween != null:
			_active_tween.set_parallel(true)
			_active_tween.tween_property(badge_node, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_active_tween.tween_property(badge_node, "position:y", badge_node.position.y + 0.3, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
			if not is_match:
				var fade = _active_tween.chain()
				fade.tween_interval(duration * 0.4)
				fade.tween_property(badge_node, "scale", Vector3(0.01, 0.01, 0.01), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				fade.tween_callback(func():
					if is_instance_valid(badge_node):
						badge_node.visible = false
				)
			else:
				var pop = _active_tween.chain()
				pop.tween_property(badge_node, "scale", Vector3(1.15, 1.15, 1.15), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				pop.tween_interval(1.4)
				pop.tween_property(badge_node, "scale", Vector3(0.01, 0.01, 0.01), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				pop.tween_callback(func():
					if is_instance_valid(badge_node):
						badge_node.visible = false
				)
	else:
		badge_node.scale = Vector3.ONE

func hide_comparison():
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	if badge_node and is_instance_valid(badge_node):
		badge_node.visible = false
