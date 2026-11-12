extends Node3D
class_name HybridPlayer

# ==============================================================================
# ENGINE 0: ZERO-G LOGIC CHAMBER (PLAYER CONTROLLER — PRODUCTION SUITE) — REV 4
# ARCHITECTURE: Dual OpenXR/Desktop State Manager & Dynamic Raycast Grabber
#
# CHANGES FROM REV 3:
#  - _release_grab now checks for HardwareCartridge + tries to snap it onto
#    any MagneticTrack in the scene before falling back to a normal drop.
#    This was written for the Assembly Desk step but never actually landed
#    in this file — cartridges could be grabbed but never placed.
# ==============================================================================

const VRHandScript = preload("res://scripts/player/vr_hand.gd")

var xr_origin: XROrigin3D
var xr_camera: XRCamera3D
var left_hand: XRController3D
var left_hand_model: Node3D
var right_hand: XRController3D
var right_hand_model: Node3D
var interaction_ray: RayCast3D
var ui_layer: CanvasLayer

var is_vr_active: bool = false
var desktop_move_speed: float = 5.0
var mouse_sensitivity: float = 0.003
var rotation_x: float = 0.0
var rotation_y: float = 0.0

var grabbed_object: RigidBody3D = null
var hovered_object: Node3D = null
var grab_distance: float = 2.5
const ROTATION_SLERP_SPEED: float = 10.0
const POSITION_LERP_SPEED: float = 18.0
const CABLE_SNAP_RADIUS: float = 1.0

func _ready():
	_build_player_nodes()
	_initialize_xr_system()

# ---------------------------------------------------------
# 1. PROCEDURAL PLAYER NODE GENERATION
# ---------------------------------------------------------
func _build_player_nodes():
	xr_origin = XROrigin3D.new()
	add_child(xr_origin)

	xr_camera = XRCamera3D.new()
	xr_camera.position = Vector3(0, 1.7, 0.0)
	xr_camera.current = true
	xr_origin.add_child(xr_camera)

	left_hand = XRController3D.new()
	left_hand.tracker = "left_hand"
	xr_origin.add_child(left_hand)
	
	left_hand_model = VRHandScript.new()
	left_hand.add_child(left_hand_model)

		# Wrist scanner only makes sense in real VR — left_hand doesn't move
	# in desktop mode, so it'd sit stuck in camera view.
	var xr_check = XRServer.find_interface("OpenXR")
	if xr_check and xr_check.is_initialized():
		var scanner_ray = RayCast3D.new()
		scanner_ray.target_position = Vector3(0, 0, -2.0)
		scanner_ray.enabled = true
		left_hand.add_child(scanner_ray)

		var wrist_scanner = WristScanner.new()
		wrist_scanner.scan_ray = scanner_ray
		wrist_scanner.position = Vector3(0, 0.05, -0.1)
		left_hand.add_child(wrist_scanner)

	right_hand = XRController3D.new()
	right_hand.tracker = "right_hand"
	right_hand.button_pressed.connect(_on_vr_button_pressed)
	right_hand.button_released.connect(_on_vr_button_released)
	xr_origin.add_child(right_hand)
	
	right_hand_model = VRHandScript.new()
	right_hand.add_child(right_hand_model)

	interaction_ray = RayCast3D.new()
	interaction_ray.target_position = Vector3(0, 0, -6.0)
	interaction_ray.enabled = true
	interaction_ray.collide_with_areas = true
	interaction_ray.collide_with_bodies = true
	interaction_ray.collision_mask = CollisionLayers.WORLD | CollisionLayers.PORT
	xr_camera.add_child(interaction_ray)

	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	var crosshair = ColorRect.new()
	crosshair.size = Vector2(4, 4)
	crosshair.color = Color(1, 1, 1, 0.8)
	crosshair.anchors_preset = Control.PRESET_CENTER
	crosshair.grow_horizontal = Control.GROW_DIRECTION_BOTH
	crosshair.grow_vertical = Control.GROW_DIRECTION_BOTH
	ui_layer.add_child(crosshair)

func _initialize_xr_system():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		get_viewport().use_xr = true
		is_vr_active = true

		if ui_layer:
			ui_layer.visible = false

		interaction_ray.get_parent().remove_child(interaction_ray)
		right_hand.add_child(interaction_ray)
		interaction_ray.position = Vector3.ZERO
		interaction_ray.target_position = Vector3(0, 0, -6.0)
	else:
		is_vr_active = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ---------------------------------------------------------
# 2. INPUT & MOVEMENT ENGINE
# ---------------------------------------------------------
func _unhandled_input(event):
	if is_vr_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-85), deg_to_rad(85))
		xr_camera.transform.basis = Basis.from_euler(Vector3(rotation_x, rotation_y, 0))

	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		_attempt_grab()
		if right_hand_model: right_hand_model.close_hand()
		if left_hand_model: left_hand_model.close_hand()
	elif event.is_action_released("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		_release_grab()
		if right_hand_model: right_hand_model.open_hand()
		if left_hand_model: left_hand_model.open_hand()

func _process(delta):
	if not is_vr_active:
		var input_dir = Vector3.ZERO
		if Input.is_physical_key_pressed(KEY_W): input_dir.z -= 1
		if Input.is_physical_key_pressed(KEY_S): input_dir.z += 1
		if Input.is_physical_key_pressed(KEY_A): input_dir.x -= 1
		if Input.is_physical_key_pressed(KEY_D): input_dir.x += 1

		if input_dir != Vector3.ZERO:
			input_dir = input_dir.normalized()
			var forward = -xr_camera.global_transform.basis.z
			var right = xr_camera.global_transform.basis.x
			forward.y = 0
			right.y = 0
			xr_origin.global_position += (forward * -input_dir.z + right * input_dir.x) * desktop_move_speed * delta

func _on_vr_button_pressed(button_name: String):
	if button_name == "trigger_click" or button_name == "ax_button":
		_attempt_grab()
		if right_hand_model: right_hand_model.close_hand()
		if left_hand_model: left_hand_model.close_hand()

func _on_vr_button_released(button_name: String):
	if button_name == "trigger_click" or button_name == "ax_button":
		_release_grab()
		if right_hand_model: right_hand_model.open_hand()
		if left_hand_model: left_hand_model.open_hand()

# ---------------------------------------------------------
# 3. ADVANCED PHYSICS GRABBING ALGORITHM
# ---------------------------------------------------------
func _attempt_grab():
	if grabbed_object != null: return
	if not interaction_ray.is_colliding(): return

	var target = interaction_ray.get_collider()

	if target is CablePort and not target.is_input and not target.is_occupied:
		var cable = FlowCable.new()
		get_tree().root.add_child(cable)
		cable.connect_to_start(target)
		target.is_occupied = true

		grabbed_object = cable.plug_body
		grabbed_object.set_meta("is_grabbed", true)
		grabbed_object.set_meta("owning_cable", cable)
		grabbed_object.collision_layer = CollisionLayers.NONE
		grabbed_object.collision_mask = CollisionLayers.NONE
		_play_grab_pop(grabbed_object)
		return

	if target is IngredientSpawner:
		var new_cart = target.spawn_cartridge()
		grabbed_object = new_cart
		grabbed_object.set_meta("is_grabbed", true)
		grabbed_object.collision_layer = CollisionLayers.NONE
		grabbed_object.collision_mask = CollisionLayers.NONE
		_play_grab_pop(grabbed_object)
		return

	if target is FlowchartNodeSpawner:
		var new_node = target.spawn_node()
		grabbed_object = new_node
		grabbed_object.set_meta("is_grabbed", true)
		grabbed_object.collision_layer = CollisionLayers.NONE
		grabbed_object.collision_mask = CollisionLayers.NONE
		_play_grab_pop(grabbed_object)
		return

	if target is TraceLever:
		target.pull()
		return

	if target is CompileLever:
		target.pull()
		return

	if target is RigidBody3D and target.is_in_group("grabbable"):
		grabbed_object = target
		grabbed_object.set_meta("is_grabbed", true)

		if grabbed_object.has_meta("owning_cable"):
			var cable: FlowCable = grabbed_object.get_meta("owning_cable")
			if cable.is_plugged_in:
				cable.target_port.is_occupied = false
				cable.target_port = null
				cable.is_plugged_in = false
				grabbed_object.freeze = false

		grabbed_object.linear_velocity = Vector3.ZERO
		grabbed_object.angular_velocity = Vector3.ZERO

		grabbed_object.collision_layer = CollisionLayers.NONE
		grabbed_object.collision_mask = CollisionLayers.NONE

		_play_grab_pop(grabbed_object)

func _release_grab():
	if grabbed_object == null:
		return

	if grabbed_object.has_meta("owning_cable"):
		var cable: FlowCable = grabbed_object.get_meta("owning_cable")
		var best_port: CablePort = null
		var best_dist: float = CABLE_SNAP_RADIUS
		var closest_dist_overall: float = INF
		var closest_name: String = "none"

		for port in get_tree().get_nodes_in_group("cable_port"):
			if port is CablePort:
				var d = port.global_position.distance_to(grabbed_object.global_position)
				if d < closest_dist_overall:
					closest_dist_overall = d
					closest_name = port.get_parent().label_text + (" (input)" if port.is_input else " (output)")
				if port.is_input and not port.is_occupied and d < best_dist:
					best_dist = d
					best_port = port

		if best_port != null:
			cable.snap_to_target(best_port)
			best_port.is_occupied = true
			if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
				VFXUtils.spawn_energy_burst(self, best_port.global_position, Color(1.0, 1.0, 1.0))
		else:
			print("WIRE DISCARDED: nearest port was '", closest_name, "' at distance ", closest_dist_overall, " (snap radius is ", CABLE_SNAP_RADIUS, ")")
			cable.discard()

		grabbed_object = null
		return

	# NEW: releasing a HardwareCartridge tries to snap it onto any nearby
	# magnetic track before falling back to a normal drop. This was
	# designed for the Assembly Desk step but had never actually been
	# added to this file — cartridges could be grabbed but never placed.
	if grabbed_object is HardwareCartridge:
		for track in get_tree().get_nodes_in_group("magnetic_track"):
			if track is MagneticTrack and track.try_snap_cartridge(grabbed_object):
				print("CARTRIDGE SNAPPED: ", grabbed_object.token_name)
				if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
					VFXUtils.spawn_energy_burst(self, grabbed_object.global_position, Color(0.2, 1.0, 0.5))
				grabbed_object.set_meta("is_grabbed", false)
				grabbed_object = null
				return
		print("CARTRIDGE NOT SNAPPED: too far from any track slot")

	grabbed_object.set_meta("is_grabbed", false)
	grabbed_object.set_meta("base_y", grabbed_object.global_position.y)

	grabbed_object.collision_layer = CollisionLayers.WORLD
	grabbed_object.collision_mask = CollisionLayers.WORLD

	grabbed_object = null

func _physics_process(delta):
	# -- Hover Logic --
	if interaction_ray.is_colliding():
		var col = interaction_ray.get_collider()
		if col != hovered_object:
			if hovered_object != null and is_instance_valid(hovered_object) and hovered_object.has_method("on_hover"):
				hovered_object.on_hover(false)
			hovered_object = col
			if hovered_object != null and is_instance_valid(hovered_object) and hovered_object.has_method("on_hover"):
				hovered_object.on_hover(true)
	else:
		if hovered_object != null and is_instance_valid(hovered_object):
			if hovered_object.has_method("on_hover"):
				hovered_object.on_hover(false)
			hovered_object = null

	if grabbed_object != null and is_instance_valid(grabbed_object):
		var hold_position: Vector3

		if is_vr_active:
			hold_position = right_hand.global_position + (-right_hand.global_transform.basis.z * 0.8)
		else:
			hold_position = xr_camera.global_position + (-xr_camera.global_transform.basis.z * grab_distance)

		grabbed_object.global_position = grabbed_object.global_position.lerp(hold_position, POSITION_LERP_SPEED * delta)

		var target_look = xr_camera.global_position
		target_look.y = grabbed_object.global_position.y

		var look_dir = target_look - grabbed_object.global_position
		if look_dir.length_squared() > 0.0001:
			var up_ref = Vector3.UP
			if abs(look_dir.normalized().dot(Vector3.UP)) > 0.98:
				up_ref = Vector3.FORWARD

			var target_basis = Transform3D(Basis(), grabbed_object.global_position)\
				.looking_at(target_look, up_ref).basis
			target_basis = target_basis.rotated(Vector3.UP, PI)

			var current_basis = grabbed_object.global_transform.basis.orthonormalized()
			target_basis = target_basis.orthonormalized()

			var new_basis = current_basis.slerp(target_basis, ROTATION_SLERP_SPEED * delta)
			grabbed_object.global_transform = Transform3D(new_basis, grabbed_object.global_transform.origin)

# ---------------------------------------------------------
# 4. GAME FEEL
# ---------------------------------------------------------
func _play_grab_pop(object: Node3D) -> void:
	var tween = create_tween()
	tween.tween_property(object, "scale", Vector3.ONE * 1.12, 0.07)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, "scale", Vector3.ONE, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
