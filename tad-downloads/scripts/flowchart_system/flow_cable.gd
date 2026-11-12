extends Node3D
class_name FlowCable

# ==============================================================================
# FLOW CABLE ENGINE (PHYSICAL WIRE ATTACHMENT)
# ==============================================================================

var plug_body: RigidBody3D
var wire_mesh: MeshInstance3D 

var start_port: CablePort = null
var target_port: CablePort = null
var is_plugged_in: bool = false

func _ready():
	
	add_to_group("flow_cable")
	_build_cable_visuals()
	
func _build_cable_visuals():
	plug_body = RigidBody3D.new()
	plug_body.gravity_scale = 0.0
	plug_body.axis_lock_angular_x = true
	plug_body.axis_lock_angular_y = true
	plug_body.axis_lock_angular_z = true
	plug_body.add_to_group("grabbable")
	
	var plug_col = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.15
	plug_col.shape = sphere_shape
	plug_body.add_child(plug_col)
	
	var plug_vis = MeshInstance3D.new()
	var s_mesh = SphereMesh.new()
	s_mesh.radius = 0.15
	s_mesh.height = 0.3
	plug_vis.mesh = s_mesh
	
	var plug_mat = StandardMaterial3D.new()
	plug_mat.albedo_color = Color(1.0, 0.8, 0.1)
	plug_mat.emission_enabled = true
	plug_mat.emission = Color(1.0, 0.8, 0.1)
	plug_vis.material_override = plug_mat
	plug_body.add_child(plug_vis)
	add_child(plug_body)
	
	wire_mesh = MeshInstance3D.new()
	var c_mesh = CylinderMesh.new()
	c_mesh.top_radius = 0.03
	c_mesh.bottom_radius = 0.03
	wire_mesh.mesh = c_mesh
	
	var wire_mat = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.2, 0.8, 1.0)
	wire_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wire_mat.albedo_color.a = 0.8
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(0.1, 0.6, 1.0)
	wire_mesh.material_override = wire_mat
	add_child(wire_mesh)

func connect_to_start(port: CablePort):
	start_port = port
	global_position = start_port.global_position
	plug_body.global_position = global_position + Vector3(0, 0, 0.4)

func snap_to_target(port: CablePort):
	target_port = port
	is_plugged_in = true
	plug_body.global_position = target_port.global_position
	plug_body.freeze = true

	var mat: StandardMaterial3D = wire_mesh.material_override
	mat.albedo_color = Color(0.2, 1.0, 0.4, 0.9)
	mat.emission = Color(0.2, 1.0, 0.4)

	print("WIRE CONNECTED: ", start_port.get_parent().label_text, " -> ", target_port.get_parent().label_text)

func discard():
	if start_port:
		start_port.is_occupied = false
	if target_port:
		target_port.is_occupied = false
	print("WIRE DISCARDED: released too far from any input port")
	queue_free()

func _process(_delta):
	if start_port == null:
		return
		
	var start_pos = start_port.global_position
	var end_pos = plug_body.global_position
	
	if is_plugged_in and target_port != null:
		end_pos = target_port.global_position
		plug_body.global_position = end_pos
		
	var distance = start_pos.distance_to(end_pos)
	if distance > 0.01:
		wire_mesh.global_position = start_pos.lerp(end_pos, 0.5)
		var cyl: CylinderMesh = wire_mesh.mesh
		cyl.height = distance
		wire_mesh.look_at(end_pos, Vector3.UP)
		wire_mesh.rotate_x(PI / 2.0)
