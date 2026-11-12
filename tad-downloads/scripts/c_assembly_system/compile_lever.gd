extends Area3D
class_name CompileLever

var readout_label: Label3D
var backend: CompilerBackend

func _ready():
	collision_layer = CollisionLayers.WORLD
	collision_mask = CollisionLayers.NONE
	monitorable = true

	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.8, 0.2, 0.6)
	col.shape = box
	add_child(col)

	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = box.size
	mesh_inst.mesh = box_mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.3, 0.2)
	mat.metallic = 0.9
	mat.roughness = 0.2
	mesh_inst.material_override = mat
	add_child(mesh_inst)

	var label = Label3D.new()
	label.text = "COMPILE"
	label.font_size = 32
	label.position = Vector3(0, 0.8, 0)
	add_child(label)

	readout_label = Label3D.new()
	readout_label.font_size = 28
	readout_label.outline_size = 8
	readout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	readout_label.width = 600
	readout_label.position = Vector3(0, 0.4, 0.4)
	add_child(readout_label)

	backend = CompilerBackend.new()
	add_child(backend)
	backend.compilation_succeeded.connect(_on_success)
	backend.compilation_failed.connect(_on_failure)

func pull():
	var mission = Missions.get_current_mission()
	if mission == null:
		print("COMPILE ERROR: no active mission.")
		return

	# NEW: gate the Assembly Desk behind the flowchart stage — this is
	# the actual bridge between the two stations.
	if not Missions.flowchart_stage_passed:
		readout_label.text = "Build and validate the flowchart at the Blueprint Table first."
		readout_label.modulate = Color(1.0, 0.6, 0.2)
		print("COMPILE BLOCKED: flowchart stage not passed yet.")
		return

	var tracks = get_tree().get_nodes_in_group("cooking_pot")
	if tracks.is_empty():
		print("COMPILE ERROR: no cooking pot found in scene.")
		return

	var track: CookingPot = tracks[0]
	var tokens = track.get_serialized_tokens()
	print("COMPILING TOKENS: ", tokens)

	# NEW: check the assembled sequence matches THIS mission's expected
	# tokens, not just "gcc accepted whatever was there."
	if tokens != mission.cartridge_sequence:
		readout_label.text = "Wrong sequence. Expected: %s" % [" ".join(mission.cartridge_sequence)]
		readout_label.modulate = Color(1.0, 0.3, 0.3)
		print("COMPILE RESULT: sequence mismatch. Got ", tokens, " expected ", mission.cartridge_sequence)
		return

	backend.compile_and_test(tokens, [], [])

func _on_success(msg: String):
	readout_label.text = msg
	readout_label.modulate = Color(0.3, 1.0, 0.4)
	print("COMPILE RESULT: ", msg)
	
	# VFX Burst
	if ClassDB.class_exists("VFXManager"):
		var burst = VFXManager.create_success_burst()
		burst.position = Vector3(0, 1.0, 0)
		add_child(burst)
		
	if ClassDB.class_exists("AudioManager"):
		AudioManager.play_3d_sound("success", Vector3(0, 1.0, 0), self)
	
	var mission = Missions.get_current_mission()
	var dish_name = mission.title if mission else "Code Cake"
	
	var pots = get_tree().get_nodes_in_group("cooking_pot")
	if not pots.is_empty():
		var pot: CookingPot = pots[0]
		pot.transform_into_dish(dish_name)
		
	# NEW: Don't complete the mission here. The player must grab the Code Cake
	# and deliver it to the Menu Board to finish the flow.

func _on_failure(msg: String):
	readout_label.text = msg
	readout_label.modulate = Color(1.0, 0.3, 0.3)
	print("COMPILE RESULT: ", msg)
	
	# VFX Error Puff
	if ClassDB.class_exists("VFXManager"):
		var puff = VFXManager.create_error_puff()
		puff.position = Vector3(0, 0.5, 0.5)
		add_child(puff)
		
	if ClassDB.class_exists("AudioManager"):
		AudioManager.play_3d_sound("error", Vector3(0, 0.5, 0.5), self)
