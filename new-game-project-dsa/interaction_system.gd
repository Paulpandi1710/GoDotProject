## ============================================================
## INTERACTION SYSTEM (HYBRID VR & DESKTOP)
## ============================================================
## Handles:
## - VR Controller raycast & Desktop raycasting
## - Free-mouse cursor picking & center-crosshair aiming
## - Hierarchical object discovery (array capsules, hub kiosks)
## - Instant hover detection and multi-angle selection
## ============================================================

extends Node3D

var is_vr: bool = false
var vr_pointer: XRController3D
var desktop_camera: Camera3D
var game_ui

var ray_length: float = 40.0
var last_hovered: Node = null

func setup_vr(pointer: XRController3D, ui):
	is_vr = true
	vr_pointer = pointer
	game_ui = ui
	if vr_pointer and not vr_pointer.button_pressed.is_connected(_on_pointer_button_pressed):
		vr_pointer.button_pressed.connect(_on_pointer_button_pressed)

func setup_desktop(camera: Camera3D, ui):
	is_vr = false
	desktop_camera = camera
	game_ui = ui

func _ready():
	_ensure_references()

func _ensure_references():
	if not is_vr and desktop_camera == null:
		if get_viewport():
			desktop_camera = get_viewport().get_camera_3d()
		if desktop_camera == null and get_parent():
			desktop_camera = get_parent().get_node_or_null("PlayerCamera")

	if is_vr and vr_pointer == null and get_parent():
		var rh = get_parent().get_node_or_null("RightHand")
		if rh:
			setup_vr(rh, game_ui)

func _process(_delta):
	_ensure_references()

	if is_vr and vr_pointer == null:
		return
	if not is_vr and desktop_camera == null:
		return

	update_hover()

func _find_interactable(collider: Object) -> Node:
	if collider == null or not (collider is Node):
		return null
	var curr: Node = collider as Node
	while curr != null:
		if curr.has_meta("array_system") or curr.has_meta("hub_topic"):
			return curr
		curr = curr.get_parent()
	return null

func _raycast_screen(screen_point: Vector2) -> Node:
	if desktop_camera == null:
		return null
	var ray_origin := desktop_camera.project_ray_origin(screen_point)
	var ray_direction := desktop_camera.project_ray_normal(screen_point)
	var ray_end := ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)

	if not result.is_empty():
		var collider = result.get("collider")
		return _find_interactable(collider)
	return null

func update_hover():
	var hovered_object: Node = null

	if is_vr:
		if vr_pointer != null:
			var ray_origin := vr_pointer.global_position
			var ray_direction := -vr_pointer.global_transform.basis.z
			var ray_end := ray_origin + ray_direction * ray_length
			var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			query.collide_with_bodies = true
			query.collide_with_areas = true
			var space_state := get_world_3d().direct_space_state
			var result := space_state.intersect_ray(query)
			if not result.is_empty():
				hovered_object = _find_interactable(result.get("collider"))
	else:
		if desktop_camera != null and get_viewport() != null:
			var viewport := get_viewport()
			var is_captured := (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
			var aim_pos: Vector2
			if is_captured:
				var vp_size := viewport.get_visible_rect().size
				aim_pos = Vector2(vp_size.x / 2.0, vp_size.y / 2.0)
			else:
				aim_pos = viewport.get_mouse_position()
			hovered_object = _raycast_screen(aim_pos)

	if hovered_object != last_hovered:
		clear_previous_hover()
		if hovered_object != null:
			hover_object(hovered_object)
			last_hovered = hovered_object

func hover_object(object: Node):
	if object == null:
		return

	if object.has_meta("hub_topic"):
		var audio = get_node_or_null("/root/AudioManager")
		if audio != null and audio.has_method("play_portal_hover_sound"):
			audio.play_portal_hover_sound()
		if is_inside_tree() and get_tree() != null:
			var world = get_tree().get_first_node_in_group("dsa_world")
			if world != null and world.has_method("on_topic_pedestal_hover"):
				world.on_topic_pedestal_hover(object.get_meta("hub_topic"), true)
		return

	if not object.has_meta("array_system"):
		return

	var system = object.get_meta("array_system")
	if system != null and system.has_method("on_element_hover"):
		system.on_element_hover(object)

	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("play_hover_sound"):
		audio.play_hover_sound()

	var index = object.get_meta("array_index", -1)
	var value = object.get_meta("array_value", 0)

	if game_ui != null and game_ui.has_method("show_element_info"):
		game_ui.show_element_info(index, value)

func clear_previous_hover():
	if last_hovered == null:
		return

	if last_hovered.has_meta("hub_topic"):
		if is_inside_tree() and get_tree() != null:
			var world = get_tree().get_first_node_in_group("dsa_world")
			if world != null and world.has_method("on_topic_pedestal_hover"):
				world.on_topic_pedestal_hover(last_hovered.get_meta("hub_topic"), false)
	elif last_hovered.has_meta("array_system"):
		var system = last_hovered.get_meta("array_system")
		if system != null and system.has_method("on_element_unhover"):
			system.on_element_unhover(last_hovered)

	last_hovered = null

	if game_ui != null and game_ui.has_method("hide_element_info"):
		game_ui.hide_element_info()

func _on_pointer_button_pressed(name: String):
	if name == "trigger_click":
		interact()
		if game_ui and game_ui.has_method("simulate_space_press"):
			game_ui.simulate_space_press()
	elif name == "ax_button":
		if game_ui and game_ui.has_method("emit_action"):
			game_ui.emit_action("FIRST")
	elif name == "by_button":
		if game_ui and game_ui.has_method("emit_action"):
			game_ui.emit_action("MIDDLE")

func _is_ui_blocking() -> bool:
	if game_ui == null:
		return false
	if game_ui.has_method("panel_is_open") and game_ui.panel_is_open():
		return true
	if game_ui.get("_hub_overlay") != null and game_ui._hub_overlay.visible:
		return true
	return false

func _unhandled_input(event):
	if is_vr:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not _is_ui_blocking():
				interact_at_pos(event.position)

func interact_at_pos(click_pos: Vector2 = Vector2.ZERO):
	var target: Node = null

	if is_vr:
		target = last_hovered
	else:
		var viewport := get_viewport()
		if viewport != null and desktop_camera != null:
			var vp_size := viewport.get_visible_rect().size
			var screen_center := Vector2(vp_size.x / 2.0, vp_size.y / 2.0)
			var is_captured := (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)

			var test_points := []
			if is_captured:
				test_points.append(screen_center)
				if click_pos != Vector2.ZERO and click_pos != screen_center:
					test_points.append(click_pos)
			else:
				if click_pos != Vector2.ZERO:
					test_points.append(click_pos)
				var mouse_pos := viewport.get_mouse_position()
				if mouse_pos != click_pos:
					test_points.append(mouse_pos)
				test_points.append(screen_center)

			for pt in test_points:
				var hit = _raycast_screen(pt)
				if hit != null:
					target = hit
					break

		if target == null and last_hovered != null:
			target = last_hovered

	if target != null:
		_perform_interaction(target)

func interact():
	interact_at_pos(Vector2.ZERO)

func _perform_interaction(target: Node):
	if target == null:
		return

	if target.has_meta("hub_topic"):
		var topic_idx = int(target.get_meta("hub_topic"))
		var audio = get_node_or_null("/root/AudioManager")
		if audio != null and audio.has_method("play_warp_sound"):
			audio.play_warp_sound()
		if is_inside_tree() and get_tree() != null:
			var lm = get_tree().get_first_node_in_group("lesson_manager")
			if lm != null and lm.has_method("launch_lesson"):
				lm.launch_lesson(topic_idx)
		return

	if not target.has_meta("array_system"):
		return

	var system = target.get_meta("array_system")
	var index = target.get_meta("array_index", -1)
	var value = target.get_meta("array_value", 0)

	var audio = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("play_click_sound"):
		audio.play_click_sound()

	if system != null and system.has_method("interact_with_element"):
		system.interact_with_element(target)

	if game_ui != null and game_ui.has_method("show_selected_element"):
		game_ui.show_selected_element(index, value)
