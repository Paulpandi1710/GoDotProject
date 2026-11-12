extends Node3D
class_name LaserGrid

var grid_layers: Array[MeshInstance3D] = []

func build_grid(tiers: int):
	for i in range(tiers):
		var laser = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		
		# Shape the laser beam
		cylinder.height = 12.0
		cylinder.top_radius = 0.1
		cylinder.bottom_radius = 0.1
		
		# Apply glowing red material
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.RED
		mat.emission_enabled = true
		mat.emission = Color.RED
		mat.emission_energy_multiplier = 8.0
		
		cylinder.material = mat
		laser.mesh = cylinder
		laser.rotation.z = deg_to_rad(90)
		laser.position = Vector3(0, (i * 1.5) + 1.0, -10) # Stack them vertically at the door
		
		grid_layers.append(laser)
		add_child(laser)

func shutdown_layer(layer_number: int):
	var target = layer_number - 1
	if target < grid_layers.size():
		var laser = grid_layers[target]
		var mat = laser.mesh.surface_get_material(0)
		
		# Turn the laser green to signify bypass
		mat.albedo_color = Color.GREEN
		mat.emission = Color.GREEN
		
		# Animate the laser shrinking into nothing
		var tween = create_tween()
		tween.tween_property(laser, "scale:y", 0.0, 0.5)
