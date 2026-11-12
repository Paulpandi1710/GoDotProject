extends RigidBody3D
class_name HardwareCartridge

# ==============================================================================
# HARDWARE CARTRIDGE (SHAPE-KEYED C-SYNTAX TOKEN)
# ==============================================================================

enum CartridgeType { DATA_TYPE, VARIABLE, OPERATOR, VALUE, KEYWORD, LOOP, FLOWCHART }
enum SocketShape { TRIANGLE, SQUARE, RECTANGLE }

@export var token_name: String = "int"
@export var cartridge_type: CartridgeType = CartridgeType.DATA_TYPE
@export var socket_shape: SocketShape = SocketShape.TRIANGLE

var label_3d: Label3D
var mesh_instance: MeshInstance3D

func _ready():
	add_to_group("grabbable")
	add_to_group("c_cartridge")
	gravity_scale = 0.0
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	
	contact_monitor = true
	max_contacts_reported = 2
	body_entered.connect(_on_body_entered)
	
	_build_cartridge_mesh()

func _on_body_entered(_body: Node):
	if linear_velocity.length_squared() > 0.2:
		if ClassDB.class_exists("AudioManager"):
			AudioManager.play_3d_sound("clack", global_position, self)

func _build_cartridge_mesh():
	mesh_instance = MeshInstance3D.new()
	var collision = CollisionShape3D.new()
	var coll_box = BoxShape3D.new()
	coll_box.size = Vector3(0.4, 0.3, 0.2)
	collision.shape = coll_box
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = coll_box.size
	mesh_instance.mesh = box_mesh
	
	var mat = StandardMaterial3D.new()
	mat.metallic = 0.7
	mat.roughness = 0.3
	
	match cartridge_type:
		CartridgeType.DATA_TYPE:
			mat.albedo_color = Color(0.2, 0.6, 1.0) # Blue
			socket_shape = SocketShape.TRIANGLE
		CartridgeType.VARIABLE:
			mat.albedo_color = Color(0.2, 0.9, 0.3) # Green
			socket_shape = SocketShape.SQUARE
		CartridgeType.OPERATOR:
			mat.albedo_color = Color(1.0, 0.6, 0.1) # Orange
			socket_shape = SocketShape.RECTANGLE
		CartridgeType.VALUE:
			mat.albedo_color = Color(0.8, 0.3, 0.8) # Purple
		CartridgeType.KEYWORD:
			mat.albedo_color = Color(0.9, 0.2, 0.2) # Red
		CartridgeType.LOOP:
			mat.albedo_color = Color(0.9, 0.1, 0.5) # Neon Pink
			socket_shape = SocketShape.RECTANGLE
		CartridgeType.FLOWCHART:
			mat.albedo_color = Color(0.3, 0.3, 0.3) # Dark grey
			socket_shape = SocketShape.SQUARE
			
	mesh_instance.material_override = mat
	add_child(mesh_instance)
	add_child(collision)
	
	label_3d = Label3D.new()
	label_3d.text = token_name
	label_3d.font_size = 32 # Scaled down
	label_3d.outline_size = 8
	label_3d.position = Vector3(0, 0, 0.11) # flush with 0.2/2 thickness
	add_child(label_3d)
