extends Node3D
class_name EngineZeroCore

const PlayerScript = preload("res://scripts/player/hybrid_player.gd")
const ChefAIScript = preload("res://scripts/core/chef_ai.gd")

func _ready():
	_build_lighting()
	_build_floor_and_walls()
	_build_recipe_board()
	_build_mission_ui()
	
	var mission = Missions.get_current_mission()
	_build_cooking_station(mission)
	_build_ingredient_wall()
	
	var chef = ChefAIScript.new()
	# Position managed by ChefAI._ready()
	add_child(chef)

	var player = PlayerScript.new()
	add_child(player)

	if mission:
		var problem_label = Label3D.new()
		problem_label.text = mission.problem_statement
		problem_label.font_size = 36
		problem_label.outline_size = 10
		problem_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		problem_label.width = 900
		problem_label.position = Vector3(0, 4.0, -13.8) # Above ingredient wall
		add_child(problem_label)


func _build_lighting():
	# --- World Environment (cinematic post-processing) ---
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.06, 0.04, 0.02)
	
	# Ambient
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.38, 0.22)
	env.ambient_light_energy = 0.55
	
	# Glow / bloom
	env.glow_enabled = true
	env.glow_intensity = 1.4
	env.glow_bloom = 0.18
	env.glow_hdr_threshold = 0.7
	
	# SSAO (screen-space ambient occlusion for depth)
	env.ssao_enabled = true
	env.ssao_radius = 0.8
	env.ssao_intensity = 1.6
	
	# Tone-mapping
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0
	
	# Subtle warm dust fog
	env.fog_enabled = true
	env.fog_density = 0.003
	env.fog_aerial_perspective = 0.12
	
	env_node.environment = env
	add_child(env_node)

	# --- Directional light: cool ceiling wash ---
	var sun = DirectionalLight3D.new()
	sun.light_color = Color(0.85, 0.9, 1.0)
	sun.light_energy = 0.4
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-70, 15, 0)
	add_child(sun)

	# --- Main OmniLight over cooking station ---
	var pendant = OmniLight3D.new()
	pendant.light_color = Color(1.0, 0.78, 0.45)
	pendant.light_energy = 7.0
	pendant.omni_range = 16.0
	pendant.position = Vector3(0, 5.2, -3.0)
	add_child(pendant)

	# --- SpotLight: Blueprint Table accent ---
	var blueprint_spot = SpotLight3D.new()
	blueprint_spot.light_color = Color(0.85, 0.75, 1.0) # Cool purple-white
	blueprint_spot.light_energy = 4.5
	blueprint_spot.spot_range = 8.0
	blueprint_spot.spot_angle = 35.0
	blueprint_spot.position = Vector3(6.5, 5.5, -0.5)
	blueprint_spot.rotation_degrees = Vector3(-60, -90, 0)
	add_child(blueprint_spot)

	# --- SpotLight: Serving window accent ---
	var window_spot = SpotLight3D.new()
	window_spot.light_color = Color(0.3, 1.0, 0.8) # Glow cyan
	window_spot.light_energy = 3.0
	window_spot.spot_range = 6.0
	window_spot.spot_angle = 45.0
	window_spot.position = Vector3(0, 5.0, -7.6)
	window_spot.rotation_degrees = Vector3(-80, 0, 0)
	add_child(window_spot)

	# --- Over recipe board ---
	var recipe_light = OmniLight3D.new()
	recipe_light.light_color = Color(0.9, 0.82, 0.65)
	recipe_light.light_energy = 3.5
	recipe_light.omni_range = 9.0
	recipe_light.position = Vector3(5.5, 4.5, -0.5)
	add_child(recipe_light)

	# --- Over ingredient wall ---
	var wall_light = OmniLight3D.new()
	wall_light.light_color = Color(0.9, 0.82, 0.65)
	wall_light.light_energy = 4.0
	wall_light.omni_range = 12.0
	wall_light.position = Vector3(0.0, 5.0, -7.5)
	add_child(wall_light)


func _build_floor_and_walls():
	var floor_body = StaticBody3D.new()
	var floor_col = CollisionShape3D.new()
	var floor_box = BoxShape3D.new()
	floor_box.size = Vector3(14, 0.5, 10)
	floor_col.shape = floor_box
	floor_body.position = Vector3(0, -0.25, -3.0)
	floor_body.add_child(floor_col)
	add_child(floor_body)

	var floor_mesh = MeshInstance3D.new()
	var floor_mesh_box = BoxMesh.new()
	floor_mesh_box.size = floor_box.size
	floor_mesh.mesh = floor_mesh_box
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.32, 0.20, 0.11)
	floor_mat.roughness = 0.85
	floor_mat.metallic = 0.05
	floor_mesh.material_override = floor_mat
	floor_body.add_child(floor_mesh)

	# Central kitchen floor rug
	var rug = MeshInstance3D.new()
	var rug_mesh = BoxMesh.new()
	rug_mesh.size = Vector3(8.0, 0.05, 5.0)
	rug.mesh = rug_mesh
	rug.position = Vector3(0, 0.01, -2.5)
	var rug_mat = StandardMaterial3D.new()
	rug_mat.albedo_color = Color(0.18, 0.38, 0.48)
	rug_mat.roughness = 0.95
	rug.material_override = rug_mat
	add_child(rug)

	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.52, 0.34, 0.22)
	wall_mat.roughness = 0.85
	
	# Helper to spawn wall panels
	var build_wall = func(w_size: Vector3, w_pos: Vector3):
		var w_mesh = MeshInstance3D.new()
		var w_box = BoxMesh.new()
		w_box.size = w_size
		w_mesh.mesh = w_box
		w_mesh.position = w_pos
		w_mesh.material_override = wall_mat
		var b_col = CollisionShape3D.new()
		var b_shape = BoxShape3D.new()  # FIX: use BoxShape3D, not BoxMesh
		b_shape.size = w_size
		b_col.shape = b_shape
		var stat = StaticBody3D.new()
		stat.add_child(b_col)
		w_mesh.add_child(stat)
		add_child(w_mesh)

	# Walls
	build_wall.call(Vector3(14, 6, 0.5), Vector3(0, 3, -8.0))   # Back
	build_wall.call(Vector3(14, 6, 0.5), Vector3(0, 3, 2.0))    # Front
	build_wall.call(Vector3(0.5, 6, 11), Vector3(-7.25, 3, -3.0)) # Left
	build_wall.call(Vector3(0.5, 6, 11), Vector3(7.25, 3, -3.0))  # Right
	
	# Ceiling
	var ceil_mat = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.18, 0.10, 0.05)
	var ceil_mesh = MeshInstance3D.new()
	var ceil_box = BoxMesh.new()
	ceil_box.size = Vector3(14, 0.5, 10)
	ceil_mesh.mesh = ceil_box
	ceil_mesh.position = Vector3(0, 6.25, -3.0)
	ceil_mesh.material_override = ceil_mat
	add_child(ceil_mesh)

	# --- Ceiling cross-beams (dark wood) ---
	var beam_mat = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.22, 0.12, 0.06)
	beam_mat.roughness = 0.9
	# Three beams running left-right across the ceiling
	for bz in [-1.5, -4.0, -6.5]:
		var beam = MeshInstance3D.new()
		var bm = BoxMesh.new()
		bm.size = Vector3(14.0, 0.22, 0.30)
		beam.mesh = bm
		beam.position = Vector3(0, 5.9, bz)
		beam.material_override = beam_mat
		add_child(beam)

	# Pendant lamp meshes hanging from beams
	var lamp_mat = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(0.72, 0.55, 0.3)
	lamp_mat.metallic = 0.9
	lamp_mat.roughness = 0.2
	var shade_mat = StandardMaterial3D.new()
	shade_mat.albedo_color = Color(0.25, 0.15, 0.08)
	shade_mat.metallic = 0.7
	shade_mat.roughness = 0.4
	# FIX: iterate directly over Vector3 values to avoid Variant type errors
	var lamp_positions: Array[Vector3] = [Vector3(0, 5.7, -3.0), Vector3(5.5, 5.7, -0.5)]
	for lp: Vector3 in lamp_positions:
		var rod = MeshInstance3D.new()
		var rod_m = CylinderMesh.new()
		rod_m.top_radius = 0.02
		rod_m.bottom_radius = 0.02
		rod_m.height = 0.5
		rod.mesh = rod_m
		rod.material_override = lamp_mat
		rod.position = lp
		add_child(rod)
		var shade = MeshInstance3D.new()
		var shade_m = CylinderMesh.new()
		shade_m.top_radius = 0.12
		shade_m.bottom_radius = 0.28
		shade_m.height = 0.22
		shade.mesh = shade_m
		shade.material_override = shade_mat
		shade.position = lp + Vector3(0, -0.35, 0)
		add_child(shade)

	# --- Serving Window: glowing cyan opening in back wall ---
	# Cyan emissive frame
	var win_mat = StandardMaterial3D.new()
	win_mat.albedo_color = Color(0.05, 0.6, 0.7)
	win_mat.emission_enabled = true
	win_mat.emission = Color(0.1, 0.9, 1.0)
	win_mat.emission_energy_multiplier = 2.5
	# Top bar
	var win_top = MeshInstance3D.new()
	var wt_m = BoxMesh.new()
	wt_m.size = Vector3(2.0, 0.12, 0.15)
	win_top.mesh = wt_m
	win_top.material_override = win_mat
	win_top.position = Vector3(0, 3.5, -7.72)
	add_child(win_top)
	# Bottom bar
	var win_bot = MeshInstance3D.new()
	win_bot.mesh = wt_m
	win_bot.material_override = win_mat
	win_bot.position = Vector3(0, 2.3, -7.72)
	add_child(win_bot)
	# Left post
	var win_l = MeshInstance3D.new()
	var wl_m = BoxMesh.new()
	wl_m.size = Vector3(0.12, 1.35, 0.15)
	win_l.mesh = wl_m
	win_l.material_override = win_mat
	win_l.position = Vector3(-1.06, 2.92, -7.72)
	add_child(win_l)
	# Right post
	var win_r = MeshInstance3D.new()
	win_r.mesh = wl_m
	win_r.material_override = win_mat
	win_r.position = Vector3(1.06, 2.92, -7.72)
	add_child(win_r)
	# Interior glow light
	var win_glow = OmniLight3D.new()
	win_glow.light_color = Color(0.3, 1.0, 0.85)
	win_glow.light_energy = 2.5
	win_glow.omni_range = 4.0
	win_glow.position = Vector3(0, 2.9, -7.5)
	add_child(win_glow)

	# Menu board on right wall
	var menu_board = MenuBoard.new()
	menu_board.position = Vector3(6.9, 3.0, -5.0)
	menu_board.rotation_degrees = Vector3(0, -90, 0)
	add_child(menu_board)

func _build_mission_ui():
	var mission = Missions.get_current_mission()
	if not mission: return
	
	var ui_board = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(8.0, 3.0, 0.1)
	ui_board.mesh = box
	ui_board.position = Vector3(-7.0, 3.5, -3.5) # Placed on left wall
	ui_board.rotation_degrees = Vector3(0, 90, 0)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.12)
	mat.roughness = 0.5
	ui_board.material_override = mat
	
	var title_lbl = Label3D.new()
	title_lbl.text = "MISSION: " + mission.title
	title_lbl.font_size = 56
	title_lbl.modulate = Color(0.3, 1.0, 0.5)
	title_lbl.position = Vector3(0, 1.0, 0.06)
	ui_board.add_child(title_lbl)
	
	var stmt_lbl = Label3D.new()
	stmt_lbl.text = mission.problem_statement
	stmt_lbl.font_size = 40
	stmt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stmt_lbl.width = 1200
	stmt_lbl.position = Vector3(0, 0.0, 0.06)
	ui_board.add_child(stmt_lbl)
	
	add_child(ui_board)


func _build_recipe_board():
	# Massive angled wooden board acting as the Blueprint Table
	var board_body = StaticBody3D.new()
	var board_col = CollisionShape3D.new()
	var board_box = BoxShape3D.new()
	board_box.size = Vector3(4.0, 2.5, 0.1)
	board_col.shape = board_box
	board_body.add_child(board_col)
	
	var board_mesh = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = board_box.size
	board_mesh.mesh = mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.28, 0.14) # Warm butcher wood
	mat.roughness = 0.9
	board_mesh.material_override = mat
	board_body.add_child(board_mesh)
	
	# Placed on the right side of the room flat against the right wall
	board_body.position = Vector3(6.9, 2.0, -0.5)
	board_body.rotation_degrees = Vector3(0, -90, 0)
	add_child(board_body)
	
	# Flowchart Node Spawners along the top edge
	var FlowchartNodeScript = load("res://scripts/flowchart_system/flowchart_node.gd")
	if FlowchartNodeScript != null:
		var spawners_data = [
			[FlowchartNodeScript.NodeType.START_END, "Start", "START"],
			[FlowchartNodeScript.NodeType.PROCESS, "Process", "PROCESS"],
			[FlowchartNodeScript.NodeType.DECISION, "Decision", "DECISION"],
			[FlowchartNodeScript.NodeType.INPUT_OUTPUT, "I/O", "I/O"],
			[FlowchartNodeScript.NodeType.START_END, "End", "END"],
		]
		
		for i in range(spawners_data.size()):
			var data = spawners_data[i]
			var spawner = FlowchartNodeSpawner.new()
			spawner.spawned_node_type = data[0]
			spawner.spawned_label = data[1]
			spawner.bin_label_text = data[2]
			
			spawner.scale = Vector3(0.5, 0.5, 0.5)
			spawner.position = Vector3(-1.5 + (i * 0.75), 1.0, 0.2)
			board_body.add_child(spawner)
		
	# Trace Lever to validate the flowchart logic ("Recipe validation")
	var trace_lever = TraceLever.new()
	trace_lever.scale = Vector3(0.5, 0.5, 0.5)
	trace_lever.position = Vector3(1.5, -0.8, 0.2)
	board_body.add_child(trace_lever)


func _build_cooking_station(mission):
	var counter_body = StaticBody3D.new()
	var counter_col = CollisionShape3D.new()
	var counter_box = BoxShape3D.new()
	counter_box.size = Vector3(3.5, 0.9, 2.0)
	counter_col.shape = counter_box
	counter_body.position = Vector3(0, 0.45, -3.0)
	counter_body.add_child(counter_col)
	add_child(counter_body)

	var counter_mesh = MeshInstance3D.new()
	var counter_mesh_box = BoxMesh.new()
	counter_mesh_box.size = counter_box.size
	counter_mesh.mesh = counter_mesh_box
	var counter_mat = StandardMaterial3D.new()
	counter_mat.albedo_color = Color(0.45, 0.28, 0.15)
	counter_mat.roughness = 0.6
	counter_mesh.material_override = counter_mat
	counter_body.add_child(counter_mesh)

	# Decorative Pot Visual
	var pot = MeshInstance3D.new()
	var pot_mesh = CylinderMesh.new()
	pot_mesh.top_radius = 0.6
	pot_mesh.bottom_radius = 0.5
	pot_mesh.height = 0.6
	pot.mesh = pot_mesh
	pot.position = Vector3(0, 1.2, -3.0)
	var pot_mat = StandardMaterial3D.new()
	pot_mat.albedo_color = Color(0.72, 0.45, 0.2)
	pot_mat.metallic = 0.8
	pot_mat.roughness = 0.3
	pot.material_override = pot_mat
	add_child(pot)

	var pot_glow = OmniLight3D.new()
	pot_glow.light_color = Color(1.0, 0.6, 0.2)
	pot_glow.light_energy = 2.0
	pot_glow.omni_range = 2.0
	pot_glow.position = Vector3(0, 1.5, -3.0)
	add_child(pot_glow)

	# Functional Pot
	var pot_catcher = CookingPot.new()
	if mission:
		pot_catcher.expected_types = mission.cartridge_types
	else:
		pot_catcher.expected_types = [] as Array[int]
		
	pot_catcher.position = Vector3(0, 1.8, -3.0)
	
	var pot_col = CollisionShape3D.new()
	var pot_shape = CylinderShape3D.new()
	pot_shape.radius = 0.7
	pot_shape.height = 0.6
	pot_col.shape = pot_shape
	pot_catcher.add_child(pot_col)
	
	var pot_physics = StaticBody3D.new()
	var floor_col = CollisionShape3D.new()
	var floor_box = BoxShape3D.new()
	floor_box.size = Vector3(1.2, 0.1, 1.2)
	floor_col.shape = floor_box
	floor_col.position = Vector3(0, -0.3, 0)
	pot_physics.add_child(floor_col)
	
	pot_catcher.add_child(pot_physics)
	add_child(pot_catcher)

	# Compile Lever
	var lever = CompileLever.new()
	lever.position = Vector3(1.3, 1.0, -3.0)
	add_child(lever)


func _build_ingredient_wall():
	var rows_data = [
		{
			"y": 1.0,
			"items": [
				["for", HardwareCartridge.CartridgeType.LOOP],
				["while", HardwareCartridge.CartridgeType.LOOP],
				["if", HardwareCartridge.CartridgeType.LOOP],
				["else", HardwareCartridge.CartridgeType.LOOP],
				["break", HardwareCartridge.CartridgeType.LOOP],
				["return", HardwareCartridge.CartridgeType.LOOP]
			]
		},
		{
			"y": 1.6,
			"items": [
				["x", HardwareCartridge.CartridgeType.VARIABLE],
				["y", HardwareCartridge.CartridgeType.VARIABLE],
				["i", HardwareCartridge.CartridgeType.VARIABLE],
				["j", HardwareCartridge.CartridgeType.VARIABLE],
				["count", HardwareCartridge.CartridgeType.VARIABLE],
				["temp", HardwareCartridge.CartridgeType.VARIABLE],
				["result", HardwareCartridge.CartridgeType.VARIABLE],
				["0", HardwareCartridge.CartridgeType.VALUE],
				["1", HardwareCartridge.CartridgeType.VALUE],
				["5", HardwareCartridge.CartridgeType.VALUE],
				["10", HardwareCartridge.CartridgeType.VALUE]
			]
		},
		{
			"y": 2.2,
			"items": [
				["=", HardwareCartridge.CartridgeType.OPERATOR],
				["+", HardwareCartridge.CartridgeType.OPERATOR],
				["-", HardwareCartridge.CartridgeType.OPERATOR],
				["*", HardwareCartridge.CartridgeType.OPERATOR],
				["/", HardwareCartridge.CartridgeType.OPERATOR],
				["%", HardwareCartridge.CartridgeType.OPERATOR],
				["==", HardwareCartridge.CartridgeType.OPERATOR],
				["!=", HardwareCartridge.CartridgeType.OPERATOR],
				[">", HardwareCartridge.CartridgeType.OPERATOR],
				["<", HardwareCartridge.CartridgeType.OPERATOR],
				[">=", HardwareCartridge.CartridgeType.OPERATOR],
				["<=", HardwareCartridge.CartridgeType.OPERATOR],
				["&&", HardwareCartridge.CartridgeType.OPERATOR],
				["||", HardwareCartridge.CartridgeType.OPERATOR],
				["!", HardwareCartridge.CartridgeType.OPERATOR],
				["++", HardwareCartridge.CartridgeType.OPERATOR]
			]
		},
		{
			"y": 2.8,
			"items": [
				["int", HardwareCartridge.CartridgeType.DATA_TYPE],
				["float", HardwareCartridge.CartridgeType.DATA_TYPE],
				["bool", HardwareCartridge.CartridgeType.DATA_TYPE],
				["string", HardwareCartridge.CartridgeType.DATA_TYPE],
				["char", HardwareCartridge.CartridgeType.DATA_TYPE],
				["void", HardwareCartridge.CartridgeType.DATA_TYPE]
			]
		},
		{
			"y": 3.4,
			"items": [
				["Start", HardwareCartridge.CartridgeType.FLOWCHART],
				["End", HardwareCartridge.CartridgeType.FLOWCHART],
				["Process", HardwareCartridge.CartridgeType.FLOWCHART],
				["Decision", HardwareCartridge.CartridgeType.FLOWCHART],
				["I/O", HardwareCartridge.CartridgeType.FLOWCHART]
			]
		}
	]
	
	for r in range(rows_data.size()):
		var row_y = rows_data[r]["y"]
		var items = rows_data[r]["items"]
		
		# Build a long physical wooden shelf for this row
		var shelf = StaticBody3D.new()
		var shelf_col = CollisionShape3D.new()
		var shelf_box = BoxShape3D.new()
		shelf_box.size = Vector3(14.0, 0.15, 0.5)
		shelf_col.shape = shelf_box
		shelf.add_child(shelf_col)
		
		var shelf_mesh = MeshInstance3D.new()
		var s_mesh = BoxMesh.new()
		s_mesh.size = shelf_box.size
		shelf_mesh.mesh = s_mesh
		var shelf_mat = StandardMaterial3D.new()
		shelf_mat.albedo_color = Color(0.38, 0.23, 0.12)
		shelf_mat.roughness = 0.75
		shelf_mesh.material_override = shelf_mat
		shelf.add_child(shelf_mesh)
		
		# Place it perfectly flush against the back wall, centered.
		shelf.position = Vector3(0.0, row_y, -7.5)
		add_child(shelf)

		# Under-shelf accent light (warm amber strip)
		var accent = OmniLight3D.new()
		accent.light_color = Color(1.0, 0.72, 0.35)
		accent.light_energy = 0.8
		accent.omni_range = 3.5
		var row_y_f: float = float(row_y)
		accent.position = Vector3(0.0, row_y_f - 0.18, -7.4)
		add_child(accent)
		
		# Center items on the shelf using a wider 0.82 margin for decongestion
		var start_x = - (items.size() * 0.82) / 2.0 + 0.41
		for i in range(items.size()):
			var item = items[i]
			var spawner = IngredientSpawner.new()
			spawner.spawned_token_name = item[0]
			spawner.spawned_type = item[1]
			spawner.rack_label_text = item[0]
			
			# Visually scale down crate a bit
			spawner.scale = Vector3(0.5, 0.5, 0.5)
			
			# Y=0.325 rests the crate perfectly on top of the shelf (shelf thickness 0.15/2 + crate scale 1.0/2 * 0.5)
			spawner.position = Vector3(start_x + (i * 0.82), 0.325, 0.0)
			
			# Create procedural box mesh so it's not invisible
			var box_vis = MeshInstance3D.new()
			box_vis.name = "CrateMesh" # CRITICAL: Enables hover feedback glow
			var bm = BoxMesh.new()
			bm.size = Vector3(1.0, 1.0, 1.0)
			box_vis.mesh = bm
			var bmat = StandardMaterial3D.new()
			var mat_color = Color(0.6, 0.4, 0.3)
			match item[1]:
				HardwareCartridge.CartridgeType.DATA_TYPE:
					mat_color = Color(0.2, 0.6, 1.0) # Blue
				HardwareCartridge.CartridgeType.VARIABLE:
					mat_color = Color(0.2, 0.9, 0.3) # Green
				HardwareCartridge.CartridgeType.OPERATOR:
					mat_color = Color(1.0, 0.6, 0.1) # Orange
				HardwareCartridge.CartridgeType.VALUE:
					mat_color = Color(0.8, 0.3, 0.8) # Purple
				HardwareCartridge.CartridgeType.LOOP:
					mat_color = Color(0.9, 0.1, 0.5) # Pink
				HardwareCartridge.CartridgeType.FLOWCHART:
					mat_color = Color(0.3, 0.3, 0.3) # Dark grey
			bmat.albedo_color = mat_color
			bmat.roughness = 0.9
			box_vis.material_override = bmat
			spawner.add_child(box_vis)
			
			shelf.add_child(spawner)
