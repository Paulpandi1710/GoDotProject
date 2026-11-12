extends Node3D

# ============================================================
# VAULT DOOR — Engine 2, Automation Foundry
# Opens only when all laser layers are deactivated
# ============================================================

var door_left: MeshInstance3D
var door_right: MeshInstance3D
var door_light: OmniLight3D
var is_open: bool = false

const OPEN_DISTANCE := 3.5


func _ready() -> void:
	_build_door()


func _build_door() -> void:
	# Main door frame
	var frame := MeshInstance3D.new()
	var frame_box := BoxMesh.new()
	frame_box.size = Vector3(7.2, 5.0, 0.3)
	frame.mesh = frame_box
	var frame_mat := StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.15, 0.15, 0.2)
	frame_mat.metallic = 1.0
	frame_mat.roughness = 0.1
	frame.set_surface_override_material(0, frame_mat)
	add_child(frame)

	# Left door panel
	door_left = MeshInstance3D.new()
	var left_box := BoxMesh.new()
	left_box.size = Vector3(3.4, 4.5, 0.4)
	door_left.mesh = left_box
	door_left.position = Vector3(-1.7, 0, 0.2)
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.2, 0.22, 0.28)
	door_mat.metallic = 0.95
	door_mat.roughness = 0.15
	door_left.set_surface_override_material(0, door_mat)
	add_child(door_left)

	# Right door panel
	door_right = door_left.duplicate()
	door_right.position = Vector3(1.7, 0, 0.2)
	add_child(door_right)

	# Warning stripes on door
	_add_warning_stripes(door_left)
	_add_warning_stripes(door_right)

	# Lock mechanism (center bolt)
	var lock := MeshInstance3D.new()
	var lock_cyl := CylinderMesh.new()
	lock_cyl.top_radius = 0.2
	lock_cyl.bottom_radius = 0.2
	lock_cyl.height = 0.6
	lock.mesh = lock_cyl
	lock.rotation_degrees = Vector3(90, 0, 0)
	lock.position = Vector3(0, 0, 0.5)
	var lock_mat := StandardMaterial3D.new()
	lock_mat.albedo_color = Color(0.8, 0.3, 0.0)
	lock_mat.emission_enabled = true
	lock_mat.emission = Color(1.0, 0.4, 0.0)
	lock_mat.emission_energy_multiplier = 2.0
	lock.set_surface_override_material(0, lock_mat)
	add_child(lock)

	# Door status light
	door_light = OmniLight3D.new()
	door_light.light_color = Color(1.0, 0.2, 0.0)
	door_light.light_energy = 2.0
	door_light.omni_range = 3.0
	door_light.position = Vector3(0, 2.5, 0.5)
	add_child(door_light)

	# Pulse the lock light
	var t := create_tween().set_loops()
	t.tween_property(door_light, "light_energy", 3.0, 0.5)
	t.tween_property(door_light, "light_energy", 1.0, 0.5)


func _add_warning_stripes(door: MeshInstance3D) -> void:
	for i in range(5):
		var stripe := MeshInstance3D.new()
		var stripe_box := BoxMesh.new()
		stripe_box.size = Vector3(0.25, 4.0, 0.05)
		stripe.mesh = stripe_box
		stripe.position = Vector3(-1.2 + i * 0.6, 0, 0.22)
		var stripe_mat := StandardMaterial3D.new()
		stripe_mat.albedo_color = Color(0.9, 0.7, 0.0) if i % 2 == 0 else Color(0.1, 0.1, 0.1)
		stripe_mat.emission_enabled = (i % 2 == 0)
		stripe_mat.emission = Color(1.0, 0.8, 0.0)
		stripe_mat.emission_energy_multiplier = 0.5
		stripe.set_surface_override_material(0, stripe_mat)
		door.add_child(stripe)


func open_door() -> void:
	if is_open:
		return
	is_open = true

	# Turn lock green
	door_light.light_color = Color(0.0, 1.0, 0.3)
	door_light.light_energy = 4.0

	# Slide doors apart
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(door_left, "position:x", door_left.position.x - OPEN_DISTANCE, 3.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(door_right, "position:x", door_right.position.x + OPEN_DISTANCE, 3.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)

	# Rumble effect — shake position
	var shake_tween := create_tween()
	for _i in range(20):
		shake_tween.tween_property(self, "position", position + Vector3(randf_range(-0.05, 0.05), 0, 0), 0.05)
	shake_tween.tween_property(self, "position", position, 0.1)
