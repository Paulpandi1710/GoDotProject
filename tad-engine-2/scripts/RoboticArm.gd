extends Node3D

# ============================================================
# ROBOTIC ARM — Engine 2, Automation Foundry
# Physically reacts to while/nested loop code execution
# ============================================================

@export var arm_index: int = 0
@export var base_color: Color = Color(0.2, 0.4, 0.8)

var base_mesh: MeshInstance3D
var upper_arm: Node3D
var lower_arm: Node3D
var claw: Node3D
var arm_light: OmniLight3D

enum ArmState { IDLE, CALIBRATING, GRID_SYNC, LOCKDOWN, OPERATIONAL }
var arm_state: ArmState = ArmState.IDLE

var idle_oscillation_speed: float = 0.5
var time_elapsed: float = 0.0


func _ready() -> void:
	_build_arm_geometry()
	_start_idle_animation()


# ── Build 3D Arm Geometry ──────────────────────────────────
func _build_arm_geometry() -> void:
	# Base cylinder
	var base_node := MeshInstance3D.new()
	var base_mesh_data := CylinderMesh.new()
	base_mesh_data.top_radius = 0.3
	base_mesh_data.bottom_radius = 0.4
	base_mesh_data.height = 0.5
	base_node.mesh = base_mesh_data
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.25, 0.25, 0.3)
	base_mat.metallic = 0.95
	base_mat.roughness = 0.2
	base_node.set_surface_override_material(0, base_mat)
	base_node.position = Vector3(0, 0.25, 0)
	add_child(base_node)

	# Upper arm segment
	upper_arm = Node3D.new()
	upper_arm.position = Vector3(0, 0.5, 0)
	add_child(upper_arm)

	var upper_mesh := MeshInstance3D.new()
	var upper_box := BoxMesh.new()
	upper_box.size = Vector3(0.2, 1.2, 0.2)
	upper_mesh.mesh = upper_box
	upper_mesh.position = Vector3(0, 0.6, 0)
	var upper_mat := StandardMaterial3D.new()
	upper_mat.albedo_color = base_color
	upper_mat.metallic = 0.8
	upper_mat.roughness = 0.3
	upper_mesh.set_surface_override_material(0, upper_mat)
	upper_arm.add_child(upper_mesh)

	# Elbow joint sphere
	var elbow := MeshInstance3D.new()
	var elbow_sphere := SphereMesh.new()
	elbow_sphere.radius = 0.15
	elbow_sphere.height = 0.3
	elbow.mesh = elbow_sphere
	elbow.position = Vector3(0, 1.2, 0)
	var elbow_mat := StandardMaterial3D.new()
	elbow_mat.albedo_color = Color(0.15, 0.15, 0.2)
	elbow_mat.metallic = 1.0
	elbow.set_surface_override_material(0, elbow_mat)
	upper_arm.add_child(elbow)

	# Lower arm segment
	lower_arm = Node3D.new()
	lower_arm.position = Vector3(0, 1.2, 0)
	upper_arm.add_child(lower_arm)

	var lower_mesh := MeshInstance3D.new()
	var lower_box := BoxMesh.new()
	lower_box.size = Vector3(0.15, 1.0, 0.15)
	lower_mesh.mesh = lower_box
	lower_mesh.position = Vector3(0.3, 0.5, 0)
	var lower_mat := StandardMaterial3D.new()
	lower_mat.albedo_color = base_color.darkened(0.2)
	lower_mat.metallic = 0.8
	lower_mesh.set_surface_override_material(0, lower_mat)
	lower_arm.add_child(lower_mesh)

	# Claw
	claw = Node3D.new()
	claw.position = Vector3(0.3, 1.0, 0)
	lower_arm.add_child(claw)
	_build_claw()

	# Status light on arm
	arm_light = OmniLight3D.new()
	arm_light.position = Vector3(0, 2.0, 0)
	arm_light.light_color = Color(0.3, 0.5, 1.0)
	arm_light.light_energy = 1.0
	arm_light.omni_range = 2.0
	add_child(arm_light)


func _build_claw() -> void:
	var claw_colors := [Color(0.8, 0.2, 0.1), Color(0.1, 0.8, 0.2)]
	for i in range(2):
		var finger := MeshInstance3D.new()
		var finger_box := BoxMesh.new()
		finger_box.size = Vector3(0.08, 0.3, 0.08)
		finger.mesh = finger_box
		finger.position = Vector3(0, 0.15, 0.1 * (1 if i == 0 else -1))
		var finger_mat := StandardMaterial3D.new()
		finger_mat.albedo_color = Color(0.15, 0.15, 0.2)
		finger_mat.metallic = 0.95
		finger.set_surface_override_material(0, finger_mat)
		claw.add_child(finger)


# ── Idle animation ─────────────────────────────────────────
func _start_idle_animation() -> void:
	arm_state = ArmState.IDLE
	idle_oscillation_speed = 0.3 + arm_index * 0.05


func _process(delta: float) -> void:
	time_elapsed += delta
	if arm_state == ArmState.IDLE:
		# Gentle idle bobbing
		upper_arm.rotation_degrees.z = sin(time_elapsed * idle_oscillation_speed) * 3.0
		lower_arm.rotation_degrees.z = sin(time_elapsed * idle_oscillation_speed * 1.5) * 5.0
		arm_light.light_energy = 0.5 + sin(time_elapsed * 2.0) * 0.2

	elif arm_state == ArmState.LOCKDOWN:
		# Spin wildly
		upper_arm.rotation_degrees.y += delta * 200.0
		lower_arm.rotation_degrees.y -= delta * 300.0
		arm_light.light_color = Color(1.0, 0.1, 0.0)
		arm_light.light_energy = 2.0 + sin(time_elapsed * 20.0) * 1.5


# ── State Actions ──────────────────────────────────────────
func calibrate_countdown(step: int, total: int) -> void:
	arm_state = ArmState.CALIBRATING
	arm_light.light_color = Color(1.0, 0.8, 0.0)

	var t := create_tween()
	t.tween_property(upper_arm, "rotation_degrees:z", -30.0 + step * 6.0, 0.25)
	t.tween_property(lower_arm, "rotation_degrees:z", 15.0 - step * 3.0, 0.25)

	if step == 0:
		arm_state = ArmState.OPERATIONAL
		arm_light.light_color = Color(0.0, 1.0, 0.3)


func sync_grid_position(row: int, col: int) -> void:
	arm_state = ArmState.GRID_SYNC
	arm_light.light_color = Color(0.0, 0.8, 1.0)

	var target_pos := Vector3(col * 0.8 - 0.8, 0, row * 0.8 - 0.8)
	var t := create_tween()
	t.tween_property(self, "position", position + target_pos * 0.3, 0.4)
	t.tween_interval(0.2)
	t.tween_property(self, "position", position, 0.4)
	t.tween_callback(func(): arm_state = ArmState.OPERATIONAL)


func trigger_lockdown() -> void:
	arm_state = ArmState.LOCKDOWN


func recover_from_lockdown() -> void:
	arm_state = ArmState.IDLE
	upper_arm.rotation_degrees = Vector3.ZERO
	lower_arm.rotation_degrees = Vector3.ZERO
	arm_light.light_color = Color(0.3, 0.5, 1.0)
	arm_light.light_energy = 1.0
