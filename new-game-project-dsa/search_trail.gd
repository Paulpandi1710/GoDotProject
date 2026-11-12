## ============================================================
## SEARCH TRAIL (Sequential Traversal Visualizer)
## ============================================================
## Draws glowing cybernetic energy lines linking checked nodes
## sequentially (0 -> 1 -> 2...). Reinforces the physical
## reality that Linear Search cannot skip elements.
## ============================================================

extends Node3D
class_name SearchTrail

var segments: Array[MeshInstance3D] = []
var trail_material: StandardMaterial3D
var success_material: StandardMaterial3D

const C_TRAIL_ACTIVE := Color(0.0, 0.75, 1.0, 0.8)
const C_TRAIL_SUCCESS := Color(0.2, 1.0, 0.45, 0.95)

func _init():
	_ensure_materials()

func _ready():
	_ensure_materials()

func _ensure_materials():
	if trail_material != null:
		return

	trail_material = StandardMaterial3D.new()
	trail_material.albedo_color = C_TRAIL_ACTIVE
	trail_material.emission_enabled = true
	trail_material.emission = Color(0.0, 0.75, 1.0)
	trail_material.emission_energy_multiplier = 0.5
	trail_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	success_material = StandardMaterial3D.new()
	success_material.albedo_color = C_TRAIL_SUCCESS
	success_material.emission_enabled = true
	success_material.emission = Color(0.2, 1.0, 0.45)
	success_material.emission_energy_multiplier = 0.8
	success_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func add_segment(from_pos: Vector3, to_pos: Vector3):
	_ensure_materials()
	var line_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()

	var distance = from_pos.distance_to(to_pos)
	box.size = Vector3(0.06, 0.06, distance)
	line_mesh.mesh = box
	line_mesh.material_override = trail_material

	# Position midway
	line_mesh.position = (from_pos + to_pos) / 2.0
	line_mesh.look_at_from_position(line_mesh.position, to_pos, Vector3.UP)

	add_child(line_mesh)
	segments.append(line_mesh)

	if is_inside_tree() and get_tree() != null:
		line_mesh.scale = Vector3(0.1, 0.1, 1.0)
		var tween = create_tween()
		if tween != null:
			tween.tween_property(line_mesh, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)

func illuminate_success():
	_ensure_materials()
	for seg in segments:
		if is_instance_valid(seg):
			seg.material_override = success_material
			if is_inside_tree() and get_tree() != null:
				var tween = create_tween()
				if tween != null:
					tween.tween_property(seg, "scale", Vector3(1.6, 1.6, 1.0), 0.3)
					tween.tween_property(seg, "scale", Vector3.ONE, 0.3)

func clear_trail():
	for seg in segments:
		if is_instance_valid(seg):
			seg.queue_free()
	segments.clear()
