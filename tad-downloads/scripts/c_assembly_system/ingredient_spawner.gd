extends Area3D
class_name IngredientSpawner

# ==============================================================================
# INGREDIENT SPAWNER (INFINITE RACK DISPENSER)
# ==============================================================================

@export var spawned_token_name: String = "int"
@export var spawned_type: HardwareCartridge.CartridgeType = HardwareCartridge.CartridgeType.DATA_TYPE
@export var rack_label_text: String = "INT (4B)"

func _ready():
	# NEW: without a collision shape, this Area3D was invisible to the
	# player's raycast — it could never be aimed at or clicked.
	collision_layer = CollisionLayers.WORLD
	collision_mask = CollisionLayers.NONE
	monitorable = true

	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(1.0, 1.0, 1.0)
	col.shape = box
	add_child(col)

	_setup_bin_visuals()

func _setup_bin_visuals():
	var label = Label3D.new()
	label.text = rack_label_text
	label.font_size = 40
	label.outline_size = 10
	label.modulate = Color(0.85, 0.65, 0.35) # Warm copper tone
	label.position = Vector3(0, 0.0, 0.51) # Placed exactly flat against the front of the crate
	add_child(label)

func spawn_cartridge() -> HardwareCartridge:
	var cart = HardwareCartridge.new()
	cart.token_name = spawned_token_name
	cart.cartridge_type = spawned_type
	get_tree().root.add_child(cart)          # add to tree FIRST
	cart.global_position = global_position + Vector3(0, 0, 0.5)  # THEN position it
	return cart

func on_hover(is_hovered: bool):
	var crate = get_node_or_null("CrateMesh")
	if crate != null and crate is MeshInstance3D and crate.material_override != null:
		var mat = crate.material_override as StandardMaterial3D
		if is_hovered:
			mat.emission_enabled = true
			mat.emission = mat.albedo_color
			mat.emission_energy_multiplier = 0.6
		else:
			mat.emission_enabled = false
