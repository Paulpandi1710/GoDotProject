extends Area3D
class_name TraceLever

signal validation_result(is_valid: bool, message: String)

var readout_label: Label3D

func _ready():
	collision_layer = CollisionLayers.WORLD
	collision_mask = CollisionLayers.NONE
	monitorable = true

	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.8, 1.2, 0.4)
	col.shape = box
	add_child(col)

	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = box.size
	mesh_inst.mesh = box_mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.7, 0.1)
	mat.metallic = 0.9
	mat.roughness = 0.2
	mesh_inst.material_override = mat
	add_child(mesh_inst)

	var label = Label3D.new()
	label.text = "TRACE"
	label.font_size = 32
	label.position = Vector3(0, 0.8, 0)
	add_child(label)

	readout_label = Label3D.new()
	readout_label.font_size = 28
	readout_label.outline_size = 8
	readout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	readout_label.width = 500
	readout_label.position = Vector3(0, -1.0, 0)
	add_child(readout_label)

func pull():
	var nodes = get_tree().get_nodes_in_group("flowchart_node")
	var cables = get_tree().get_nodes_in_group("flow_cable")

	var result = FlowchartValidator.validate_graph(nodes, cables)
	validation_result.emit(result["is_valid"], result["message"])

	readout_label.text = result["message"]
	readout_label.modulate = Color(0.3, 1.0, 0.4) if result["is_valid"] else Color(1.0, 0.3, 0.3)

	print("TRACE RESULT: ", result["message"])

	if result["is_valid"]:
		Missions.mark_flowchart_passed()
