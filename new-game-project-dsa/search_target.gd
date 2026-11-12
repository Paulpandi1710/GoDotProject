## ============================================================
## SEARCH TARGET (3D Holographic Target Beacon)
## ============================================================
## Represents the target data frequency the player must locate.
## Floats independently in the world, emitting a distinct gold
## signal beacon with animated energy rings and celebratory effects.
## ============================================================

extends Node3D
class_name SearchTarget

var target_value: int = 40
var base_position: Vector3 = Vector3(0, 0, 0)
var time_elapsed: float = 0.0
var is_found: bool = false

var core_mesh: MeshInstance3D
var ring_mesh: MeshInstance3D
var beam_mesh: MeshInstance3D
var value_label: Label3D
var title_label: Label3D
var beacon_light: OmniLight3D

const C_GOLD := Color(1.0, 0.78, 0.15)
const C_GOLD_GLOW := Color(1.0, 0.85, 0.3)
const C_GREEN_FOUND := Color(0.2, 1.0, 0.45)

func _init():
	_ensure_built()

func _ready():
	_ensure_built()

func _ensure_built():
	if core_mesh != null:
		return

	# Pedestal Base
	var base := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.65
	cyl.bottom_radius = 0.85
	cyl.height = 0.20
	base.mesh = cyl
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.04, 0.06, 0.10)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.2
	base.material_override = base_mat
	base.position = Vector3(0, 0.1, 0)
	add_child(base)

	# Glowing Pedestal Rim
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.64
	torus.outer_radius = 0.72
	rim.mesh = torus
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = C_GOLD
	rim_mat.emission_enabled = true
	rim_mat.emission = C_GOLD
	rim_mat.emission_energy_multiplier = 0.5
	rim.material_override = rim_mat
	rim.position = Vector3(0, 0.21, 0)
	add_child(rim)

	# Rotating Holographic Target Core (Prism/Octahedron)
	core_mesh = MeshInstance3D.new()
	core_mesh.name = "TargetCore"
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.70
	core_mesh.mesh = sphere
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = C_GOLD
	core_mat.emission_enabled = true
	core_mat.emission = C_GOLD
	core_mat.emission_energy_multiplier = 0.6
	core_mat.metallic = 0.4
	core_mat.roughness = 0.1
	core_mesh.material_override = core_mat
	core_mesh.position = Vector3(0, 1.15, 0)
	add_child(core_mesh)

	# Spinning Orbital Ring around Core
	ring_mesh = MeshInstance3D.new()
	var r_torus := TorusMesh.new()
	r_torus.inner_radius = 0.46
	r_torus.outer_radius = 0.52
	ring_mesh.mesh = r_torus
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = C_GOLD_GLOW
	ring_mat.emission_enabled = true
	ring_mat.emission = C_GOLD_GLOW
	ring_mat.emission_energy_multiplier = 0.7
	ring_mesh.material_override = ring_mat
	ring_mesh.position = Vector3(0, 1.15, 0)
	ring_mesh.rotation_degrees = Vector3(35, 0, 0)
	add_child(ring_mesh)

	# Vertical Beacon Beam (Activates on Found)
	beam_mesh = MeshInstance3D.new()
	beam_mesh.name = "BeaconBeam"
	var b_cyl := CylinderMesh.new()
	b_cyl.top_radius = 0.12
	b_cyl.bottom_radius = 0.28
	b_cyl.height = 5.0
	beam_mesh.mesh = b_cyl
	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.4)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = C_GOLD
	beam_mat.emission_energy_multiplier = 0.7
	beam_mesh.material_override = beam_mat
	beam_mesh.position = Vector3(0, 3.5, 0)
	beam_mesh.visible = false
	add_child(beam_mesh)

	# Light
	beacon_light = OmniLight3D.new()
	beacon_light.light_color = C_GOLD
	beacon_light.light_energy = 1.4
	beacon_light.omni_range = 6.0
	beacon_light.position = Vector3(0, 1.2, 0)
	add_child(beacon_light)

	# Target Value 3D Label
	value_label = Label3D.new()
	value_label.name = "TargetValueLabel"
	value_label.text = str(target_value)
	value_label.font_size = 72
	value_label.modulate = Color(1.0, 1.0, 1.0)
	value_label.outline_size = 14
	value_label.outline_modulate = Color(0.12, 0.08, 0.0)
	value_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	value_label.no_depth_test = true
	value_label.render_priority = 12
	value_label.pixel_size = 0.0032
	value_label.position = Vector3(0, 1.95, 0)
	add_child(value_label)

	# Target Title 3D Label
	title_label = Label3D.new()
	title_label.name = "TargetTitleLabel"
	title_label.text = "✦ TARGET SIGNAL ✦"
	title_label.font_size = 26
	title_label.modulate = C_GOLD
	title_label.outline_size = 8
	title_label.outline_modulate = Color(0.02, 0.02, 0.04)
	title_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title_label.no_depth_test = true
	title_label.render_priority = 12
	title_label.pixel_size = 0.0022
	title_label.position = Vector3(0, 2.30, 0)
	add_child(title_label)

func _process(delta: float):
	time_elapsed += delta
	if core_mesh:
		core_mesh.rotate_y(1.5 * delta)
		var bob = sin(time_elapsed * 2.8) * 0.04
		core_mesh.position.y = 1.15 + bob
		if ring_mesh:
			ring_mesh.position.y = 1.15 + bob
			ring_mesh.rotate_z(2.2 * delta)

	if is_found and beam_mesh and beam_mesh.visible:
		beam_mesh.rotate_y(3.0 * delta)

func set_target(value: int):
	_ensure_built()
	target_value = value
	is_found = false
	if value_label:
		value_label.text = str(target_value)
		value_label.modulate = Color(1.0, 1.0, 1.0)
	if title_label:
		title_label.text = "✦ TARGET SIGNAL ✦"
		title_label.modulate = C_GOLD
	if beam_mesh:
		beam_mesh.visible = false
	if beacon_light:
		beacon_light.light_color = C_GOLD
		beacon_light.light_energy = 1.4

func celebrate_found():
	_ensure_built()
	is_found = true
	if beam_mesh:
		beam_mesh.visible = true
	if beacon_light:
		beacon_light.light_color = C_GREEN_FOUND
		beacon_light.light_energy = 2.8
	if title_label:
		title_label.text = "✦ SIGNAL ACQUIRED! ✦"
		title_label.modulate = C_GREEN_FOUND
	if value_label:
		value_label.modulate = C_GREEN_FOUND

	if is_inside_tree() and get_tree() != null:
		var tween = create_tween()
		if tween != null and core_mesh != null:
			tween.set_parallel(true)
			tween.tween_property(core_mesh, "scale", Vector3.ONE * 1.4, 0.4).set_trans(Tween.TRANS_BACK)
			tween.tween_property(core_mesh, "scale", Vector3.ONE, 0.6).set_delay(0.4)

func reset():
	_ensure_built()
	is_found = false
	visible = false
	if beam_mesh:
		beam_mesh.visible = false
	if beacon_light:
		beacon_light.light_color = C_GOLD
		beacon_light.light_energy = 1.0
	if title_label:
		title_label.text = "✦ TARGET SIGNAL ✦"
		title_label.modulate = C_GOLD
	if value_label:
		value_label.modulate = Color(1.0, 1.0, 1.0)
	if core_mesh:
		core_mesh.scale = Vector3.ONE

