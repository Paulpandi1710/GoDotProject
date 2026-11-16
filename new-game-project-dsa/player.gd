extends CharacterBody3D


# ============================================================
# HYBRID VR & DESKTOP PLAYER CONTROLLER
# ============================================================

var is_vr: bool = false

# Desktop Variables
const MOVE_SPEED: float = 5.5
const SPRINT_SPEED: float = 8.0
const GRAVITY: float = 18.0
const MOUSE_SENSITIVITY: float = 0.0025
var desktop_camera: Camera3D
var pitch: float = 0.0

# VR Variables
var xr_origin: XROrigin3D
var vr_camera: XRCamera3D
var left_controller: XRController3D
var right_controller: XRController3D

var interaction_system
var game_ui


# ============================================================
# READY
# ============================================================

func _ready():
	
	# --------------------------------------------------------
	# INITIALIZE OPENXR
	# --------------------------------------------------------
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		is_vr = true
	else:
		print("OpenXR not initialized. Falling back to Desktop mode.")
		is_vr = false

	if is_vr:
		create_vr_rig()
	else:
		create_desktop_rig()

	create_interaction_system()

	if game_ui != null:
		setup_game_ui(game_ui)


# ============================================================
# DESKTOP RIG
# ============================================================

func create_desktop_rig():
	if desktop_camera != null:
		return
	var collision = CollisionShape3D.new()
	collision.name = "PlayerCollision"
	var shape = CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.8
	collision.shape = shape
	collision.position = Vector3(0, 0.9, 0)
	add_child(collision)

	desktop_camera = Camera3D.new()
	desktop_camera.name = "PlayerCamera"
	desktop_camera.position = Vector3(0, 1.55, 0)
	desktop_camera.current = true
	desktop_camera.fov = 72.0
	desktop_camera.near = 0.05
	desktop_camera.far = 100.0
	add_child(desktop_camera)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# --------------------------------------------------------
	# DESKTOP CROSSHAIR — Always visible pointer (Spec §9)
	# --------------------------------------------------------
	create_crosshair()


func create_crosshair():
	var crosshair_layer = CanvasLayer.new()
	crosshair_layer.name = "CrosshairLayer"
	crosshair_layer.layer = 50
	add_child(crosshair_layer)

	var container = Control.new()
	container.name = "CrosshairContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_layer.add_child(container)

	# Center dot
	var dot = ColorRect.new()
	dot.color = Color(0.0, 0.85, 1.0, 0.85)
	dot.size = Vector2(6, 6)
	dot.position = Vector2(-3, -3)
	dot.set_anchors_preset(Control.PRESET_CENTER)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(dot)

	# Horizontal lines
	for offset in [-12, 8]:
		var line = ColorRect.new()
		line.color = Color(0.0, 0.85, 1.0, 0.6)
		line.size = Vector2(8, 2)
		line.position = Vector2(offset, -1)
		line.set_anchors_preset(Control.PRESET_CENTER)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(line)

	# Vertical lines
	for offset in [-12, 8]:
		var line = ColorRect.new()
		line.color = Color(0.0, 0.85, 1.0, 0.6)
		line.size = Vector2(2, 8)
		line.position = Vector2(-1, offset)
		line.set_anchors_preset(Control.PRESET_CENTER)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(line)


# ============================================================
# VR RIG
# ============================================================

func create_vr_rig():
	
	xr_origin = XROrigin3D.new()
	xr_origin.name = "XROrigin3D"
	add_child(xr_origin)
	
	vr_camera = XRCamera3D.new()
	vr_camera.name = "XRCamera3D"
	vr_camera.current = true
	vr_camera.near = 0.05
	vr_camera.far = 100.0
	xr_origin.add_child(vr_camera)
	
	left_controller = XRController3D.new()
	left_controller.name = "LeftHand"
	left_controller.tracker = "left_hand"
	xr_origin.add_child(left_controller)
	
	right_controller = XRController3D.new()
	right_controller.name = "RightHand"
	right_controller.tracker = "right_hand"
	xr_origin.add_child(right_controller)
	
	var pointer_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.005, 0.005, 10.0)
	pointer_mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1, 1, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color(0, 1, 1)
	pointer_mesh.material_override = material
	
	pointer_mesh.position = Vector3(0, 0, -5.0)
	right_controller.add_child(pointer_mesh)


# ============================================================
# INTERACTION SYSTEM
# ============================================================

func create_interaction_system():
	if interaction_system != null:
		return
	var interaction_script = load("res://interaction_system.gd")

	if interaction_script == null:
		push_error("interaction_system.gd not found.")
		return

	interaction_system = interaction_script.new()
	interaction_system.name = "InteractionSystem"
	add_child(interaction_system)


# ============================================================
# CONNECT UI
# ============================================================

func setup_game_ui(ui):
	game_ui = ui

	if interaction_system == null:
		if is_vr:
			create_vr_rig()
		else:
			create_desktop_rig()
		create_interaction_system()

	if interaction_system != null:
		if is_vr:
			interaction_system.setup_vr(right_controller, game_ui)
		else:
			interaction_system.setup_desktop(desktop_camera, game_ui)


# ============================================================
# DESKTOP INPUT
# ============================================================

func _is_ui_panel_open() -> bool:
	# Check if a UI panel is currently visible and should block mouse capture
	if game_ui == null:
		return false
	if game_ui.has_method("panel_is_open") and game_ui.panel_is_open():
		return true
	# Also check for hub overlay or other modal states
	if game_ui.get("_hub_overlay") != null and game_ui._hub_overlay.visible:
		return true
	return false

func _unhandled_input(event):
	if is_vr:
		return

	# Mouse capture on click — never while a story/quiz modal is open
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			if _is_ui_panel_open():
				return
			var vp_size = get_viewport().get_visible_rect().size
			if event.position.y < vp_size.y * 0.72:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Mouse look (fluid when captured, OR when dragging with Right Mouse Button)
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			pitch -= (event.relative.y * MOUSE_SENSITIVITY)
			pitch = clamp(pitch, -1.35, 1.35)

			if desktop_camera != null:
				desktop_camera.rotation.x = pitch

	# ESC — toggle mouse capture
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# R key — Restart current lesson (disabled in hub)
		if event.pressed and event.keycode == KEY_R:
			var managers = get_tree().get_nodes_in_group("lesson_manager")
			if managers.size() > 0:
				var manager = managers[0]
				if manager.get("in_hub") != true and manager.has_method("restart_current_lesson"):
					manager.restart_current_lesson()

		# H key — Return to Hub
		if event.pressed and event.keycode == KEY_H:
			var managers = get_tree().get_nodes_in_group("lesson_manager")
			if managers.size() > 0:
				var manager = managers[0]
				if manager.has_method("return_to_hub"):
					manager.return_to_hub()

		# B / P / Right Arrow are handled only in game_ui.gd (avoid double-toggle)

		# 1, 2, 3 keys — Hub chapter select (respects unlock order)
		if event.pressed and (event.keycode == KEY_1 or event.keycode == KEY_2 or event.keycode == KEY_3):
			var managers = get_tree().get_nodes_in_group("lesson_manager")
			if managers.size() > 0:
				var manager = managers[0]
				if manager.get("in_hub") == true and manager.has_method("try_launch_lesson"):
					var idx = 0 if event.keycode == KEY_1 else (1 if event.keycode == KEY_2 else 2)
					manager.try_launch_lesson(idx)


# ============================================================
# PHYSICS (DESKTOP MOVEMENT)
# ============================================================

func _physics_process(delta):
	if is_vr:
		return

	var input_vector = Vector2.ZERO

	if Input.is_key_pressed(KEY_W): input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S): input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A): input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_vector.x += 1.0

	input_vector = input_vector.normalized()

	var direction = transform.basis * Vector3(input_vector.x, 0, input_vector.y)
	var speed = SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else MOVE_SPEED

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	move_and_slide()


# ============================================================
# KEEP PLAYER INSIDE ROOM
# ============================================================

func _process(_delta):
	position.x = clamp(position.x, -10.5, 10.5)
	position.z = clamp(position.z, -9.0, 9.0)
	position.y = max(position.y, 0.0)
