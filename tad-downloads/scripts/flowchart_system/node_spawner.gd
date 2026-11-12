extends Area3D
class_name FlowchartNodeSpawner

@export var spawned_node_type: int = FlowchartNode.NodeType.PROCESS
@export var spawned_label: String = "Process"
@export var bin_label_text: String = "PROCESS"

func _ready():
	collision_layer = CollisionLayers.WORLD
	collision_mask = CollisionLayers.NONE
	monitorable = true

	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.8, 0.8, 0.8)
	col.shape = box
	add_child(col)

	var label = Label3D.new()
	label.name = "SpawnerLabel"
	label.text = bin_label_text
	label.font_size = 32
	label.outline_size = 8
	label.modulate = Color(0.85, 0.65, 0.35) # Warm kitchen tone
	label.position = Vector3(0, 0.6, 0)
	add_child(label)

func spawn_node() -> FlowchartNode:
	var node = FlowchartNode.new()
	node.node_type = spawned_node_type
	node.label_text = spawned_label
	get_tree().root.add_child(node)
	node.global_position = global_position + Vector3(0, 0, 0.6)
	return node

func on_hover(is_hovered: bool):
	var label = get_node_or_null("SpawnerLabel")
	if label != null and label is Label3D:
		if is_hovered:
			label.modulate = Color(1.0, 1.0, 0.8) # Bright highlight
		else:
			label.modulate = Color(0.85, 0.65, 0.35) # Back to original
