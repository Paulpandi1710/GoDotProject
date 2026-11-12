extends Node3D
class_name StylizedVRHand

var base_mesh: MeshInstance3D
var left_pincer: Node3D
var right_pincer: Node3D

var tween_left: Tween
var tween_right: Tween

func _ready():
	_build_hand()
	open_hand()

func _build_hand():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.15)
	mat.metallic = 0.8
	mat.roughness = 0.3
	
	var accent_mat = StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.1, 0.8, 1.0) # Sci-fi cyan
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.1, 0.8, 1.0)
	accent_mat.emission_energy_multiplier = 2.0
	
	# base (wrist block)
	base_mesh = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = Vector3(0.08, 0.05, 0.1)
	base_mesh.mesh = bm
	base_mesh.material_override = mat
	add_child(base_mesh)
	
	# glowing core
	var core_mesh = MeshInstance3D.new()
	var cm = BoxMesh.new()
	cm.size = Vector3(0.05, 0.06, 0.05)
	core_mesh.mesh = cm
	core_mesh.material_override = accent_mat
	base_mesh.add_child(core_mesh)
	
	# left pincer root (pivot)
	left_pincer = Node3D.new()
	left_pincer.position = Vector3(-0.04, 0, -0.05)
	add_child(left_pincer)
	
	var lp_mesh = MeshInstance3D.new()
	var lpm = BoxMesh.new()
	lpm.size = Vector3(0.015, 0.04, 0.12)
	lp_mesh.mesh = lpm
	lp_mesh.position = Vector3(0, 0, -0.05) # offset from pivot
	lp_mesh.material_override = mat
	left_pincer.add_child(lp_mesh)
	
	# right pincer root (pivot)
	right_pincer = Node3D.new()
	right_pincer.position = Vector3(0.04, 0, -0.05)
	add_child(right_pincer)
	
	var rp_mesh = MeshInstance3D.new()
	var rpm = BoxMesh.new()
	rpm.size = Vector3(0.015, 0.04, 0.12)
	rp_mesh.mesh = rpm
	rp_mesh.position = Vector3(0, 0, -0.05) # offset from pivot
	rp_mesh.material_override = mat
	right_pincer.add_child(rp_mesh)
	
	# Add some simple joints logic for looks
	var joint_left = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.015
	cyl.bottom_radius = 0.015
	cyl.height = 0.042
	joint_left.mesh = cyl
	joint_left.position = Vector3(0, 0, 0)
	joint_left.material_override = accent_mat
	left_pincer.add_child(joint_left)
	
	var joint_right = MeshInstance3D.new()
	joint_right.mesh = cyl
	joint_right.position = Vector3(0, 0, 0)
	joint_right.material_override = accent_mat
	right_pincer.add_child(joint_right)

func open_hand():
	if tween_left: tween_left.kill()
	if tween_right: tween_right.kill()
	
	if ClassDB.class_exists("AudioManager"):
		AudioManager.play_3d_sound("clack", global_position, self)
	
	tween_left = create_tween()
	tween_left.tween_property(left_pincer, "rotation_degrees:y", 15.0, 0.15).set_trans(Tween.TRANS_SINE)
	
	tween_right = create_tween()
	tween_right.tween_property(right_pincer, "rotation_degrees:y", -15.0, 0.15).set_trans(Tween.TRANS_SINE)

func close_hand():
	if tween_left: tween_left.kill()
	if tween_right: tween_right.kill()
	
	if ClassDB.class_exists("AudioManager"):
		AudioManager.play_3d_sound("click", global_position, self)
	if typeof(VFXUtils) == TYPE_OBJECT or typeof(VFXUtils) == TYPE_DICTIONARY:
		# Tiny micro-burst of energy on close
		VFXUtils.spawn_energy_burst(self, global_position + Vector3(0,0, -0.1), Color(0.1, 0.8, 1.0), 0.3)
	
	tween_left = create_tween()
	tween_left.tween_property(left_pincer, "rotation_degrees:y", -8.0, 0.1).set_trans(Tween.TRANS_BOUNCE)
	
	tween_right = create_tween()
	tween_right.tween_property(right_pincer, "rotation_degrees:y", 8.0, 0.1).set_trans(Tween.TRANS_BOUNCE)
