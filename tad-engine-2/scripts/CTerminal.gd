extends Node3D

# ============================================================
# C-TERMINAL — Engine 2, Automation Foundry
# A real, physical computer screen inside the 3D world!
# ============================================================

var screen_mesh: MeshInstance3D
var screen_material: StandardMaterial3D
var terminal_light: OmniLight3D
@onready var ui_viewport: SubViewport = $ScreenViewport

enum TerminalState { IDLE, ACTIVE, COMPILING, SUCCESS, ERROR, LOCKDOWN }
var state: TerminalState = TerminalState.IDLE
var pulse_time: float = 0.0

func _ready() -> void:
	_build_terminal_geometry()
	
	# Paint the UI onto the physical 3D glass
	var vp_tex = ui_viewport.get_texture()
	screen_material.albedo_texture = vp_tex
	screen_material.emission_texture = vp_tex
	
	_set_terminal_state(TerminalState.IDLE)


# Funnel all keyboard typing directly into the 3D screen
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		ui_viewport.push_input(event)


# Translate mouse clicks in the 3D world to the 2D interface
func _on_screen_input(_camera: Node, event: InputEvent, intersect_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var local_pos = screen_mesh.to_local(intersect_pos)
	var uv_x = (local_pos.x + 1.0) / 2.0
	var uv_y = 1.0 - ((local_pos.y + 0.55) / 1.1) 
	var vp_pos = Vector2(uv_x * 1920.0, uv_y * 1080.0)
	
	if event is InputEventMouse:
		var clone = event.duplicate()
		clone.position = vp_pos
		if clone is InputEventMouseButton or clone is InputEventMouseMotion:
			clone.global_position = vp_pos
		ui_viewport.push_input(clone)


func _build_terminal_geometry() -> void:
	var metal_mat := StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.18, 0.18, 0.22)
	metal_mat.metallic = 0.95
	metal_mat.roughness = 0.2

	var desk := MeshInstance3D.new()
	var desk_box := BoxMesh.new()
	desk_box.size = Vector3(2.5, 0.1, 1.2)
	desk.mesh = desk_box
	desk.position = Vector3(0, 0.9, 0)
	desk.set_surface_override_material(0, metal_mat)
	add_child(desk)

	for leg_x in [-1.1, 1.1]:
		for leg_z in [-0.5, 0.5]:
			var leg := MeshInstance3D.new()
			var leg_box := BoxMesh.new()
			leg_box.size = Vector3(0.1, 0.9, 0.1)
			leg.mesh = leg_box
			leg.position = Vector3(leg_x, 0.45, leg_z)
			leg.set_surface_override_material(0, metal_mat)
			add_child(leg)

	var stand := MeshInstance3D.new()
	var stand_box := BoxMesh.new()
	stand_box.size = Vector3(0.08, 0.5, 0.08)
	stand.mesh = stand_box
	stand.position = Vector3(0, 1.2, -0.3)
	stand.set_surface_override_material(0, metal_mat)
	add_child(stand)

	var screen_back := MeshInstance3D.new()
	var back_box := BoxMesh.new()
	back_box.size = Vector3(2.1, 1.2, 0.1)
	screen_back.mesh = back_box
	screen_back.position = Vector3(0, 1.8, -0.35)
	screen_back.set_surface_override_material(0, metal_mat)
	add_child(screen_back)

	screen_mesh = MeshInstance3D.new()
	var screen_quad := QuadMesh.new()
	screen_quad.size = Vector2(2.0, 1.1)
	screen_mesh.mesh = screen_quad
	screen_mesh.position = Vector3(0, 1.8, -0.29)
	
	screen_material = StandardMaterial3D.new()
	screen_material.albedo_color = Color.BLACK
	screen_material.emission_enabled = true
	screen_material.emission = Color.WHITE
	screen_material.emission_energy_multiplier = 1.0
	screen_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	screen_mesh.set_surface_override_material(0, screen_material)
	add_child(screen_mesh)
	
	var click_area := Area3D.new()
	var coll := CollisionShape3D.new()
	var coll_shape := BoxShape3D.new()
	coll_shape.size = Vector3(2.0, 1.1, 0.1)
	coll.shape = coll_shape
	click_area.add_child(coll)
	screen_mesh.add_child(click_area)
	click_area.input_event.connect(_on_screen_input)

	var kb := MeshInstance3D.new()
	var kb_box := BoxMesh.new()
	kb_box.size = Vector3(1.6, 0.04, 0.5)
	kb.mesh = kb_box
	kb.position = Vector3(0, 0.97, 0.2)
	var kb_mat := StandardMaterial3D.new()
	kb_mat.albedo_color = Color(0.1, 0.1, 0.12)
	kb_mat.metallic = 0.4
	kb.set_surface_override_material(0, kb_mat)
	add_child(kb)

	terminal_light = OmniLight3D.new()
	terminal_light.position = Vector3(0, 2.0, 0)
	terminal_light.light_color = Color(0.0, 1.0, 0.4)
	terminal_light.light_energy = 1.0
	terminal_light.omni_range = 4.0
	add_child(terminal_light)

func _process(delta: float) -> void:
	pulse_time += delta
	match state:
		TerminalState.IDLE:
			screen_material.emission_energy_multiplier = 0.7 + sin(pulse_time * 0.8) * 0.1
			terminal_light.light_energy = 0.6 + sin(pulse_time * 0.8) * 0.2
		TerminalState.ACTIVE:
			screen_material.emission_energy_multiplier = 1.0 + sin(pulse_time * 3.0) * 0.2
			terminal_light.light_energy = 2.0 + sin(pulse_time * 2.0) * 0.5
		TerminalState.COMPILING:
			screen_material.emission_energy_multiplier = 2.0 + sin(pulse_time * 10.0) * 1.0
			terminal_light.light_energy = 3.0 + sin(pulse_time * 12.0) * 1.0
		TerminalState.ERROR, TerminalState.LOCKDOWN:
			screen_material.emission_energy_multiplier = 2.0 + sin(pulse_time * 8.0) * 1.5
			terminal_light.light_energy = 3.0
		TerminalState.SUCCESS:
			screen_material.emission_energy_multiplier = 3.0 + sin(pulse_time * 4.0) * 0.5
			terminal_light.light_energy = 4.0

func _set_terminal_state(new_state: TerminalState) -> void:
	state = new_state
	match new_state:
		TerminalState.IDLE:
			terminal_light.light_color = Color(0.0, 1.0, 0.4)
		TerminalState.ACTIVE:
			terminal_light.light_color = Color(0.0, 1.0, 0.5)
		TerminalState.COMPILING:
			terminal_light.light_color = Color(0.5, 1.0, 0.8)
		TerminalState.SUCCESS:
			terminal_light.light_color = Color(0.0, 1.0, 0.4)
		TerminalState.ERROR, TerminalState.LOCKDOWN:
			terminal_light.light_color = Color(1.0, 0.1, 0.0)

func on_compile_start() -> void: _set_terminal_state(TerminalState.COMPILING)
func on_compile_success() -> void:
	_set_terminal_state(TerminalState.SUCCESS)
	await get_tree().create_timer(3.0).timeout
	_set_terminal_state(TerminalState.ACTIVE)
func on_compile_error() -> void:
	_set_terminal_state(TerminalState.ERROR)
	await get_tree().create_timer(2.0).timeout
	_set_terminal_state(TerminalState.ACTIVE)
func on_lockdown() -> void: _set_terminal_state(TerminalState.LOCKDOWN)
func on_lockdown_end() -> void: _set_terminal_state(TerminalState.ACTIVE)
func on_player_approach() -> void: _set_terminal_state(TerminalState.ACTIVE)
