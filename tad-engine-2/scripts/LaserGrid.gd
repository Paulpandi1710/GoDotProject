extends Node3D

# ============================================================
# LASER GRID — Engine 2, Automation Foundry
# Each layer deactivates as a prime number is found
# ============================================================

const LAYER_COUNT := 5
const LAYER_COLORS := [
	Color(1.0, 0.0, 0.0),   # Layer 0 — Red
	Color(1.0, 0.5, 0.0),   # Layer 1 — Orange
	Color(1.0, 1.0, 0.0),   # Layer 2 — Yellow
	Color(0.0, 1.0, 0.5),   # Layer 3 — Cyan
	Color(0.5, 0.0, 1.0),   # Layer 4 — Purple
]

var layers: Array = []
var layer_lights: Array = []
var active_layers: int = LAYER_COUNT


func _ready() -> void:
	_build_laser_layers()


func _build_laser_layers() -> void:
	for i in range(LAYER_COUNT):
		var layer_node := Node3D.new()
		layer_node.name = "LaserLayer_%d" % i
		layer_node.position = Vector3(0, 0, float(i) * 1.2 - (float(LAYER_COUNT) * 0.6))
		add_child(layer_node)
		layers.append(layer_node)

		# Horizontal laser beam bars
		for h in range(4):
			var beam := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(6.0, 0.04, 0.04)
			beam.mesh = box
			beam.position = Vector3(0, 0.5 + h * 0.6, 0)

			var mat := StandardMaterial3D.new()
			mat.albedo_color = LAYER_COLORS[i]
			mat.emission_enabled = true
			mat.emission = LAYER_COLORS[i]
			mat.emission_energy_multiplier = 3.0
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.85
			beam.set_surface_override_material(0, mat)
			layer_node.add_child(beam)

		# Vertical laser beam bars
		for v in range(3):
			var vbeam := MeshInstance3D.new()
			var vbox := BoxMesh.new()
			vbox.size = Vector3(0.04, 2.5, 0.04)
			vbeam.mesh = vbox
			vbeam.position = Vector3(-2.5 + v * 2.5, 1.25, 0)

			var vmat := StandardMaterial3D.new()
			vmat.albedo_color = LAYER_COLORS[i]
			vmat.emission_enabled = true
			vmat.emission = LAYER_COLORS[i]
			vmat.emission_energy_multiplier = 2.0
			vmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			vmat.albedo_color.a = 0.7
			vbeam.set_surface_override_material(0, vmat)
			layer_node.add_child(vbeam)

		# Emitter nodes (corner posts)
		for corner in [Vector3(-3.0, 0, 0), Vector3(3.0, 0, 0)]:
			var emitter := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.08
			cyl.bottom_radius = 0.1
			cyl.height = 2.8
			emitter.mesh = cyl
			emitter.position = corner
			var emat := StandardMaterial3D.new()
			emat.albedo_color = Color(0.2, 0.2, 0.25)
			emat.metallic = 0.9
			emitter.set_surface_override_material(0, emat)
			layer_node.add_child(emitter)

		# Point light per layer
		var light := OmniLight3D.new()
		light.light_color = LAYER_COLORS[i]
		light.light_energy = 2.0
		light.omni_range = 4.0
		light.position = Vector3(0, 1.5, 0)
		layer_node.add_child(light)
		layer_lights.append(light)

	_start_pulse_animation()


func _start_pulse_animation() -> void:
	for i in range(layers.size()):
		var light: OmniLight3D = layer_lights[i]
		var freq: float = 1.0 + float(i) * 0.3
		_pulse_layer(light, freq)


func _pulse_layer(light: OmniLight3D, freq: float) -> void:
	var t := create_tween().set_loops()
	t.tween_property(light, "light_energy", 3.5, 1.0 / freq)
	t.tween_property(light, "light_energy", 1.5, 1.0 / freq)


# ── Deactivate a specific layer ────────────────────────────
func deactivate_layer(layer_index: int) -> void:
	if layer_index >= layers.size():
		return

	var layer: Node3D = layers[layer_index]
	var light: OmniLight3D = layer_lights[layer_index]
	active_layers -= 1

	# Dramatic shutdown sequence
	var t := create_tween()
	# Flash white
	t.tween_property(light, "light_color", Color.WHITE, 0.1)
	t.tween_property(light, "light_energy", 8.0, 0.1)
	# Fade out
	t.tween_property(light, "light_energy", 0.0, 0.4)
	# Shrink and hide
	t.tween_property(layer, "scale", Vector3(1.0, 0.0, 1.0), 0.5)
	t.tween_callback(func(): layer.visible = false)

	# Sparks VFX — move beams outward
	for child in layer.get_children():
		if child is MeshInstance3D:
			var bt := create_tween()
			bt.tween_property(child, "position:y", child.position.y + randf_range(-0.5, 0.5), 0.3)


func deactivate_all_layers_sequentially(_primes: Array, delay_per_layer: float) -> void:
	for i in range(layers.size()):
		var idx: int = i
		var t := create_tween()
		t.tween_interval(float(i) * delay_per_layer)
		t.tween_callback(func(): deactivate_layer(idx))


func reactivate_all() -> void:
	active_layers = LAYER_COUNT
	for i in range(layers.size()):
		layers[i].visible = true
		layers[i].scale = Vector3.ONE
		layer_lights[i].light_energy = 2.0
	_start_pulse_animation()


func all_clear() -> bool:
	return active_layers <= 0
