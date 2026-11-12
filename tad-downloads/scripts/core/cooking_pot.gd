extends Area3D
class_name CookingPot

# ==============================================================================
# COOKING POT CATCHER
# ==============================================================================
# Replaces MagneticTrack for a more tactile VR kitchen feel.
# Ingredients dropped in will physically stack if they match the expected
# recipe type. If they do not match, the pot physically rejects them outwards.
# ==============================================================================

@export var expected_types: Array[int] = []

var accepted_ingredients: Array = []
const REJECT_IMPULSE_STRENGTH: float = 3.5

func _ready():
	add_to_group("cooking_pot")
	body_entered.connect(_on_body_entered)
	
	if ClassDB.class_exists("VFXManager"):
		var steam = VFXManager.create_steam_emitter()
		steam.position = Vector3(0, 0.3, 0)
		add_child(steam)

func _on_body_entered(body: Node3D):
	if body is HardwareCartridge:
		_process_dropped_ingredient(body)

func _process_dropped_ingredient(cart: HardwareCartridge):
	# If track is "full" matching the expected type count, reject new stuff
	if accepted_ingredients.size() >= expected_types.size():
		_reject_ingredient(cart)
		return
		
	var expected = expected_types[accepted_ingredients.size()]
	
	if cart.cartridge_type == expected:
		# Valid! Let it keep its physics and stack in the pot
		accepted_ingredients.append(cart)
		cart.add_to_group("pot_contents")
		cart.gravity_scale = 1.0 # Ensure it clatters down
		cart.freeze = false
		if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
			VFXUtils.spawn_energy_burst(self, cart.global_position, Color(0.2, 1.0, 0.4))
	else:
		_reject_ingredient(cart)

func transform_into_dish(dish_name: String):
	print("POT: Transforming valid ingredients into a delicious ", dish_name, "!")
	clear_pot()
	
	# Spawn visual dish here
	var dish = RigidBody3D.new()
	dish.add_to_group("grabbable")
	dish.add_to_group("code_cake")
	dish.gravity_scale = 1.0
	
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.5
	shape.height = 0.2
	col.shape = shape
	dish.add_child(col)
	
	var dish_mesh = MeshInstance3D.new()
	var dish_shape = CylinderMesh.new()
	dish_shape.top_radius = 0.5
	dish_shape.bottom_radius = 0.3
	dish_shape.height = 0.2
	dish_mesh.mesh = dish_shape
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.4) # Golden brown cake/dish
	mat.roughness = 0.5
	dish_mesh.material_override = mat
	dish.add_child(dish_mesh)
	
	get_tree().root.add_child(dish)
	dish.global_position = global_position + Vector3(0, 0.8, 0) # Pop out of pot
	
	if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
		VFXUtils.spawn_energy_burst(self, global_position + Vector3(0, 0.8, 0), Color(0.8, 0.9, 1.0))

func _reject_ingredient(cart: HardwareCartridge):
	print("POT REJECTED: wrong type for current recipe step")
	# Fire visual effect at pot center
	if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
		# Assume VFXUtils exists as singleton as in magnetic_track.gd
		VFXUtils.spawn_energy_burst(self, global_position, Color(1.0, 0.3, 0.2))
	
	# Unfreeze in case it was being held or stuck
	cart.freeze = false
	
	# Apply an explosion-like upward/outward impulse
	var away_dir = (cart.global_position - global_position).normalized()
	if away_dir.length_squared() < 0.01:
		away_dir = Vector3(0, 1, 0.2).normalized()
	
	cart.apply_central_impulse(away_dir * REJECT_IMPULSE_STRENGTH + Vector3(0, 3.5, 0))

func get_serialized_tokens() -> Array:
	var tokens = []
	for cart in accepted_ingredients:
		if is_instance_valid(cart):
			tokens.append(cart.token_name)
	return tokens

func clear_pot():
	for i in range(accepted_ingredients.size()):
		if is_instance_valid(accepted_ingredients[i]):
			accepted_ingredients[i].queue_free()
	accepted_ingredients.clear()
