extends Node3D
class_name ChefAI

# ==============================================================================
# CHEF AI — Persistent Narrative Robot Companion
# ==============================================================================
# A physical hovering robot that stays in the kitchen throughout gameplay.
# Performs an onboarding demo on spawn, then floats to its perch and idles,
# surfacing mission-relevant dialogue on a floating panel above its head.
# ==============================================================================

# --- Robot parts for animation ---
var _visor_mat: StandardMaterial3D
var _antenna_mat: StandardMaterial3D
var _dialogue_label: Label3D
var _dialogue_panel: MeshInstance3D

# --- Idle state ---
var _base_y: float = 1.8
var _time: float = 0.0
var _perch_pos := Vector3(-5.5, 1.8, -1.0)
var _is_perched := false

# --- Demo token reference ---
var _demo_token

func _ready():
	_build_robot_body()
	_build_dialogue_panel()

	# Position away during demo, then float to perch after
	global_position = Vector3(-5.5, 3.5, 1.5)

	# Kick off the demo after a short delay
	get_tree().create_timer(3.0).timeout.connect(_play_demo)

	# Listen for mission changes to update dialogue
	if Missions.has_signal("mission_started"):
		Missions.mission_started.connect(_on_mission_started)

	# Show current mission text immediately
	_refresh_dialogue()


func _process(delta: float) -> void:
	_time += delta

	if _is_perched:
		# Idle hover bob
		position.y = _base_y + sin(_time * 1.2) * 0.08
		# Lazy y-rotation to slowly face the player area
		rotation_degrees.y = sin(_time * 0.3) * 12.0

	# Animate visor emissive pulse
	if _visor_mat:
		var pulse = (sin(_time * 3.0) * 0.5 + 0.5) # 0..1
		_visor_mat.emission_energy_multiplier = lerp(1.2, 2.8, pulse)

	# Animate antenna tip fast pulse
	if _antenna_mat:
		var fast_pulse = (sin(_time * 7.0) * 0.5 + 0.5)
		_antenna_mat.emission_energy_multiplier = lerp(0.5, 4.0, fast_pulse)


# ------------------------------------------------------------------------------
# Robot body construction
# ------------------------------------------------------------------------------
func _build_robot_body() -> void:
	# --- Torso ---
	var torso = MeshInstance3D.new()
	var torso_m = CapsuleMesh.new()
	torso_m.radius = 0.18
	torso_m.height = 0.55
	torso.mesh = torso_m
	var torso_mat = StandardMaterial3D.new()
	torso_mat.albedo_color = Color(0.72, 0.45, 0.18)
	torso_mat.metallic = 0.92
	torso_mat.roughness = 0.22
	torso.material_override = torso_mat
	torso.position = Vector3(0, 0, 0)
	add_child(torso)

	# --- Head ---
	var head = MeshInstance3D.new()
	var head_m = SphereMesh.new()
	head_m.radius = 0.22
	head_m.height = 0.44
	head.mesh = head_m
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.78, 0.50, 0.22)
	head_mat.metallic = 0.95
	head_mat.roughness = 0.18
	head.material_override = head_mat
	head.position = Vector3(0, 0.42, 0)
	add_child(head)

	# --- Visor band (emissive cyan) ---
	var visor = MeshInstance3D.new()
	var visor_m = BoxMesh.new()
	visor_m.size = Vector3(0.36, 0.07, 0.38)
	visor.mesh = visor_m
	_visor_mat = StandardMaterial3D.new()
	_visor_mat.albedo_color = Color(0.05, 0.85, 1.0)
	_visor_mat.emission_enabled = true
	_visor_mat.emission = Color(0.1, 0.9, 1.0)
	_visor_mat.emission_energy_multiplier = 2.0
	visor.material_override = _visor_mat
	visor.position = Vector3(0, 0.43, 0.16)
	add_child(visor)

	# --- Antenna (thin rod + tip ball) ---
	var ant_rod = MeshInstance3D.new()
	var ant_rod_m = CylinderMesh.new()
	ant_rod_m.top_radius = 0.014
	ant_rod_m.bottom_radius = 0.014
	ant_rod_m.height = 0.28
	ant_rod.mesh = ant_rod_m
	var ant_mat = StandardMaterial3D.new()
	ant_mat.albedo_color = Color(0.65, 0.42, 0.18)
	ant_mat.metallic = 0.9
	ant_mat.roughness = 0.2
	ant_rod.material_override = ant_mat
	ant_rod.position = Vector3(0, 0.78, 0)
	add_child(ant_rod)

	var ant_ball = MeshInstance3D.new()
	var ant_ball_m = SphereMesh.new()
	ant_ball_m.radius = 0.04
	ant_ball_m.height = 0.08
	ant_ball.mesh = ant_ball_m
	_antenna_mat = StandardMaterial3D.new()
	_antenna_mat.albedo_color = Color(0.2, 1.0, 0.5)
	_antenna_mat.emission_enabled = true
	_antenna_mat.emission = Color(0.2, 1.0, 0.5)
	_antenna_mat.emission_energy_multiplier = 2.5
	ant_ball.material_override = _antenna_mat
	ant_ball.position = Vector3(0, 0.94, 0)
	add_child(ant_ball)

	# --- Left arm stub ---
	var arm_l = MeshInstance3D.new()
	var arm_m = CapsuleMesh.new()
	arm_m.radius = 0.065
	arm_m.height = 0.32
	arm_l.mesh = arm_m
	var arm_mat = StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.68, 0.42, 0.16)
	arm_mat.metallic = 0.88
	arm_mat.roughness = 0.3
	arm_l.material_override = arm_mat
	arm_l.position = Vector3(-0.28, 0.05, 0)
	arm_l.rotation_degrees = Vector3(0, 0, 25)
	add_child(arm_l)

	# --- Right arm stub ---
	var arm_r = arm_l.duplicate()
	arm_r.position = Vector3(0.28, 0.05, 0)
	arm_r.rotation_degrees = Vector3(0, 0, -25)
	add_child(arm_r)


# ------------------------------------------------------------------------------
# Floating dialogue panel
# ------------------------------------------------------------------------------
func _build_dialogue_panel() -> void:
	_dialogue_panel = MeshInstance3D.new()
	var panel_m = BoxMesh.new()
	panel_m.size = Vector3(1.4, 0.6, 0.04)
	_dialogue_panel.mesh = panel_m
	var panel_mat = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.05, 0.06, 0.12)
	panel_mat.roughness = 0.6
	panel_mat.metallic = 0.3
	_dialogue_panel.material_override = panel_mat
	_dialogue_panel.position = Vector3(0, 1.35, 0)
	add_child(_dialogue_panel)

	# Panel border glow strip (top edge)
	var border = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = Vector3(1.4, 0.035, 0.045)
	border.mesh = bm
	var border_mat = StandardMaterial3D.new()
	border_mat.albedo_color = Color(0.1, 0.8, 1.0)
	border_mat.emission_enabled = true
	border_mat.emission = Color(0.1, 0.8, 1.0)
	border_mat.emission_energy_multiplier = 2.0
	border.material_override = border_mat
	border.position = Vector3(0, 0.32, 0)
	_dialogue_panel.add_child(border)

	# The label itself
	_dialogue_label = Label3D.new()
	_dialogue_label.font_size = 22
	_dialogue_label.outline_size = 6
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.width = 420
	_dialogue_label.modulate = Color(0.7, 1.0, 0.9)
	_dialogue_label.position = Vector3(0, 0, 0.03)
	_dialogue_panel.add_child(_dialogue_label)


# ------------------------------------------------------------------------------
# Dialogue
# ------------------------------------------------------------------------------
func _refresh_dialogue() -> void:
	if not _dialogue_label:
		return
	var mission = Missions.get_current_mission() if Missions else null
	if mission:
		# Show a short contextual hint derived from the mission
		_dialogue_label.text = "CHEF-7: " + _get_hint(mission)
	else:
		_dialogue_label.text = "CHEF-7: Hello, Chef! Welcome to the Kitchen Lab."


func _get_hint(mission) -> String:
	match mission.unit_number:
		0:
			return "Let me show you the ropes! Watch closely."
		1:
			return "Variables are your ingredients. Pick carefully!"
		2:
			return "Conditionals shape the recipe's path. Think before you branch!"
		3:
			return "Loops: the secret to efficient cooking. Don't burn the pot!"
		4:
			return "Complex logic unlocks advanced recipes. You've got this!"
		5:
			return "The final course! Return the right value and you graduate."
		_:
			return mission.problem_statement.substr(0, 80)


func _on_mission_started(_mission) -> void:
	_refresh_dialogue()


# ------------------------------------------------------------------------------
# Onboarding demo
# ------------------------------------------------------------------------------
func _play_demo() -> void:
	print("CHEF AI: Starting onboarding demonstration...")

	# Lean toward the cooking pot visually
	var lean_tween = create_tween()
	lean_tween.tween_property(self, "rotation_degrees", Vector3(15, -30, 0), 0.5)

	# Spawn demo token
	_demo_token = HardwareCartridge.new()
	_demo_token.cartridge_type = HardwareCartridge.CartridgeType.DATA_TYPE
	_demo_token.token_name = "DEMO"
	add_child(_demo_token)
	_demo_token.position = Vector3(0, -0.6, 0.3)
	_demo_token.freeze = true
	_demo_token.remove_from_group("grabbable")

	# Float toward cooking pot at (0, 1.8, -3.0)
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector3(0, 3.0, -3.0), 2.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_drop_token)

	# Return to perch: set_delay must chain directly off tween_property before set_trans
	tween.tween_property(self, "global_position", _perch_pos + Vector3(0, 0.5, 0), 2.8)\
		.set_delay(1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_arrive_at_perch)


func _drop_token() -> void:
	if is_instance_valid(_demo_token):
		var gp = _demo_token.global_position
		remove_child(_demo_token)
		get_tree().root.get_child(0).add_child(_demo_token)
		_demo_token.global_position = gp
		_demo_token.add_to_group("grabbable")
		_demo_token.freeze = false
		_demo_token.gravity_scale = 1.0
		_demo_token.apply_central_impulse(Vector3(0, -1.0, 0))

	# Reset lean
	var untween = create_tween()
	untween.tween_property(self, "rotation_degrees", Vector3.ZERO, 0.6)


func _arrive_at_perch() -> void:
	_is_perched = true
	_base_y = _perch_pos.y
	# Ensure exact final position
	global_position = _perch_pos
