extends Node3D

# ============================================================
# FACTORY FLOOR — Engine 2, Automation Foundry
# Procedurally builds the entire 3D factory environment
# All scales are computed via code — no manual Inspector scaling
# ============================================================

@export var floor_width: float = 24.0
@export var floor_depth: float = 30.0
@export var wall_height: float = 8.0
@export var num_robotic_arms: int = 6
@export var num_conveyor_belts: int = 3
@export var pillar_count: int = 8

var screen_scale: Vector3 = Vector3.ONE


func _ready() -> void:
	_compute_screen_scale()
	_build_floor_and_walls()
	_build_pillars()
	_build_ceiling_lights()
	_build_walkway()
	_build_catwalks()
	_populate_conveyor_belts()
	_populate_robotic_arms()
	_build_ambient_details()


# ── Compute scale from screen size ─────────────────────────
func _compute_screen_scale() -> void:
	var screen: Vector2i = DisplayServer.window_get_size()
	var sx: float = float(screen.x) / 1920.0
	var sy: float = float(screen.y) / 1080.0
	var s: float = min(sx, sy)
	screen_scale = Vector3(s, s, s).clamp(Vector3(0.6, 0.6, 0.6), Vector3(1.5, 1.5, 1.5))
	scale = screen_scale


# ── Floor, Walls, Ceiling ──────────────────────────────────
func _build_floor_and_walls() -> void:
	var mats := _make_industrial_material(Color(0.12, 0.12, 0.14), 0.8, 0.6)

	# Floor
	_add_box(Vector3(floor_width, 0.3, floor_depth), Vector3(0, -0.15, 0), mats)

	# Ceiling
	var ceil_mat := _make_industrial_material(Color(0.08, 0.08, 0.1), 0.6, 0.8)
	_add_box(Vector3(floor_width, 0.3, floor_depth), Vector3(0, wall_height + 0.15, 0), ceil_mat)

	# Back wall
	var wall_mat := _make_industrial_material(Color(0.1, 0.1, 0.13), 0.7, 0.5)
	_add_box(Vector3(floor_width, wall_height, 0.4), Vector3(0, wall_height / 2.0, -floor_depth / 2.0), wall_mat)

	# Left wall
	_add_box(Vector3(0.4, wall_height, floor_depth), Vector3(-floor_width / 2.0, wall_height / 2.0, 0), wall_mat)

	# Right wall
	_add_box(Vector3(0.4, wall_height, floor_depth), Vector3(floor_width / 2.0, wall_height / 2.0, 0), wall_mat)

	# Floor grid lines
	_add_floor_grid()


func _add_floor_grid() -> void:
	var line_mat := _make_industrial_material(Color(0.2, 0.4, 0.2), 0.0, 1.0)
	for i in range(-5, 6):
		_add_box(Vector3(floor_width, 0.02, 0.05), Vector3(0, 0.01, float(i) * 2.5), line_mat)
		_add_box(Vector3(0.05, 0.02, floor_depth), Vector3(float(i) * 2.5, 0.01, 0), line_mat)


# ── Pillars ────────────────────────────────────────────────
func _build_pillars() -> void:
	var pillar_mat := _make_industrial_material(Color(0.18, 0.18, 0.22), 0.9, 0.2)
	var positions := [
		Vector3(-9, 0, -12), Vector3(9, 0, -12),
		Vector3(-9, 0, -4),  Vector3(9, 0, -4),
		Vector3(-9, 0,  4),  Vector3(9, 0,  4),
		Vector3(-9, 0,  12), Vector3(9, 0,  12),
	]
	for pos in positions:
		# pillar mesh — return value not needed, suppress unused-var warning
		_add_box(Vector3(0.8, wall_height, 0.8), pos + Vector3(0, wall_height / 2.0, 0), pillar_mat)
		# Warning stripes at base
		var stripe_mat := _make_industrial_material(Color(0.9, 0.6, 0.0), 0.0, 0.8)
		_add_box(Vector3(0.82, 0.15, 0.82), pos + Vector3(0, 0.15, 0), stripe_mat)
		_add_box(Vector3(0.82, 0.15, 0.82), pos + Vector3(0, 0.55, 0), stripe_mat)

		# Pillar light
		var light := OmniLight3D.new()
		light.light_color = Color(0.8, 0.9, 1.0)
		light.light_energy = 1.5
		light.omni_range = 5.0
		light.position = pos + Vector3(0, wall_height - 0.5, 0)
		add_child(light)


# ── Ceiling Industrial Lights ──────────────────────────────
func _build_ceiling_lights() -> void:
	var light_positions := [
		Vector3(-6, wall_height - 0.3, -8),
		Vector3( 6, wall_height - 0.3, -8),
		Vector3(-6, wall_height - 0.3,  0),
		Vector3( 6, wall_height - 0.3,  0),
		Vector3(-6, wall_height - 0.3,  8),
		Vector3( 6, wall_height - 0.3,  8),
		Vector3( 0, wall_height - 0.3, -14),
	]
	var fixture_mat := _make_industrial_material(Color(0.3, 0.3, 0.3), 0.8, 0.3)

	for pos in light_positions:
		# Fixture housing
		_add_box(Vector3(1.5, 0.15, 0.4), pos, fixture_mat)

		# Actual light
		var spot := SpotLight3D.new()
		spot.position = pos
		spot.rotation_degrees.x = -90
		spot.light_color = Color(0.85, 0.95, 1.0)
		spot.light_energy = 4.0
		spot.spot_angle = 40.0
		spot.spot_range = 12.0
		spot.shadow_enabled = true
		add_child(spot)

		# Emissive bulb
		var bulb := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.08
		sphere.height = 0.16
		bulb.mesh = sphere
		bulb.position = pos
		var bulb_mat := StandardMaterial3D.new()
		bulb_mat.albedo_color = Color.WHITE
		bulb_mat.emission_enabled = true
		bulb_mat.emission = Color(1.0, 0.95, 0.8)
		bulb_mat.emission_energy_multiplier = 5.0
		bulb.set_surface_override_material(0, bulb_mat)
		add_child(bulb)


# ── Walkway / Platform ─────────────────────────────────────
func _build_walkway() -> void:
	var walk_mat := _make_industrial_material(Color(0.2, 0.2, 0.25), 0.7, 0.5)
	# Raised platform where the terminal sits
	_add_box(Vector3(6.0, 0.3, 5.0), Vector3(0, 0.15, 12.0), walk_mat)

	# Steps up to platform
	for step in range(3):
		_add_box(Vector3(4.0, 0.1, 0.6), Vector3(0, step * 0.1, 9.5 + step * 0.6), walk_mat)

	# Guardrails
	var rail_mat := _make_industrial_material(Color(0.6, 0.6, 0.0), 0.9, 0.3)
	for side in [-2.8, 2.8]:
		_add_box(Vector3(0.06, 0.8, 5.0), Vector3(side, 0.7, 12.0), rail_mat)
	_add_box(Vector3(6.0, 0.06, 0.06), Vector3(0, 1.1, 9.6), rail_mat)


# ── Catwalks ───────────────────────────────────────────────
func _build_catwalks() -> void:
	var cat_mat := _make_industrial_material(Color(0.22, 0.22, 0.26), 0.8, 0.4)
	# Upper catwalk on left side
	_add_box(Vector3(1.2, 0.15, 20.0), Vector3(-10.5, 4.5, 0), cat_mat)
	_add_box(Vector3(1.2, 0.15, 20.0), Vector3( 10.5, 4.5, 0), cat_mat)

	# Hanging cables from ceiling
	var cable_mat := _make_industrial_material(Color(0.1, 0.1, 0.1), 0.0, 1.0)
	for x in [-8.0, -4.0, 0.0, 4.0, 8.0]:
		_add_box(Vector3(0.04, 4.0, 0.04), Vector3(x, wall_height - 2.0, -10.0), cable_mat)


# ── Conveyor Belts ─────────────────────────────────────────
func _populate_conveyor_belts() -> void:
	var conveyor_parent: Node3D = $ConveyorSystem if has_node("ConveyorSystem") else _make_child("ConveyorSystem")
	var positions := [
		Vector3(-5.0, 0.0, -4.0),
		Vector3( 0.0, 0.0,  0.0),
		Vector3( 5.0, 0.0,  4.0),
	]
	for i in range(num_conveyor_belts):
		var belt_scene_script := load("res://scripts/ConveyorBelt.gd")
		var belt := Node3D.new()
		belt.set_script(belt_scene_script)
		belt.name = "ConveyorBelt_%d" % i
		belt.position = positions[i % positions.size()]
		belt.rotation_degrees.y = 30.0 * i
		conveyor_parent.add_child(belt)


# ── Robotic Arms ───────────────────────────────────────────
func _populate_robotic_arms() -> void:
	var arms_parent: Node3D = $RoboticArms if has_node("RoboticArms") else _make_child("RoboticArms")
	var arm_script := load("res://scripts/RoboticArm.gd")

	var arm_colors := [
		Color(0.2, 0.4, 0.8),
		Color(0.8, 0.3, 0.1),
		Color(0.1, 0.7, 0.4),
		Color(0.7, 0.2, 0.7),
		Color(0.9, 0.7, 0.1),
		Color(0.1, 0.5, 0.9),
	]

	for i in range(num_robotic_arms):
		var arm := Node3D.new()
		arm.set_script(arm_script)
		arm.name = "RoboticArm_%d" % i

		# Spread arms across the factory floor in two rows
		var row := i / 3
		var col := i % 3
		arm.position = Vector3(-4.0 + col * 4.0, 0.0, -6.0 + row * 5.0)
		arm.set("arm_index", i)
		arm.set("base_color", arm_colors[i % arm_colors.size()])
		arms_parent.add_child(arm)


# ── Ambient Details ────────────────────────────────────────
func _build_ambient_details() -> void:
	# Server racks on back wall (visual only)
	var rack_mat := _make_industrial_material(Color(0.1, 0.12, 0.15), 0.9, 0.3)
	var led_mat := _make_industrial_material(Color(0.0, 1.0, 0.3), 0.0, 1.0)

	for rack in range(5):
		var rack_pos := Vector3(-8.0 + rack * 3.5, 0.0, -14.5)
		_add_box(Vector3(2.0, 4.5, 0.8), rack_pos + Vector3(0, 2.25, 0), rack_mat)
		# LED strips on each rack
		for led in range(6):
			_add_box(Vector3(1.6, 0.04, 0.05), rack_pos + Vector3(0, 0.4 + led * 0.6, 0.42), led_mat)

	# Pipes along left wall
	var pipe_mat := _make_industrial_material(Color(0.35, 0.25, 0.15), 0.7, 0.4)
	for h in [2.0, 4.0, 6.0]:
		_add_box(Vector3(0.2, 0.2, floor_depth), Vector3(-floor_width / 2.0 + 0.5, h, 0), pipe_mat)

	# Warning signs on walls
	var warn_mat := _make_industrial_material(Color(0.9, 0.6, 0.0), 0.0, 0.7)
	for z in [-8.0, 0.0, 8.0]:
		_add_box(Vector3(1.0, 0.6, 0.05), Vector3(-11.5, 2.0, z), warn_mat)


# ── Utility Functions ──────────────────────────────────────
func _add_box(size: Vector3, pos: Vector3, material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = pos
	if material != null:
		mesh_instance.set_surface_override_material(0, material)
	add_child(mesh_instance)
	return mesh_instance


func _make_industrial_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	return mat


func _make_child(child_name: String) -> Node3D:
	var node := Node3D.new()
	node.name = child_name
	add_child(node)
	return node
