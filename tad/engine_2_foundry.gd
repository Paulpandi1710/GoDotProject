extends Node3D

# ============================================================
# ENGINE 2 - ITERATIVE LOGIC TRAINING ROOM (ENHANCED)
# ============================================================

var player: Node3D
var camera_pivot: Node3D
var camera: Camera3D

@export var move_speed: float = 6.0
@export var sprint_speed: float = 10.0
@export var mouse_sensitivity: float = 0.0025

var camera_pitch: float = 0.0
var mouse_captured: bool = false

# HACKING STATE
var is_hacking: bool = false
var is_unlocked: bool = false
var terminal_in_range: bool = false

# UI
var ui_layer: CanvasLayer
var code_input: TextEdit
var compile_button: Button
var interact_prompt: Label3D
var terminal_status: Label3D
var compiler_message: Label
var crosshair: ColorRect

# FACTORY
var vault_door: CSGBox3D
var laser_grid: Array[CSGCylinder3D] = []

# CONSTANTS
const PLAYER_HEIGHT: float = 1.6
const TERMINAL_POSITION := Vector3(0.0, 0.0, -2.0)
const TERMINAL_INTERACTION_DISTANCE: float = 3.5
const ROOM_MIN_X: float = -7.0
const ROOM_MAX_X: float = 7.0
const ROOM_MIN_Z: float = -6.8
const ROOM_MAX_Z: float = 7.0
const LASER_COUNT: int = 5

# COLORS
const COLOR_ORANGE := Color(1.0, 0.35, 0.05)
const COLOR_BLUE := Color(0.05, 0.7, 1.0)
const COLOR_RED := Color(1.0, 0.02, 0.02)
const COLOR_GREEN := Color(0.05, 1.0, 0.2)
const COLOR_YELLOW := Color(0.8, 0.6, 0.0)
const COLOR_DARK_METAL := Color(0.08, 0.09, 0.11)

# ============================================================
# READY
# ============================================================
func _ready() -> void:
	print("\n================================================")
	print(" ENGINE 2 - ITERATIVE LOGIC TRAINING ROOM")
	print("================================================\n")

	_setup_world_environment()
	_setup_industrial_lighting()
	
	_build_factory_room()
	_build_factory_pillars()
	_build_hazard_stripes() # NEW: Floor details
	_build_power_conduits() # NEW: Ceiling details
	_build_vault()
	_build_laser_grid()
	
	_setup_player()
	
	_build_terminal()
	_build_hacking_interface()
	_build_hud()
	
	_capture_mouse()

# ============================================================
# ENVIRONMENT & LIGHTING
# ============================================================
func _setup_world_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.005, 0.008, 0.015)
	
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.15, 0.16, 0.20)
	environment.ambient_light_energy = 0.45
	
	environment.glow_enabled = true
	environment.glow_intensity = 1.5
	environment.glow_bloom = 0.2
	
	world_environment.environment = environment
	add_child(world_environment)

func _setup_industrial_lighting() -> void:
	var factory_light := OmniLight3D.new()
	factory_light.position = Vector3(0.0, 5.5, 1.0)
	factory_light.light_color = COLOR_ORANGE
	factory_light.light_energy = 6.0
	factory_light.omni_range = 18.0
	factory_light.shadow_enabled = true
	add_child(factory_light)

	var terminal_light := OmniLight3D.new()
	terminal_light.position = Vector3(0.0, 2.5, -2.0)
	terminal_light.light_color = COLOR_BLUE
	terminal_light.light_energy = 3.0
	terminal_light.omni_range = 8.0
	terminal_light.shadow_enabled = true
	add_child(terminal_light)

	var vault_light := OmniLight3D.new()
	vault_light.position = Vector3(0.0, 4.5, -6.5)
	vault_light.light_color = COLOR_RED
	vault_light.light_energy = 2.5
	vault_light.omni_range = 7.0
	vault_light.shadow_enabled = true
	add_child(vault_light)

# ============================================================
# ROOM ARCHITECTURE & ENHANCEMENTS
# ============================================================
func _build_factory_room() -> void:
	var floor_node := CSGBox3D.new()
	floor_node.size = Vector3(16.0, 0.5, 16.0)
	floor_node.position = Vector3(0.0, -0.25, 0.0)
	floor_node.material = get_metal_material(Color(0.12, 0.13, 0.15), 0.9, 0.32)
	add_child(floor_node)

	var back_wall := CSGBox3D.new()
	back_wall.size = Vector3(16.0, 8.0, 0.5)
	back_wall.position = Vector3(0.0, 4.0, -7.75)
	back_wall.material = get_metal_material(COLOR_DARK_METAL)
	add_child(back_wall)

	var front_wall := CSGBox3D.new()
	front_wall.size = Vector3(16.0, 8.0, 0.5)
	front_wall.position = Vector3(0.0, 4.0, 7.75)
	front_wall.material = get_metal_material(COLOR_DARK_METAL)
	add_child(front_wall)

	var left_wall := CSGBox3D.new()
	left_wall.size = Vector3(0.5, 8.0, 16.0)
	left_wall.position = Vector3(-7.75, 4.0, 0.0)
	left_wall.material = get_metal_material(COLOR_DARK_METAL)
	add_child(left_wall)

	var right_wall := CSGBox3D.new()
	right_wall.size = Vector3(0.5, 8.0, 16.0)
	right_wall.position = Vector3(7.75, 4.0, 0.0)
	right_wall.material = get_metal_material(COLOR_DARK_METAL)
	add_child(right_wall)

	var ceiling := CSGBox3D.new()
	ceiling.size = Vector3(16.0, 0.3, 16.0)
	ceiling.position = Vector3(0.0, 8.0, 0.0)
	ceiling.material = get_metal_material(Color(0.04, 0.045, 0.05), 0.8, 0.5)
	add_child(ceiling)

func _build_factory_pillars() -> void:
	for i in range(4):
		var z_pos = -5.0 + (i * 3.5)
		
		var left_pillar = CSGBox3D.new()
		left_pillar.size = Vector3(1.0, 8.0, 1.0)
		left_pillar.position = Vector3(-7.25, 4.0, z_pos)
		left_pillar.material = get_metal_material(Color(0.15, 0.15, 0.18))
		add_child(left_pillar)
		
		var right_pillar = CSGBox3D.new()
		right_pillar.size = Vector3(1.0, 8.0, 1.0)
		right_pillar.position = Vector3(7.25, 4.0, z_pos)
		right_pillar.material = get_metal_material(Color(0.15, 0.15, 0.18))
		add_child(right_pillar)

func _build_hazard_stripes() -> void:
	var stripe_mat = StandardMaterial3D.new()
	stripe_mat.albedo_color = COLOR_YELLOW
	stripe_mat.roughness = 0.8
	
	for x_pos in [-4.0, 4.0]:
		var stripe = CSGBox3D.new()
		stripe.size = Vector3(0.3, 0.02, 16.0)
		stripe.position = Vector3(x_pos, 0.01, 0.0)
		stripe.material = stripe_mat
		add_child(stripe)

func _build_power_conduits() -> void:
	for x_pos in [-2.0, 2.0]:
		var conduit = CSGCylinder3D.new()
		conduit.radius = 0.1
		conduit.height = 16.0
		conduit.rotation_degrees = Vector3(90, 0, 0)
		conduit.position = Vector3(x_pos, 7.8, 0.0)
		conduit.material = get_emission_material(COLOR_ORANGE, 1.5)
		add_child(conduit)

func _build_vault() -> void:
	vault_door = CSGBox3D.new()
	vault_door.size = Vector3(6.0, 6.0, 0.8)
	vault_door.position = Vector3(0.0, 3.0, -7.2)
	vault_door.material = get_metal_material(Color(0.16, 0.18, 0.22), 0.95, 0.25)
	add_child(vault_door)

	var frame_left = CSGBox3D.new()
	frame_left.size = Vector3(0.5, 7.0, 1.0)
	frame_left.position = Vector3(-3.25, 3.5, -7.1)
	frame_left.material = get_metal_material(Color(0.25, 0.27, 0.30))
	add_child(frame_left)

	var frame_right = CSGBox3D.new()
	frame_right.size = Vector3(0.5, 7.0, 1.0)
	frame_right.position = Vector3(3.25, 3.5, -7.1)
	frame_right.material = get_metal_material(Color(0.25, 0.27, 0.30))
	add_child(frame_right)

func _build_laser_grid() -> void:
	var laser_material := get_emission_material(COLOR_RED, 6.0)
	
	for i in range(LASER_COUNT):
		var laser := CSGCylinder3D.new()
		laser.radius = 0.045
		laser.height = 6.0
		laser.rotation_degrees = Vector3(0.0, 0.0, 90.0)
		laser.position = Vector3(0.0, 1.0 + float(i), -6.55)
		laser.material = laser_material
		add_child(laser)
		laser_grid.append(laser)

# ============================================================
# PLAYER & INPUT
# ============================================================
func _setup_player() -> void:
	player = Node3D.new()
	player.position = Vector3(0.0, 0.0, 3.0)
	add_child(player)

	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0.0, PLAYER_HEIGHT, 0.0)
	player.add_child(camera_pivot)

	camera = Camera3D.new()
	camera.current = true
	camera.fov = 75.0
	camera_pivot.add_child(camera)

func _process(delta: float) -> void:
	if is_hacking: return
	_update_player_movement(delta)
	_update_terminal_distance()
	_update_interaction_prompt()

func _update_player_movement(delta: float) -> void:
	var input_direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_direction.z -= 1.0
	if Input.is_key_pressed(KEY_S): input_direction.z += 1.0
	if Input.is_key_pressed(KEY_A): input_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_direction.x += 1.0

	if input_direction == Vector3.ZERO: return
	input_direction = input_direction.normalized()

	var forward := -player.global_transform.basis.z
	var right := player.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var movement := (forward * -input_direction.z + right * input_direction.x)
	var current_speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed
	
	player.global_position += movement * current_speed * delta

	player.global_position.x = clamp(player.global_position.x, ROOM_MIN_X, ROOM_MAX_X)
	player.global_position.z = clamp(player.global_position.z, ROOM_MIN_Z, ROOM_MAX_Z)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured and not is_hacking:
		var mouse_event := event as InputEventMouseMotion
		player.rotate_y(-mouse_event.relative.x * mouse_sensitivity)
		camera_pitch -= (mouse_event.relative.y * mouse_sensitivity)
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera_pivot.rotation.x = camera_pitch

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if is_hacking: _cancel_hacking()
			elif mouse_captured: _release_mouse()
			else: _capture_mouse()
		
		if event.keycode == KEY_SPACE and not is_hacking and not is_unlocked and terminal_in_range:
			_start_hacking()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true
	if crosshair: crosshair.visible = true

func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false
	if crosshair: crosshair.visible = false

func _update_terminal_distance() -> void:
	var distance := player.global_position.distance_to(TERMINAL_POSITION)
	terminal_in_range = (distance <= TERMINAL_INTERACTION_DISTANCE)

func _update_interaction_prompt() -> void:
	if is_unlocked or is_hacking:
		interact_prompt.visible = false
	else:
		interact_prompt.visible = terminal_in_range

# ============================================================
# 3D TERMINAL
# ============================================================
func _build_terminal() -> void:
	var console_body = CSGBox3D.new()
	console_body.size = Vector3(2.8, 1.0, 1.4)
	console_body.position = Vector3(0.0, 0.5, -2.0)
	console_body.material = get_metal_material(Color(0.15, 0.16, 0.20), 0.85, 0.35)
	add_child(console_body)

	var stand = CSGBox3D.new()
	stand.size = Vector3(0.2, 0.6, 0.2)
	stand.position = Vector3(0.0, 1.2, -2.4)
	stand.material = get_metal_material(COLOR_DARK_METAL)
	add_child(stand)

	var monitor = CSGBox3D.new()
	monitor.size = Vector3(1.6, 1.1, 0.15)
	monitor.position = Vector3(0.0, 1.6, -2.35)
	monitor.material = get_metal_material(Color(0.025, 0.03, 0.04), 0.7, 0.25)
	add_child(monitor)

	var screen := CSGBox3D.new()
	screen.size = Vector3(1.4, 0.9, 0.02)
	screen.position = Vector3(0.0, 1.6, -2.25)
	screen.material = get_emission_material(Color(0.02, 0.3, 0.45), 2.5)
	add_child(screen)
	
	var keyboard = CSGBox3D.new()
	keyboard.size = Vector3(0.8, 0.05, 0.3)
	keyboard.position = Vector3(0.0, 1.025, -1.8)
	keyboard.rotation_degrees = Vector3(5.0, 0, 0)
	keyboard.material = get_emission_material(COLOR_BLUE, 1.5)
	add_child(keyboard)

	interact_prompt = Label3D.new()
	interact_prompt.text = "[ SPACE ] ACCESS TERMINAL"
	interact_prompt.position = Vector3(0.0, 2.4, -2.0)
	interact_prompt.modulate = COLOR_ORANGE
	interact_prompt.font_size = 32
	interact_prompt.outline_size = 8
	add_child(interact_prompt)

	terminal_status = Label3D.new()
	terminal_status.text = "SYSTEM STATUS: LOCKED"
	terminal_status.position = Vector3(0.0, 2.8, -2.0)
	terminal_status.modulate = COLOR_RED
	terminal_status.font_size = 24
	terminal_status.outline_size = 6
	add_child(terminal_status)

# ============================================================
# HACKING INTERFACE (WITH CHALLENGE BOILERPLATE)
# ============================================================
func _build_hacking_interface() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.visible = false
	add_child(ui_layer)

	var background := ColorRect.new()
	background.color = Color(0.005, 0.01, 0.02, 0.96)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(background)

	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 100)
	margin_container.add_theme_constant_override("margin_right", 100)
	margin_container.add_theme_constant_override("margin_top", 60)
	margin_container.add_theme_constant_override("margin_bottom", 60)
	ui_layer.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin_container.add_child(vbox)

	# Header
	var header := Label.new()
	header.text = "ENGINE 2 // ITERATIVE LOGIC TERMINAL\nSECURITY SYSTEM: LASER GRID"
	header.add_theme_font_size_override("font_size", 28)
	header.modulate = COLOR_BLUE
	vbox.add_child(header)

	# Problem Statement (Instructions)
	var instructions := Label.new()
	instructions.text = "MISSION BRIEFING:\nThe facility vault is locked behind a 5-tier laser grid.\nWrite a C 'for' loop that calls disable_laser(i); exactly 5 times."
	instructions.add_theme_font_size_override("font_size", 19)
	instructions.modulate = Color(0.75, 0.85, 0.90)
	vbox.add_child(instructions)

	# Code Editor (Now a Template instead of the Answer!)
	code_input = TextEdit.new()
	code_input.text = "#include <stdio.h>\n\nint main() {\n    // Write your 'for' loop below to disable lasers 0 through 4:\n    \n    \n    return 0;\n}"
	code_input.add_theme_font_size_override("font_size", 22)
	code_input.add_theme_color_override("font_color", Color(0.65, 1.0, 0.75))
	code_input.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	vbox.add_child(code_input)

	# Compiler Status
	compiler_message = Label.new()
	compiler_message.add_theme_font_size_override("font_size", 20)
	vbox.add_child(compiler_message)

	# Button Layout 
	var button_row = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(button_row)

	compile_button = Button.new()
	compile_button.text = " COMPILE & EXECUTE "
	compile_button.custom_minimum_size = Vector2(300, 60)
	compile_button.add_theme_font_size_override("font_size", 21)
	compile_button.pressed.connect(_on_submit_pressed)
	button_row.add_child(compile_button)
	
	var close_label := Label.new()
	close_label.text = "ESC = Cancel / Return to Factory"
	close_label.add_theme_font_size_override("font_size", 17)
	close_label.modulate = Color(0.5, 0.6, 0.65)
	close_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(close_label)

# ============================================================
# HUD & CROSSHAIR
# ============================================================
func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	var controls := Label.new()
	controls.text = "WASD - MOVE\nSHIFT - SPRINT\nSPACE - INTERACT\nESC - RELEASE MOUSE"
	controls.position = Vector2(25, 25)
	controls.add_theme_font_size_override("font_size", 17)
	controls.modulate = Color(0.65, 0.75, 0.80)
	hud.add_child(controls)

	crosshair = ColorRect.new()
	crosshair.custom_minimum_size = Vector2(4, 4)
	crosshair.color = Color(1.0, 1.0, 1.0, 0.5)
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	hud.add_child(crosshair)

# ============================================================
# LOGIC & VALIDATION
# ============================================================
func _start_hacking() -> void:
	is_hacking = true
	_release_mouse()
	ui_layer.visible = true
	interact_prompt.visible = false
	compiler_message.text = ""
	code_input.grab_focus()

func _cancel_hacking() -> void:
	is_hacking = false
	ui_layer.visible = false
	_capture_mouse()
	_update_interaction_prompt()

func _on_submit_pressed() -> void:
	var submitted_code := code_input.text
	var validation := validate_c_loop(submitted_code)

	if validation["valid"]:
		ui_layer.visible = false
		is_hacking = false
		_capture_mouse()
		await execute_laser_shutdown_loop()
	else:
		compiler_message.text = "COMPILER ERROR: " + validation["message"]
		compiler_message.modulate = COLOR_RED

func validate_c_loop(code: String) -> Dictionary:
	var lower_code := code.to_lower().replace(" ", "").replace("\n", "").replace("\t", "")
	if not lower_code.contains("for"): return {"valid": false, "message": "No 'for' loop detected."}
	if not (lower_code.contains("i=0")): return {"valid": false, "message": "Loop counter must start at i = 0."}
	if not (lower_code.contains("i<5")): return {"valid": false, "message": "Loop condition must be i < 5."}
	if not (lower_code.contains("disable_laser(i)")): return {"valid": false, "message": "Call disable_laser(i) inside loop."}
	return {"valid": true, "message": "Valid loop detected."}

# ============================================================
# EXECUTION ANIMATION
# ============================================================
func execute_laser_shutdown_loop() -> void:
	is_unlocked = true
	terminal_status.text = "SYSTEM STATUS: EXECUTING LOOP"
	terminal_status.modulate = COLOR_ORANGE

	for i in range(laser_grid.size()):
		await get_tree().create_timer(0.8).timeout
		await _disable_laser(i)

	terminal_status.text = "SYSTEM STATUS: LASERS OFFLINE"
	terminal_status.modulate = COLOR_GREEN
	await get_tree().create_timer(1.0).timeout
	_open_vault_door()

func _disable_laser(index: int) -> void:
	var laser := laser_grid[index]
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(laser, "scale", Vector3(1.0, 0.05, 1.0), 0.35)
	await tween.finished
	laser.visible = false

func _open_vault_door() -> void:
	var door_mat := vault_door.material as StandardMaterial3D
	door_mat.albedo_color = COLOR_GREEN
	door_mat.emission_enabled = true
	door_mat.emission = COLOR_GREEN
	door_mat.emission_energy_multiplier = 2.0

	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(vault_door, "position:x", 6.0, 3.0)

# ============================================================
# UTILITY
# ============================================================
func get_metal_material(base_color: Color, metallic_value: float = 0.8, roughness_value: float = 0.4) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.metallic = metallic_value
	material.roughness = roughness_value
	return material

func get_emission_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material
