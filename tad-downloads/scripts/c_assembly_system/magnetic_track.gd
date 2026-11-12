extends Node3D
class_name MagneticTrack
# ==============================================================================
# MAGNETIC EXECUTION TRACK / COOKING POT SLOTS
# Snaps cartridges into a linear sequence for compilation.
#
# Physical shape-key rejection: if expected_types is set (one
# CartridgeType per slot, usually pulled from the active mission's
# cartridge_types), placing the WRONG type of ingredient in a slot no
# longer silently fails — it gets a visible bounce-away impulse and a
# particle burst. Leave expected_types empty for old "accept anything"
# behavior (used by early test scenes).
# ==============================================================================
@export var slot_count: int = 5
@export var slot_spacing: float = 1.5
@export var expected_types: Array[int] = []

var snapped_cartridges: Array = []
var slot_positions: Array = []

const SNAP_RADIUS: float = 1.4
const REJECT_IMPULSE_STRENGTH: float = 3.0

func _ready():
	add_to_group("magnetic_track")
	_generate_track_slots()

func _generate_track_slots():
	for i in range(slot_count):
		var pos = Vector3(i * slot_spacing - ((slot_count - 1) * slot_spacing * 0.5), 0, 0)
		slot_positions.append(pos)

		var slot_mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(1.3, 0.1, 0.7)
		slot_mesh.mesh = box

		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.2, 0.3, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(0.1, 0.4, 0.8)
		mat.emission_energy_multiplier = 0.5
		slot_mesh.material_override = mat

		slot_mesh.position = pos
		add_child(slot_mesh)
		snapped_cartridges.append(null)

func try_snap_cartridge(cart: HardwareCartridge) -> bool:
	var closest_empty_dist: float = INF
	var closest_empty_index: int = -1

	for i in range(slot_positions.size()):
		if snapped_cartridges[i] != null:
			continue
		var pos_global = to_global(slot_positions[i])
		var d = cart.global_position.distance_to(pos_global)
		if d < closest_empty_dist:
			closest_empty_dist = d
			closest_empty_index = i

	if closest_empty_index == -1 or closest_empty_dist >= SNAP_RADIUS:
		print("CARTRIDGE NOT SNAPPED: nearest EMPTY slot was ", closest_empty_dist, " away (need < ", SNAP_RADIUS, ")")
		return false

	var slot_global = to_global(slot_positions[closest_empty_index])

	if closest_empty_index < expected_types.size():
		var expected = expected_types[closest_empty_index]
		if cart.cartridge_type != expected:
			_reject_cartridge(cart, slot_global)
			return false

	snapped_cartridges[closest_empty_index] = cart
	cart.global_position = slot_global + Vector3(0, 0.4, 0)
	cart.freeze = true
	return true

func _reject_cartridge(cart: HardwareCartridge, slot_global: Vector3):
	print("REJECTED: wrong type for this slot")
	VFXUtils.spawn_energy_burst(self, slot_global, Color(1.0, 0.3, 0.2))
	var away_dir = (cart.global_position - slot_global).normalized()
	if away_dir.length_squared() < 0.01:
		away_dir = Vector3(0, 1, 0.5).normalized()
	cart.freeze = false
	cart.apply_central_impulse(away_dir * REJECT_IMPULSE_STRENGTH + Vector3(0, 2.0, 0))
func get_serialized_tokens() -> Array:
	var tokens = []
	for cart in snapped_cartridges:
		if cart != null and cart is HardwareCartridge:
			tokens.append(cart.token_name)
	return tokens

func clear_track():
	for i in range(snapped_cartridges.size()):
		if is_instance_valid(snapped_cartridges[i]):
			snapped_cartridges[i].queue_free()
		snapped_cartridges[i] = null
