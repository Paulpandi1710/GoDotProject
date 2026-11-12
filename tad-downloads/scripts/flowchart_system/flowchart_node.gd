extends RigidBody3D
class_name FlowchartNode

# The 4 Core Flowchart Shapes
enum NodeType { START_END, PROCESS, DECISION, INPUT_OUTPUT }

@export var node_type: NodeType = NodeType.PROCESS
@export var label_text: String = "Process"

# Connection Ports for the Cables
var input_port: CablePort
var output_port_1: CablePort
var output_port_2: CablePort # Only used for Diamonds (Yes/No branches)

func _ready():
	# Allow the hybrid_player.gd to grab this object
	
	
	add_to_group("flowchart_node")
	
	# Lock rotation so they stay flat on the drafting table
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	gravity_scale = 0.0 # Floating zero-G behavior for the glass table
	
	_build_3d_shape()
	_setup_cable_ports()

# ---------------------------------------------------------
# 1. PROCEDURAL 3D SHAPE GENERATION
# ---------------------------------------------------------
func _build_3d_shape():
	var mesh_inst = MeshInstance3D.new()
	var collision = CollisionShape3D.new()
	var material = StandardMaterial3D.new()
	material.metallic = 0.1
	material.roughness = 0.9
	
	match node_type:
		NodeType.START_END:
			mesh_inst.mesh = CapsuleMesh.new()
			mesh_inst.mesh.height = 2.0
			mesh_inst.mesh.radius = 0.5
			mesh_inst.rotation_degrees = Vector3(0, 0, 90)
			collision.shape = CapsuleShape3D.new()
			material.albedo_color = Color(0.2, 0.8, 0.3)
			
		NodeType.PROCESS:
			mesh_inst.mesh = BoxMesh.new()
			mesh_inst.mesh.size = Vector3(2.5, 1.0, 1.0)
			collision.shape = BoxShape3D.new()
			material.albedo_color = Color(0.2, 0.5, 1.0)
			
		NodeType.DECISION:
			mesh_inst.mesh = BoxMesh.new()
			mesh_inst.mesh.size = Vector3(1.5, 1.5, 1.0)
			mesh_inst.rotation_degrees = Vector3(0, 0, 45)
			collision.shape = BoxShape3D.new()
			material.albedo_color = Color(1.0, 0.6, 0.1)
			
		NodeType.INPUT_OUTPUT:
			mesh_inst.mesh = BoxMesh.new()
			mesh_inst.mesh.size = Vector3(2.5, 1.0, 1.0)
			collision.shape = BoxShape3D.new()
			material.albedo_color = Color(0.6, 0.2, 0.8)

	mesh_inst.material_override = material
	
	if node_type == NodeType.START_END:
		var coll_shape = CapsuleShape3D.new()
		coll_shape.height = 2.0
		coll_shape.radius = 0.5
		collision.shape = coll_shape
		collision.rotation_degrees = Vector3(0, 0, 90)
	elif node_type == NodeType.DECISION:
		collision.rotation_degrees = Vector3(0, 0, 45)
	
	add_child(mesh_inst)
	add_child(collision)
	
	var text_label = Label3D.new()
	text_label.text = label_text
	text_label.font_size = 64
	text_label.outline_size = 16
	text_label.position = Vector3(0, 0, 0.6)
	add_child(text_label)

# ---------------------------------------------------------
# 2. CABLE PORT SETUP
# ---------------------------------------------------------
func _setup_cable_ports():
	var label_lower = label_text.to_lower()
	var is_start = node_type == NodeType.START_END and label_lower == "start"
	var is_end = node_type == NodeType.START_END and label_lower == "end"

	# FIX: the Decision diamond is a 1.5x1.5 box rotated 45°, which makes
	# its visual top vertex sit much further out (~1.06 units) than a
	# normal box's flat top (~0.5 units). The old fixed 0.6 offset buried
	# the port marker inside the diamond's own mesh — invisible, and
	# unreachable by raycast since the diamond's collision blocked the
	# ray first. Decision now gets a taller offset to actually clear it.
	var port_offset: float = 1.2 if node_type == NodeType.DECISION else 0.6

	if not is_start:
		input_port = CablePort.new()
		input_port.is_input = true
		input_port.position = Vector3(0, port_offset, 0)
		add_child(input_port)

	if not is_end:
		output_port_1 = CablePort.new()
		output_port_1.is_input = false
		output_port_1.position = Vector3(0, -port_offset, 0)
		add_child(output_port_1)

	if node_type == NodeType.DECISION:
		output_port_1.position = Vector3(-1.2, -0.8, 0) # Yes
		output_port_2 = CablePort.new()
		output_port_2.is_input = false
		output_port_2.position = Vector3(1.2, -0.8, 0)  # No
		add_child(output_port_2)
