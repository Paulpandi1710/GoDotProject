extends Node3D
class_name MenuBoard

# ==============================================================================
# MENU BOARD
# ==============================================================================
# A physical wall-mounted board that visually archives cooked dishes.
# Displays 3D ticket cards with a small color-coded mesh patch.
# ==============================================================================

var next_slot_index: int = 0
const COLUMNS = 2

func _ready():
	add_to_group("menu_board")
	
	# Add the giant wooden board backdrop
	var board_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(4.0, 3.0, 0.1)
	board_mesh.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.2, 0.1) # Dark wood
	mat.roughness = 0.8
	board_mesh.material_override = mat
	add_child(board_mesh)

	var serve_area = Area3D.new()
	serve_area.position = Vector3(0, -2.2, 0)
	var serve_col = CollisionShape3D.new()
	var serve_box = BoxShape3D.new()
	serve_box.size = Vector3(5.0, 1.0, 3.0)
	serve_col.shape = serve_box
	serve_area.add_child(serve_col)
	
	var serve_label = Label3D.new()
	serve_label.text = "SERVE DISH HERE"
	serve_label.font_size = 40
	serve_label.outline_size = 10
	serve_label.modulate = Color(0.3, 1.0, 0.4)
	serve_label.position = Vector3(0, 0.8, 0.2)
	serve_area.add_child(serve_label)
	
	serve_area.body_entered.connect(_on_serve_area_entered)
	add_child(serve_area)

	if Engine.has_singleton("Missions") or typeof(Missions) != TYPE_NIL:
		Missions.mission_completed.connect(_on_mission_completed)

func _on_serve_area_entered(body: Node3D):
	if body.is_in_group("code_cake"):
		print("MENU BOARD: Dish served successfully!")
		if Engine.has_singleton("Missions") or typeof(Missions) != TYPE_NIL:
			Missions.complete_current_mission()
		body.queue_free()

func _on_mission_completed(mission: MissionData):
	add_dish_to_menu(mission.title, Color(1.0, 0.8, 0.4))


func add_dish_to_menu(dish_name: String, dish_color: Color):
	var row: int = int(next_slot_index / float(COLUMNS))
	var col: int = next_slot_index % COLUMNS
	
	var offset_x = col * 1.8 - 0.9
	var offset_y = -(row * 0.8) + 1.0
	
	# Create the paper ticket
	var card = MeshInstance3D.new()
	var card_mesh = BoxMesh.new()
	card_mesh.size = Vector3(1.6, 0.6, 0.02)
	card.mesh = card_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.95, 0.9) # Off-white card stock
	mat.roughness = 0.9
	card.material_override = mat
	
	# Create the dish name text
	var label = Label3D.new()
	label.text = dish_name
	label.font_size = 36
	label.outline_size = 0 # Look like ink on paper
	label.modulate = Color(0.1, 0.1, 0.15)
	label.position = Vector3(0.1, 0, 0.02)
	card.add_child(label)
	
	# Create a tiny 3D icon patch for the dish color
	var icon = MeshInstance3D.new()
	var icon_mesh = SphereMesh.new()
	icon_mesh.radius = 0.15
	icon_mesh.height = 0.3
	icon.mesh = icon_mesh
	var icon_mat = StandardMaterial3D.new()
	icon_mat.albedo_color = dish_color
	icon_mat.roughness = 0.5
	icon.material_override = icon_mat
	icon.position = Vector3(-0.55, 0, 0.03)
	card.add_child(icon)
	
	card.position = Vector3(offset_x, offset_y, 0.05)
	add_child(card)
	
	# Tween pop-in for tactile VR feel
	card.scale = Vector3(0.01, 0.01, 0.01)
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector3(1, 1, 1), 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
		VFXUtils.spawn_energy_burst(self, global_position + card.position, Color(1,1,1))
		
	next_slot_index += 1
