extends Area3D
class_name CablePort

# ==============================================================================
# CABLE PORT (WIRE CONNECTION POINT)
# ==============================================================================

@export var is_input: bool = true
var is_occupied: bool = false

func _ready():
	add_to_group("cable_port")
	collision_layer = CollisionLayers.PORT
	collision_mask = CollisionLayers.NONE
	monitorable = true
	monitoring = false

	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.35
	col.shape = shape
	add_child(col)

	# NEW: visible marker so the player (and you, testing) can actually see
	# where a port is — previously fully invisible, unaimable in practice.
	var marker = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	marker.mesh = sphere

	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.albedo_color = Color(1.0, 0.9, 0.2) if not is_input else Color(0.2, 1.0, 0.6)
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 1.5
	marker.material_override = mat
	add_child(marker)
