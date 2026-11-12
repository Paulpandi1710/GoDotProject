## ============================================================
## SEARCH POINTER (3D Holographic Search Pointer)
## ============================================================
## Reusable pointer component indicating the current active search
## position. Moves smoothly with a cubic tween between elements,
## pointing directly toward the active candidate node.
## ============================================================

extends Node3D
class_name SearchPointer

var arrow_mesh: MeshInstance3D
var ring_mesh: MeshInstance3D
var label: Label3D
var pointer_light: OmniLight3D
var time_elapsed: float = 0.0

const C_CYAN := Color(0.0, 0.90, 1.0)
const C_CYAN_GLOW := Color(0.3, 1.0, 1.0)

func _init():
	_ensure_built()

func _ready():
	_ensure_built()

func _ensure_built():
	if arrow_mesh != null:
		return

	# Inverted downward-pointing cone / arrow
	arrow_mesh = MeshInstance3D.new()
	arrow_mesh.name = "ArrowMesh"
	var cone := CylinderMesh.new()
	cone.top_radius = 0.28
	cone.bottom_radius = 0.02
	cone.height = 0.65
	arrow_mesh.mesh = cone

	var arrow_mat := StandardMaterial3D.new()
	arrow_mat.albedo_color = C_CYAN
	arrow_mat.emission_enabled = true
	arrow_mat.emission = C_CYAN
	arrow_mat.emission_energy_multiplier = 0.6
	arrow_mat.metallic = 0.5
	arrow_mat.roughness = 0.15
	arrow_mesh.material_override = arrow_mat
	arrow_mesh.position = Vector3(0, 0.35, 0)
	# Invert cone so sharp point faces down
	arrow_mesh.rotation_degrees = Vector3(180, 0, 0)
	add_child(arrow_mesh)

	# Floating cyan pulsing ring around the arrow top
	ring_mesh = MeshInstance3D.new()
	ring_mesh.name = "PointerRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.36
	torus.outer_radius = 0.42
	ring_mesh.mesh = torus

	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = C_CYAN_GLOW
	ring_mat.emission_enabled = true
	ring_mat.emission = C_CYAN_GLOW
	ring_mat.emission_energy_multiplier = 0.7
	ring_mesh.material_override = ring_mat
	ring_mesh.position = Vector3(0, 0.70, 0)
	add_child(ring_mesh)

	# Pointer Status Label
	label = Label3D.new()
	label.name = "PointerLabel"
	label.text = "SCANNING"
	label.font_size = 28
	label.modulate = C_CYAN
	label.outline_size = 8
	label.outline_modulate = Color(0.01, 0.02, 0.05)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 14
	label.pixel_size = 0.0022
	label.position = Vector3(0, 1.15, 0)
	add_child(label)

	# Dedicated Point Light
	pointer_light = OmniLight3D.new()
	pointer_light.light_color = C_CYAN
	pointer_light.light_energy = 1.0
	pointer_light.omni_range = 3.5
	pointer_light.position = Vector3(0, 0.3, 0)
	add_child(pointer_light)

func _process(delta: float):
	time_elapsed += delta
	var bob = sin(time_elapsed * 3.5) * 0.04
	if arrow_mesh:
		arrow_mesh.position.y = 0.35 + bob
	if ring_mesh:
		ring_mesh.position.y = 0.70 + bob
		ring_mesh.rotate_y(1.8 * delta)

func move_to_target(target_pos: Vector3, duration: float = 0.4):
	_ensure_built()
	if is_inside_tree() and get_tree() != null:
		var tween = create_tween()
		if tween != null:
			tween.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		position = target_pos

func set_index(index: int):
	_ensure_built()
	if label:
		label.text = "INDEX %d" % index

func pulse_mismatch():
	_ensure_built()
	if arrow_mesh and is_instance_valid(arrow_mesh) and is_inside_tree() and get_tree() != null:
		var tween = create_tween()
		if tween != null:
			tween.tween_property(arrow_mesh, "scale", Vector3.ONE * 1.25, 0.15)
			tween.tween_property(arrow_mesh, "scale", Vector3.ONE, 0.2)

func pulse_match():
	_ensure_built()
	if label:
		label.text = "MATCH!"
		label.modulate = Color(0.2, 1.0, 0.4)
	if pointer_light:
		pointer_light.light_color = Color(0.2, 1.0, 0.4)
