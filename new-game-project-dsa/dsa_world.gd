## ============================================================
## DSA ACADEMY — THE QUANTUM CLASSROOM
## ============================================================
## Master 3D World Environment & Central Algorithm Hub
##
## Implements:
## 1. Realistic Classroom Lab Environment (walls, floor, ceiling)
## 2. Windows with outdoor sky view & natural lighting
## 3. Desk rows, bookshelves, whiteboard, monitors
## 4. 3 Topic Pedestals with improved collision detection
## 5. Central Algorithm Core (floating holographic heart)
## 6. Ambient particles & atmospheric effects
## 7. Seamless Player, Raycast Interaction, UI & Lesson Integration
## ============================================================

extends Node3D

# ============================================================
# CONSTANTS & PALETTE
# ============================================================

const ROOM_WIDTH: float = 20.0    # X extent
const ROOM_DEPTH: float = 18.0    # Z extent
const ROOM_HEIGHT: float = 5.0    # Y extent
const WALL_THICKNESS: float = 0.25

# Nature / realistic palette
const C_WALL_BASE     := Color(0.22, 0.24, 0.28)    # Dark grey concrete
const C_WALL_ACCENT   := Color(0.15, 0.18, 0.22)    # Darker accent wall
const C_FLOOR_TILE    := Color(0.12, 0.14, 0.17)    # Polished dark tile
const C_FLOOR_GROUT   := Color(0.07, 0.08, 0.10)    # Tile grout lines
const C_CEILING       := Color(0.28, 0.30, 0.32)    # Light ceiling
const C_WOOD          := Color(0.35, 0.22, 0.12)    # Warm wood
const C_WOOD_DARK     := Color(0.20, 0.12, 0.06)    # Dark wood
const C_METAL         := Color(0.45, 0.48, 0.52)    # Brushed metal
const C_GLASS         := Color(0.65, 0.78, 0.90)    # Glass tint
const C_WHITEBOARD    := Color(0.92, 0.94, 0.96)    # Whiteboard surface
const C_MONITOR_FRAME := Color(0.08, 0.08, 0.10)    # Monitor bezel
const C_MONITOR_SCREEN:= Color(0.02, 0.06, 0.12)    # Monitor screen dark
const C_BOOKSHELF     := Color(0.30, 0.18, 0.08)    # Bookshelf wood

# Accent colors for tech elements
const C_CYAN        := Color(0.0, 0.85, 1.0)
const C_PURPLE      := Color(0.7, 0.25, 1.0)
const C_AMBER       := Color(1.0, 0.65, 0.0)
const C_WHITE       := Color(0.95, 0.98, 1.0)
const C_NEON_STRIP  := Color(0.0, 0.65, 0.95)

# ============================================================
# SYSTEM REFERENCES
# ============================================================

var array_system: Node3D
var game_ui: CanvasLayer
var player: CharacterBody3D
var lesson_manager: Node

# Hub & Core elements
var hub_container: Node3D
var topic_pedestals: Array = []
var topic_glyphs: Array[Node3D] = []
var algorithm_core: Node3D
var core_inner: MeshInstance3D
var core_outer_ring1: MeshInstance3D
var core_outer_ring2: MeshInstance3D
var hub_active: bool = true
var time_elapsed: float = 0.0


# ============================================================
# READY
# ============================================================

func _ready():
	add_to_group("dsa_world")

	create_environment()
	create_classroom_structure()
	create_classroom_furniture()
	create_algorithm_core()
	# Atmospheric dust particles removed for a completely clean, pristine lab environment
	create_lighting()
	create_hub_pedestals()
	create_dsa_systems()
	create_game_ui()
	create_player()
	setup_system_connections()
	create_lesson_manager()
	if game_ui and game_ui.has_method("show_hub"):
		game_ui.show_hub()


# ============================================================
# ENVIRONMENT & ATMOSPHERE
# ============================================================

func create_environment():
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	# Procedural sky — daytime outdoor sky visible through windows
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.47, 0.82)      # Blue sky
	sky_mat.sky_horizon_color = Color(0.60, 0.72, 0.88)   # Light horizon
	sky_mat.sky_curve = 0.15
	sky_mat.ground_bottom_color = Color(0.18, 0.22, 0.15) # Ground far away
	sky_mat.ground_horizon_color = Color(0.45, 0.55, 0.35) # Green horizon (trees)
	sky_mat.sun_angle_max = 35.0
	sky.sky_material = sky_mat
	env.sky = sky

	# Tonemapping & Exposure — crisp, well-lit classroom
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.25

	# Subtle glow for neon tech accents
	env.glow_enabled = true
	env.glow_intensity = 0.65
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT

	# Fog disabled to eliminate murky dark haze
	env.fog_enabled = false

	# Ambient light (indoor) — clean, bright, modern lab environment
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.50, 0.54, 0.60)
	env.ambient_light_energy = 0.75

	# SSAO for depth
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 0.4

	world_env.environment = env
	add_child(world_env)


# ============================================================
# CLASSROOM STRUCTURE (Walls, Floor, Ceiling)
# ============================================================

func create_classroom_structure():
	var structure := Node3D.new()
	structure.name = "ClassroomStructure"
	add_child(structure)

	# ── FLOOR (Polished tile) ──
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"

	var floor_mesh := MeshInstance3D.new()
	var f_box := BoxMesh.new()
	f_box.size = Vector3(ROOM_WIDTH, 0.3, ROOM_DEPTH)
	floor_mesh.mesh = f_box

	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = C_FLOOR_TILE
	floor_mat.metallic = 0.6
	floor_mat.roughness = 0.12  # Very polished / reflective
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, -0.15, 0)
	floor_body.add_child(floor_mesh)

	var floor_coll := CollisionShape3D.new()
	var f_shape := BoxShape3D.new()
	f_shape.size = Vector3(ROOM_WIDTH, 0.3, ROOM_DEPTH)
	floor_coll.shape = f_shape
	floor_coll.position = Vector3(0, -0.15, 0)
	floor_body.add_child(floor_coll)

	structure.add_child(floor_body)

	# ── Floor tile grid lines ──
	_create_floor_grid(structure)

	# ── CEILING ──
	var ceiling := MeshInstance3D.new()
	var c_box := BoxMesh.new()
	c_box.size = Vector3(ROOM_WIDTH, 0.2, ROOM_DEPTH)
	ceiling.mesh = c_box
	var ceiling_mat := StandardMaterial3D.new()
	ceiling_mat.albedo_color = C_CEILING
	ceiling_mat.metallic = 0.0
	ceiling_mat.roughness = 1.0
	ceiling_mat.metallic_specular = 0.0
	ceiling.material_override = ceiling_mat
	ceiling.position = Vector3(0, ROOM_HEIGHT + 0.1, 0)
	structure.add_child(ceiling)

	# ── Ceiling panels / tiles ──
	_create_ceiling_panels(structure)

	# ── WALLS ──
	# Back wall (behind pedestals) — accent wall
	_create_wall(structure, Vector3(0, ROOM_HEIGHT / 2.0, -ROOM_DEPTH / 2.0),
		Vector3(ROOM_WIDTH, ROOM_HEIGHT, WALL_THICKNESS), C_WALL_ACCENT, 0.7, 0.3)

	# Front wall (behind player start)
	_create_wall(structure, Vector3(0, ROOM_HEIGHT / 2.0, ROOM_DEPTH / 2.0),
		Vector3(ROOM_WIDTH, ROOM_HEIGHT, WALL_THICKNESS), C_WALL_BASE, 0.5, 0.4)

	# Left wall (with windows)
	_create_wall_with_windows(structure, -1)

	# Right wall (with windows)
	_create_wall_with_windows(structure, 1)

	# ── Baseboard trim ──
	_create_baseboard(structure)

	# ── LED strip along back wall floor trim (tech accent) ──
	_create_led_strip(structure, Vector3(0, 0.08, -ROOM_DEPTH / 2.0 + 0.14), ROOM_WIDTH - 0.5, C_NEON_STRIP)


func _create_floor_grid(parent: Node3D):
	# Grout lines forming a tile pattern
	var tile_size := 2.0
	var grout_mat := StandardMaterial3D.new()
	grout_mat.albedo_color = C_FLOOR_GROUT
	grout_mat.metallic = 0.3
	grout_mat.roughness = 0.5

	# Horizontal lines
	var z_start := -ROOM_DEPTH / 2.0
	var z_end := ROOM_DEPTH / 2.0
	var x_start := -ROOM_WIDTH / 2.0
	var x_end := ROOM_WIDTH / 2.0
	var z := z_start
	while z <= z_end:
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(ROOM_WIDTH, 0.005, 0.03)
		line.mesh = line_mesh
		line.material_override = grout_mat
		line.position = Vector3(0, 0.003, z)
		parent.add_child(line)
		z += tile_size

	var x := x_start
	while x <= x_end:
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(0.03, 0.005, ROOM_DEPTH)
		line.mesh = line_mesh
		line.material_override = grout_mat
		line.position = Vector3(x, 0.003, 0)
		parent.add_child(line)
		x += tile_size


func _create_ceiling_panels(parent: Node3D):
	# Recessed ceiling panels with matte acoustic tile finish
	var panel_mat := StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.24, 0.26, 0.28)
	panel_mat.metallic = 0.0
	panel_mat.roughness = 1.0
	panel_mat.metallic_specular = 0.0

	var border_mat := StandardMaterial3D.new()
	border_mat.albedo_color = Color(0.18, 0.20, 0.22)
	border_mat.metallic = 0.0
	border_mat.roughness = 1.0
	border_mat.metallic_specular = 0.0

	var cols := 4
	var rows := 4
	var panel_w := (ROOM_WIDTH - 1.0) / cols
	var panel_d := (ROOM_DEPTH - 1.0) / rows

	for r in range(rows):
		for c in range(cols):
			var px := -ROOM_WIDTH / 2.0 + 0.5 + c * panel_w + panel_w / 2.0
			var pz := -ROOM_DEPTH / 2.0 + 0.5 + r * panel_d + panel_d / 2.0

			var panel := MeshInstance3D.new()
			var p_box := BoxMesh.new()
			p_box.size = Vector3(panel_w - 0.15, 0.04, panel_d - 0.15)
			panel.mesh = p_box
			panel.material_override = panel_mat
			panel.position = Vector3(px, ROOM_HEIGHT - 0.02, pz)
			parent.add_child(panel)


func _create_wall(parent: Node3D, pos: Vector3, size: Vector3, color: Color, metallic: float, roughness: float):
	## Visual mesh + collision so trainees cannot walk through walls (desktop play).
	var body := StaticBody3D.new()
	body.position = pos
	parent.add_child(body)

	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	wall.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	wall.material_override = mat
	body.add_child(wall)

	var coll := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	coll.shape = shape
	body.add_child(coll)


func _create_wall_with_windows(parent: Node3D, side: int):
	# side: -1 = left, 1 = right
	var x_pos := side * ROOM_WIDTH / 2.0

	# Wall segments (pillars between windows)
	var num_windows := 3
	var window_height := 2.5
	var window_width := 3.0
	var pillar_width := (ROOM_DEPTH - num_windows * window_width) / (num_windows + 1)
	var window_bottom := 1.2

	# Full wall below windows
	_create_wall(parent,
		Vector3(x_pos, window_bottom / 2.0, 0),
		Vector3(WALL_THICKNESS, window_bottom, ROOM_DEPTH),
		C_WALL_BASE, 0.5, 0.4)

	# Full wall above windows
	var above_y := window_bottom + window_height
	var above_h := ROOM_HEIGHT - above_y
	_create_wall(parent,
		Vector3(x_pos, above_y + above_h / 2.0, 0),
		Vector3(WALL_THICKNESS, above_h, ROOM_DEPTH),
		C_WALL_BASE, 0.5, 0.4)

	# Pillars between windows
	for i in range(num_windows + 1):
		var z_center := -ROOM_DEPTH / 2.0 + pillar_width / 2.0 + i * (window_width + pillar_width)
		var pillar := MeshInstance3D.new()
		var p_box := BoxMesh.new()
		p_box.size = Vector3(WALL_THICKNESS + 0.05, window_height, pillar_width)
		pillar.mesh = p_box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = C_WALL_BASE
		mat.metallic = 0.5
		mat.roughness = 0.4
		pillar.material_override = mat
		pillar.position = Vector3(x_pos, window_bottom + window_height / 2.0, z_center)
		parent.add_child(pillar)

	# Glass panes for each window
	for i in range(num_windows):
		var z_center := -ROOM_DEPTH / 2.0 + pillar_width + window_width / 2.0 + i * (window_width + pillar_width)
		var glass := MeshInstance3D.new()
		var g_box := BoxMesh.new()
		g_box.size = Vector3(0.04, window_height - 0.1, window_width - 0.15)
		glass.mesh = g_box
		var g_mat := StandardMaterial3D.new()
		g_mat.albedo_color = Color(0.70, 0.82, 0.95, 0.25)
		g_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		g_mat.metallic = 0.8
		g_mat.roughness = 0.0
		glass.material_override = g_mat
		glass.position = Vector3(x_pos, window_bottom + window_height / 2.0, z_center)
		parent.add_child(glass)

		# Window frame
		_create_window_frame(parent, Vector3(x_pos, window_bottom + window_height / 2.0, z_center),
			window_width - 0.15, window_height - 0.1, side)

	# Window sill
	for i in range(num_windows):
		var z_center := -ROOM_DEPTH / 2.0 + pillar_width + window_width / 2.0 + i * (window_width + pillar_width)
		var sill := MeshInstance3D.new()
		var s_box := BoxMesh.new()
		s_box.size = Vector3(0.25, 0.05, window_width - 0.05)
		sill.mesh = s_box
		var s_mat := StandardMaterial3D.new()
		s_mat.albedo_color = Color(0.8, 0.82, 0.85)
		s_mat.metallic = 0.2
		s_mat.roughness = 0.3
		sill.material_override = s_mat
		sill.position = Vector3(x_pos - side * 0.05, window_bottom - 0.02, z_center)
		parent.add_child(sill)


func _create_window_frame(parent: Node3D, pos: Vector3, width: float, height: float, side: int):
	var frame_mat := StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.35, 0.38, 0.42)
	frame_mat.metallic = 0.7
	frame_mat.roughness = 0.2

	var frame_depth := 0.06
	var frame_thickness := 0.06

	# Horizontal bars (top / bottom / middle)
	for y_off: float in [-height / 2.0, 0.0, height / 2.0]:
		var bar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(frame_depth, frame_thickness, width)
		bar.mesh = box
		bar.material_override = frame_mat
		bar.position = pos + Vector3(0, y_off, 0)
		parent.add_child(bar)

	# Vertical bar (center mullion)
	var vbar := MeshInstance3D.new()
	var vbox := BoxMesh.new()
	vbox.size = Vector3(frame_depth, height, frame_thickness)
	vbar.mesh = vbox
	vbar.material_override = frame_mat
	vbar.position = pos
	parent.add_child(vbar)


func _create_baseboard(parent: Node3D):
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.11, 0.13)
	base_mat.metallic = 0.3
	base_mat.roughness = 0.4

	var base_h := 0.12
	var base_y := base_h / 2.0

	# Back wall baseboard
	var bb := MeshInstance3D.new()
	var bb_box := BoxMesh.new()
	bb_box.size = Vector3(ROOM_WIDTH, base_h, 0.06)
	bb.mesh = bb_box
	bb.material_override = base_mat
	bb.position = Vector3(0, base_y, -ROOM_DEPTH / 2.0 + 0.15)
	parent.add_child(bb)

	# Front wall baseboard
	var fb := MeshInstance3D.new()
	fb.mesh = bb_box
	fb.material_override = base_mat
	fb.position = Vector3(0, base_y, ROOM_DEPTH / 2.0 - 0.15)
	parent.add_child(fb)


func _create_led_strip(parent: Node3D, pos: Vector3, width: float, color: Color):
	var strip := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(width, 0.025, 0.025)
	strip.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.5
	strip.material_override = mat
	strip.position = pos
	parent.add_child(strip)


# ============================================================
# CLASSROOM FURNITURE
# ============================================================

func create_classroom_furniture():
	var furniture := Node3D.new()
	furniture.name = "ClassroomFurniture"
	add_child(furniture)

	# ── WHITEBOARD on back wall ──
	_create_whiteboard(furniture)

	# ── BOOKSHELVES along front wall ──
	_create_bookshelves(furniture)

	# ── DESK rows on left & right sides ──
	_create_desk_rows(furniture)

	# ── ERGONOMIC LAB CHAIRS ──
	_create_desk_chairs(furniture)

	# ── CEILING LIGHTS (fluorescent panels) ──
	_create_ceiling_lights(furniture)

	# ── MONITORS on desks ──
	_create_desk_monitors(furniture)

	# ── POTTED PLANTS ──
	_create_potted_plants(furniture)


func _create_whiteboard(parent: Node3D):
	var wb_z := -ROOM_DEPTH / 2.0 + 0.20

	# Board surface — bright, crisp whiteboard with clean luminescence
	var board := MeshInstance3D.new()
	var b_box := BoxMesh.new()
	b_box.size = Vector3(6.0, 2.5, 0.06)
	board.mesh = b_box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.96, 0.98, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.96, 0.98, 1.0)
	mat.emission_energy_multiplier = 0.22
	mat.metallic = 0.0
	mat.roughness = 0.3
	board.material_override = mat
	board.position = Vector3(0, 2.5, wb_z)
	parent.add_child(board)

	# Frame
	var frame_mat := StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.40, 0.42, 0.45)
	frame_mat.metallic = 0.7
	frame_mat.roughness = 0.2

	# Top frame
	var top_f := MeshInstance3D.new()
	var tf_box := BoxMesh.new()
	tf_box.size = Vector3(6.12, 0.06, 0.08)
	top_f.mesh = tf_box
	top_f.material_override = frame_mat
	top_f.position = Vector3(0, 3.78, wb_z)
	parent.add_child(top_f)

	# Bottom frame
	var bot_f := MeshInstance3D.new()
	bot_f.mesh = tf_box
	bot_f.material_override = frame_mat
	bot_f.position = Vector3(0, 1.22, wb_z)
	parent.add_child(bot_f)

	# Side frames
	for x: float in [-3.06, 3.06]:
		var sf := MeshInstance3D.new()
		var sf_box := BoxMesh.new()
		sf_box.size = Vector3(0.06, 2.62, 0.08)
		sf.mesh = sf_box
		sf.material_override = frame_mat
		sf.position = Vector3(x, 2.5, wb_z)
		parent.add_child(sf)

	# Marker tray
	var tray := MeshInstance3D.new()
	var tray_box := BoxMesh.new()
	tray_box.size = Vector3(3.0, 0.04, 0.12)
	tray.mesh = tray_box
	tray.material_override = frame_mat
	tray.position = Vector3(0, 1.20, wb_z + 0.08)
	parent.add_child(tray)

	# "DSA Academy" text on whiteboard — crisp dark text on bright board
	var wb_title := Label3D.new()
	wb_title.text = "DSA ACADEMY"
	wb_title.font_size = 64
	wb_title.modulate = Color(0.08, 0.12, 0.22)
	wb_title.outline_size = 4
	wb_title.outline_modulate = Color(0.95, 0.97, 1.0)
	wb_title.position = Vector3(0, 3.2, wb_z + 0.04)
	wb_title.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	wb_title.pixel_size = 0.003
	parent.add_child(wb_title)

	var wb_sub := Label3D.new()
	wb_sub.text = "Data Structures & Algorithms"
	wb_sub.font_size = 32
	wb_sub.modulate = Color(0.18, 0.24, 0.36)
	wb_sub.outline_size = 2
	wb_sub.outline_modulate = Color(0.95, 0.97, 1.0)
	wb_sub.position = Vector3(0, 2.75, wb_z + 0.04)
	wb_sub.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	wb_sub.pixel_size = 0.0025
	parent.add_child(wb_sub)


func _create_bookshelves(parent: Node3D):
	var shelf_z := ROOM_DEPTH / 2.0 - 0.5

	for shelf_x: float in [-7.0, 7.0]:
		# Shelf frame
		var frame := MeshInstance3D.new()
		var f_box := BoxMesh.new()
		f_box.size = Vector3(2.8, 3.2, 0.5)
		frame.mesh = f_box
		var f_mat := StandardMaterial3D.new()
		f_mat.albedo_color = C_BOOKSHELF
		f_mat.metallic = 0.15
		f_mat.roughness = 0.65
		frame.material_override = f_mat
		frame.position = Vector3(shelf_x, 1.6, shelf_z)
		parent.add_child(frame)

		# Shelves (horizontal planks)
		for sy: float in [0.5, 1.3, 2.1, 2.9]:
			var shelf := MeshInstance3D.new()
			var s_box := BoxMesh.new()
			s_box.size = Vector3(2.7, 0.04, 0.45)
			shelf.mesh = s_box
			var s_mat := StandardMaterial3D.new()
			s_mat.albedo_color = C_WOOD
			s_mat.metallic = 0.1
			s_mat.roughness = 0.5
			shelf.material_override = s_mat
			shelf.position = Vector3(shelf_x, sy, shelf_z)
			parent.add_child(shelf)

		# Books on shelves (colorful blocks)
		var book_colors := [
			Color(0.8, 0.2, 0.2), Color(0.2, 0.5, 0.8), Color(0.2, 0.7, 0.3),
			Color(0.8, 0.6, 0.1), Color(0.6, 0.2, 0.7), Color(0.3, 0.3, 0.8)
		]
		for row_i in range(3):
			var row_y := 0.55 + row_i * 0.8
			var bx: float = shelf_x - 1.1
			for bi in range(5):
				var book := MeshInstance3D.new()
				var bk := BoxMesh.new()
				var bw := randf_range(0.12, 0.22)
				var bh := randf_range(0.35, 0.6)
				bk.size = Vector3(bw, bh, 0.3)
				book.mesh = bk
				var b_mat := StandardMaterial3D.new()
				b_mat.albedo_color = book_colors[(bi + row_i) % book_colors.size()]
				b_mat.roughness = 0.7
				book.material_override = b_mat
				book.position = Vector3(bx, row_y + bh / 2.0, shelf_z)
				parent.add_child(book)
				bx += bw + 0.05


func _create_desk_rows(parent: Node3D):
	var desk_mat := StandardMaterial3D.new()
	desk_mat.albedo_color = C_WOOD
	desk_mat.metallic = 0.15
	desk_mat.roughness = 0.45

	var leg_mat := StandardMaterial3D.new()
	leg_mat.albedo_color = C_METAL
	leg_mat.metallic = 0.8
	leg_mat.roughness = 0.25

	# Desks along left and right sides
	for side: float in [-1.0, 1.0]:
		for row in range(3):
			var dx: float = side * 7.5
			var dz := -5.0 + row * 3.5
			_create_single_desk(parent, Vector3(dx, 0, dz), desk_mat, leg_mat)


func _create_single_desk(parent: Node3D, pos: Vector3, desk_mat: StandardMaterial3D, leg_mat: StandardMaterial3D):
	var desk_w := 1.8
	var desk_d := 0.8
	var desk_h := 0.75
	var leg_th := 0.05

	# Table top
	var top := MeshInstance3D.new()
	var t_box := BoxMesh.new()
	t_box.size = Vector3(desk_w, 0.04, desk_d)
	top.mesh = t_box
	top.material_override = desk_mat
	top.position = pos + Vector3(0, desk_h, 0)
	parent.add_child(top)

	# 4 legs
	for lx: float in [-desk_w / 2.0 + 0.08, desk_w / 2.0 - 0.08]:
		for lz: float in [-desk_d / 2.0 + 0.08, desk_d / 2.0 - 0.08]:
			var leg := MeshInstance3D.new()
			var l_box := BoxMesh.new()
			l_box.size = Vector3(leg_th, desk_h, leg_th)
			leg.mesh = l_box
			leg.material_override = leg_mat
			leg.position = pos + Vector3(lx, desk_h / 2.0, lz)
			parent.add_child(leg)

	# Invisible blocker so player cannot walk through the desk
	var blocker := StaticBody3D.new()
	blocker.position = pos + Vector3(0, desk_h * 0.5, 0)
	var bcoll := CollisionShape3D.new()
	var bshape := BoxShape3D.new()
	bshape.size = Vector3(desk_w, desk_h, desk_d)
	bcoll.shape = bshape
	blocker.add_child(bcoll)
	parent.add_child(blocker)


func _create_desk_chairs(parent: Node3D):
	# Ergonomic mesh computer lab chairs for each student workstation
	var plastic_mat := StandardMaterial3D.new()
	plastic_mat.albedo_color = Color(0.12, 0.14, 0.17)
	plastic_mat.roughness = 0.6

	var cushion_mat := StandardMaterial3D.new()
	cushion_mat.albedo_color = Color(0.18, 0.22, 0.26)
	cushion_mat.roughness = 0.85

	var chrome_mat := StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.85, 0.88, 0.92)
	chrome_mat.metallic = 0.85
	chrome_mat.roughness = 0.2

	for side: float in [-1.0, 1.0]:
		for row in range(3):
			var cx: float = side * 7.5
			var cz: float = -5.0 + float(row) * 3.5 + 0.65
			var chair_root := Node3D.new()
			chair_root.position = Vector3(cx, 0, cz)
			parent.add_child(chair_root)

			# 5-Star Caster Base
			for star_i in range(5):
				var angle := float(star_i) * (TAU / 5.0)
				var spoke := MeshInstance3D.new()
				var sp_box := BoxMesh.new()
				sp_box.size = Vector3(0.04, 0.03, 0.32)
				spoke.mesh = sp_box
				spoke.material_override = plastic_mat
				spoke.position = Vector3(sin(angle) * 0.15, 0.05, cos(angle) * 0.15)
				spoke.rotation_degrees = Vector3(0, rad_to_deg(angle), 0)
				chair_root.add_child(spoke)

				# Wheel caster
				var wheel := MeshInstance3D.new()
				var wh_cyl := CylinderMesh.new()
				wh_cyl.top_radius = 0.025
				wh_cyl.bottom_radius = 0.025
				wh_cyl.height = 0.02
				wheel.mesh = wh_cyl
				wheel.rotation_degrees = Vector3(0, 0, 90)
				wheel.material_override = plastic_mat
				wheel.position = Vector3(sin(angle) * 0.28, 0.025, cos(angle) * 0.28)
				chair_root.add_child(wheel)

			# Center Pneumatic Piston Cylinder
			var piston := MeshInstance3D.new()
			var p_cyl := CylinderMesh.new()
			p_cyl.top_radius = 0.022
			p_cyl.bottom_radius = 0.025
			p_cyl.height = 0.38
			piston.mesh = p_cyl
			piston.material_override = chrome_mat
			piston.position = Vector3(0, 0.24, 0)
			chair_root.add_child(piston)

			# Seat Cushion
			var seat := MeshInstance3D.new()
			var st_box := BoxMesh.new()
			st_box.size = Vector3(0.48, 0.06, 0.46)
			seat.mesh = st_box
			seat.material_override = cushion_mat
			seat.position = Vector3(0, 0.44, 0)
			chair_root.add_child(seat)

			# Ergonomic Curved Mesh Backrest
			var back := MeshInstance3D.new()
			var bk_box := BoxMesh.new()
			bk_box.size = Vector3(0.44, 0.46, 0.04)
			back.mesh = bk_box
			back.material_override = cushion_mat
			back.position = Vector3(0, 0.72, 0.20)
			chair_root.add_child(back)

			# Chair Spine / Bracket
			var spine := MeshInstance3D.new()
			var sp_box2 := BoxMesh.new()
			sp_box2.size = Vector3(0.06, 0.35, 0.04)
			spine.mesh = sp_box2
			spine.material_override = plastic_mat
			spine.position = Vector3(0, 0.58, 0.22)
			chair_root.add_child(spine)

			# Armrests (Left & Right)
			for arm_side in [-0.26, 0.26]:
				var arm_support := MeshInstance3D.new()
				var as_box := BoxMesh.new()
				as_box.size = Vector3(0.03, 0.18, 0.04)
				arm_support.mesh = as_box
				arm_support.material_override = plastic_mat
				arm_support.position = Vector3(arm_side, 0.54, 0.02)
				chair_root.add_child(arm_support)

				var arm_pad := MeshInstance3D.new()
				var ap_box := BoxMesh.new()
				ap_box.size = Vector3(0.06, 0.025, 0.22)
				arm_pad.mesh = ap_box
				arm_pad.material_override = plastic_mat
				arm_pad.position = Vector3(arm_side, 0.64, 0.02)
				chair_root.add_child(arm_pad)



func _create_ceiling_lights(parent: Node3D):
	# Fluorescent light panels
	var light_mat := StandardMaterial3D.new()
	light_mat.albedo_color = Color(0.95, 0.98, 1.0)
	light_mat.emission_enabled = true
	light_mat.emission = Color(0.95, 0.98, 1.0)
	light_mat.emission_energy_multiplier = 1.2

	var frame_mat := StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.35, 0.38, 0.40)
	frame_mat.metallic = 0.0
	frame_mat.roughness = 1.0
	frame_mat.metallic_specular = 0.0

	for row in range(2):
		for col in range(3):
			var lx := -5.0 + col * 5.0
			var lz := -4.0 + row * 8.0

			# Light panel
			var panel := MeshInstance3D.new()
			var p_box := BoxMesh.new()
			p_box.size = Vector3(1.2, 0.03, 0.6)
			panel.mesh = p_box
			panel.material_override = light_mat
			panel.position = Vector3(lx, ROOM_HEIGHT - 0.05, lz)
			parent.add_child(panel)

			# Frame around panel
			var frame := MeshInstance3D.new()
			var f_box := BoxMesh.new()
			f_box.size = Vector3(1.3, 0.06, 0.7)
			frame.mesh = f_box
			frame.material_override = frame_mat
			frame.position = Vector3(lx, ROOM_HEIGHT - 0.06, lz)
			parent.add_child(frame)


func _create_desk_monitors(parent: Node3D):
	# Small monitors on the desks
	for side: float in [-1.0, 1.0]:
		for row in range(3):
			var dx: float = side * 7.5
			var dz := -5.0 + row * 3.5
			var mon_y := 0.75 + 0.25

			# Screen
			var screen := MeshInstance3D.new()
			var s_box := BoxMesh.new()
			s_box.size = Vector3(0.6, 0.4, 0.025)
			screen.mesh = s_box
			var s_mat := StandardMaterial3D.new()
			s_mat.albedo_color = Color(0.05, 0.15, 0.25)
			s_mat.emission_enabled = true
			s_mat.emission = Color(0.05, 0.15, 0.25)
			s_mat.emission_energy_multiplier = 0.5
			screen.material_override = s_mat
			screen.position = Vector3(dx, mon_y, dz - 0.2)
			parent.add_child(screen)

			# Bezel
			var bezel := MeshInstance3D.new()
			var bz_box := BoxMesh.new()
			bz_box.size = Vector3(0.65, 0.45, 0.02)
			bezel.mesh = bz_box
			var bz_mat := StandardMaterial3D.new()
			bz_mat.albedo_color = C_MONITOR_FRAME
			bz_mat.metallic = 0.6
			bz_mat.roughness = 0.3
			bezel.material_override = bz_mat
			bezel.position = Vector3(dx, mon_y, dz - 0.21)
			parent.add_child(bezel)

			# Stand
			var stand := MeshInstance3D.new()
			var st_box := BoxMesh.new()
			st_box.size = Vector3(0.04, 0.20, 0.04)
			stand.mesh = st_box
			stand.material_override = bz_mat
			stand.position = Vector3(dx, 0.75 + 0.05, dz - 0.2)
			parent.add_child(stand)

			# Stand base
			var base := MeshInstance3D.new()
			var ba_box := BoxMesh.new()
			ba_box.size = Vector3(0.2, 0.02, 0.15)
			base.mesh = ba_box
			base.material_override = bz_mat
			base.position = Vector3(dx, 0.76, dz - 0.2)
			parent.add_child(base)


func _create_potted_plants(parent: Node3D):
	# Decorative plants in corners
	var plant_positions := [
		Vector3(-ROOM_WIDTH / 2.0 + 1.0, 0, ROOM_DEPTH / 2.0 - 1.0),
		Vector3(ROOM_WIDTH / 2.0 - 1.0, 0, ROOM_DEPTH / 2.0 - 1.0),
		Vector3(-ROOM_WIDTH / 2.0 + 1.0, 0, -ROOM_DEPTH / 2.0 + 1.0),
		Vector3(ROOM_WIDTH / 2.0 - 1.0, 0, -ROOM_DEPTH / 2.0 + 1.0)
	]

	for pos in plant_positions:
		# Pot
		var pot := MeshInstance3D.new()
		var p_cyl := CylinderMesh.new()
		p_cyl.top_radius = 0.22
		p_cyl.bottom_radius = 0.16
		p_cyl.height = 0.35
		pot.mesh = p_cyl
		var p_mat := StandardMaterial3D.new()
		p_mat.albedo_color = Color(0.55, 0.35, 0.20)
		p_mat.roughness = 0.75
		pot.material_override = p_mat
		pot.position = pos + Vector3(0, 0.175, 0)
		parent.add_child(pot)

		# Dirt
		var dirt := MeshInstance3D.new()
		var d_cyl := CylinderMesh.new()
		d_cyl.top_radius = 0.20
		d_cyl.bottom_radius = 0.20
		d_cyl.height = 0.04
		dirt.mesh = d_cyl
		var d_mat := StandardMaterial3D.new()
		d_mat.albedo_color = Color(0.22, 0.15, 0.08)
		d_mat.roughness = 0.95
		dirt.material_override = d_mat
		dirt.position = pos + Vector3(0, 0.36, 0)
		parent.add_child(dirt)

		# Plant (simple sphere foliage)
		var foliage := MeshInstance3D.new()
		var f_sphere := SphereMesh.new()
		f_sphere.radius = 0.35
		f_sphere.height = 0.65
		foliage.mesh = f_sphere
		var f_mat := StandardMaterial3D.new()
		f_mat.albedo_color = Color(0.15, 0.45, 0.15)
		f_mat.roughness = 0.85
		foliage.material_override = f_mat
		foliage.position = pos + Vector3(0, 0.75, 0)
		parent.add_child(foliage)

		# Stem
		var stem := MeshInstance3D.new()
		var st_cyl := CylinderMesh.new()
		st_cyl.top_radius = 0.02
		st_cyl.bottom_radius = 0.03
		st_cyl.height = 0.35
		stem.mesh = st_cyl
		var st_mat := StandardMaterial3D.new()
		st_mat.albedo_color = Color(0.25, 0.35, 0.12)
		st_mat.roughness = 0.8
		stem.material_override = st_mat
		stem.position = pos + Vector3(0, 0.52, 0)
		parent.add_child(stem)


# ============================================================
# ALGORITHM CORE (Floating Central Energy Heart)
# ============================================================

func create_algorithm_core():
	algorithm_core = Node3D.new()
	algorithm_core.name = "AlgorithmCore"
	algorithm_core.position = Vector3(0, 3.8, -5.5)
	add_child(algorithm_core)

	# Inner pulsing core (Prism / Diamond)
	core_inner = MeshInstance3D.new()
	core_inner.name = "CoreHeart"
	var prism := PrismMesh.new()
	prism.size = Vector3(0.6, 0.8, 0.6)
	core_inner.mesh = prism

	var inner_mat := StandardMaterial3D.new()
	inner_mat.albedo_color = C_CYAN
	inner_mat.emission_enabled = true
	inner_mat.emission = C_CYAN
	inner_mat.emission_energy_multiplier = 2.5
	inner_mat.metallic = 0.6
	inner_mat.roughness = 0.1
	core_inner.material_override = inner_mat
	algorithm_core.add_child(core_inner)

	# Outer Orbital Ring 1
	core_outer_ring1 = MeshInstance3D.new()
	var r1 := TorusMesh.new()
	r1.inner_radius = 0.80
	r1.outer_radius = 0.86
	core_outer_ring1.mesh = r1
	var r1_mat := StandardMaterial3D.new()
	r1_mat.albedo_color = C_PURPLE
	r1_mat.emission_enabled = true
	r1_mat.emission = C_PURPLE
	r1_mat.emission_energy_multiplier = 2.2
	core_outer_ring1.material_override = r1_mat
	core_outer_ring1.rotation_degrees = Vector3(40, 0, 0)
	algorithm_core.add_child(core_outer_ring1)

	# Outer Orbital Ring 2
	core_outer_ring2 = MeshInstance3D.new()
	var r2 := TorusMesh.new()
	r2.inner_radius = 0.95
	r2.outer_radius = 1.01
	core_outer_ring2.mesh = r2
	var r2_mat := StandardMaterial3D.new()
	r2_mat.albedo_color = C_AMBER
	r2_mat.emission_enabled = true
	r2_mat.emission = C_AMBER
	r2_mat.emission_energy_multiplier = 2.0
	core_outer_ring2.material_override = r2_mat
	core_outer_ring2.rotation_degrees = Vector3(-40, 45, 0)
	algorithm_core.add_child(core_outer_ring2)

	# Core Light Source — focused tightly on the hologram core, avoiding ceiling glare
	var core_light := OmniLight3D.new()
	core_light.light_color = C_CYAN
	core_light.light_energy = 0.8
	core_light.omni_range = 2.8
	core_light.light_specular = 0.0
	algorithm_core.add_child(core_light)


# ============================================================
# ATMOSPHERIC PARTICLES (Disabled for clean, pristine air)
# ============================================================

func create_ambient_particles():
	# Ambient dust particles removed as requested for a pristine, clean environment
	pass


# ============================================================
# LIGHTING
# ============================================================

func create_lighting():
	# Key light (sun through windows)
	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_color = Color(1.0, 0.96, 0.88)   # Warm sunlight
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	add_child(sun)

	# Fill light — brightens the room and softens shadows
	var fill := DirectionalLight3D.new()
	fill.name = "FillLight"
	fill.rotation_degrees = Vector3(-30, -120, 0)
	fill.light_color = Color(0.75, 0.82, 0.95)
	fill.light_energy = 0.65
	fill.shadow_enabled = false
	add_child(fill)

	# Dedicated Whiteboard & Presentation Stage light
	var board_light := OmniLight3D.new()
	board_light.name = "WhiteboardLight"
	board_light.position = Vector3(0, 3.2, -7.2)
	board_light.light_color = Color(0.96, 0.98, 1.0)
	board_light.light_energy = 1.3
	board_light.omni_range = 6.5
	board_light.light_specular = 0.0
	add_child(board_light)

	# Center classroom point light (above pedestal & presentation area)
	var center_light := OmniLight3D.new()
	center_light.name = "CenterClassroomLight"
	center_light.position = Vector3(0, 3.5, -2.5)
	center_light.light_color = Color(0.92, 0.95, 1.0)
	center_light.light_energy = 1.1
	center_light.omni_range = 8.5
	center_light.light_specular = 0.0
	add_child(center_light)

	# Classroom rear desk area light
	var desk_light := OmniLight3D.new()
	desk_light.name = "DeskAreaLight"
	desk_light.position = Vector3(0, 3.4, 3.5)
	desk_light.light_color = Color(0.88, 0.92, 1.0)
	desk_light.light_energy = 0.85
	desk_light.omni_range = 8.0
	desk_light.light_specular = 0.0
	add_child(desk_light)

	# Accent lights for pedestals
	var accent_colors := [C_CYAN, C_PURPLE, C_AMBER]
	var accent_positions := [Vector3(-3.8, 0.5, -5.5), Vector3(0.0, 0.5, -6.5), Vector3(3.8, 0.5, -5.5)]
	for i in range(3):
		var accent := OmniLight3D.new()
		accent.position = accent_positions[i]
		accent.light_color = accent_colors[i]
		accent.light_energy = 0.75
		accent.omni_range = 4.5
		add_child(accent)


# ============================================================
# CENTRAL HUB TOPIC PEDESTALS
# ============================================================

func create_hub_pedestals():
	hub_container = Node3D.new()
	hub_container.name = "HubPedestalsContainer"
	add_child(hub_container)

	# Welcome Header (above whiteboard area)
	var welcome_label := Label3D.new()
	welcome_label.name = "WelcomeHeader"
	welcome_label.text = "✦ DSA ACADEMY — MODULE 1 ✦\nRestore the Quantum Archive"
	welcome_label.font_size = 42
	welcome_label.modulate = C_CYAN
	welcome_label.outline_size = 12
	welcome_label.outline_modulate = Color(0.01, 0.02, 0.05)
	welcome_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	welcome_label.no_depth_test = true
	welcome_label.render_priority = 10
	welcome_label.position = Vector3(0, 3.6, -6.5)
	hub_container.add_child(welcome_label)

	var sub_welcome := Label3D.new()
	sub_welcome.name = "HubSubWelcome"
	sub_welcome.text = "Start Chapter 1 first • Click a pedestal or press [1] [2] [3] • ESC frees mouse"
	sub_welcome.font_size = 20
	sub_welcome.modulate = Color(0.8, 0.9, 1.0)
	sub_welcome.outline_size = 8
	sub_welcome.outline_modulate = Color(0.01, 0.02, 0.05)
	sub_welcome.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sub_welcome.no_depth_test = true
	sub_welcome.render_priority = 10
	sub_welcome.position = Vector3(0, 2.9, -6.5)
	hub_container.add_child(sub_welcome)

	# 3 Topic Portals (positioned in front of the back wall)
	var portal_data := [
		{
			"id": 0,
			"pos": Vector3(-3.8, 0, -5.5),
			"title": "CHAPTER 1: LINEAR SEARCH",
			"sub": "Find the lost file | O(n)",
			"desc": "Check every shelf from index 0.\nWorks on unsorted data.",
			"color": C_CYAN,
			"glyph_type": "prism"
		},
		{
			"id": 1,
			"pos": Vector3(0.0, 0, -6.5),
			"title": "CHAPTER 2: BINARY SEARCH",
			"sub": "Search smarter | O(log n)",
			"desc": "Halve the search space each step.\nNeeds sorted shelves.",
			"color": C_PURPLE,
			"glyph_type": "ring"
		},
		{
			"id": 2,
			"pos": Vector3(3.8, 0, -5.5),
			"title": "CHAPTER 3: BUBBLE SORT",
			"sub": "Restore order | O(n²)",
			"desc": "Swap adjacent shelves until sorted.\nUnlocks fast searching again.",
			"color": C_AMBER,
			"glyph_type": "spheres"
		}
	]

	for data in portal_data:
		var pedestal := _create_topic_pedestal(data)
		hub_container.add_child(pedestal)
		topic_pedestals.append(pedestal)


func _create_topic_pedestal(data: Dictionary) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "TopicPedestal_%d" % data["id"]
	body.position = data["pos"]
	body.set_meta("hub_topic", data["id"])

	# Cylindrical Pedestal Base
	var base_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.85
	cylinder.bottom_radius = 1.05
	cylinder.height = 1.0
	base_mesh.mesh = cylinder

	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.12, 0.16)
	base_mat.metallic = 0.7
	base_mat.roughness = 0.25
	base_mesh.material_override = base_mat
	base_mesh.position = Vector3(0, 0.5, 0)
	body.add_child(base_mesh)

	# Glowing Neon Energy Ring around Pedestal
	var ring := MeshInstance3D.new()
	var t_mesh := TorusMesh.new()
	t_mesh.inner_radius = 0.86
	t_mesh.outer_radius = 0.92
	ring.mesh = t_mesh

	var r_mat := StandardMaterial3D.new()
	r_mat.albedo_color = data["color"]
	r_mat.emission_enabled = true
	r_mat.emission = data["color"]
	r_mat.emission_energy_multiplier = 2.0
	ring.material_override = r_mat
	ring.position = Vector3(0, 1.0, 0)
	body.add_child(ring)

	# Rotating 3D Holographic Glyph above pedestal
	var glyph_pivot := Node3D.new()
	glyph_pivot.name = "GlyphPivot"
	glyph_pivot.position = Vector3(0, 1.75, 0)
	body.add_child(glyph_pivot)
	topic_glyphs.append(glyph_pivot)

	var glyph_mesh := MeshInstance3D.new()
	glyph_mesh.name = "GlyphMesh"
	var g_mat := StandardMaterial3D.new()
	g_mat.albedo_color = data["color"]
	g_mat.emission_enabled = true
	g_mat.emission = data["color"]
	g_mat.emission_energy_multiplier = 2.4

	match data["glyph_type"]:
		"prism":
			var p := PrismMesh.new()
			p.size = Vector3(0.50, 0.65, 0.50)
			glyph_mesh.mesh = p
		"ring":
			var t := TorusMesh.new()
			t.inner_radius = 0.20
			t.outer_radius = 0.38
			glyph_mesh.mesh = t
		"spheres":
			var s := SphereMesh.new()
			s.radius = 0.25
			s.height = 0.50
			glyph_mesh.mesh = s

	glyph_mesh.material_override = g_mat
	glyph_pivot.add_child(glyph_mesh)

	# Holographic Signboard
	var sign_node := Node3D.new()
	sign_node.position = Vector3(0, 1.15, 0.70)
	body.add_child(sign_node)

	var plaque := MeshInstance3D.new()
	var p_box := BoxMesh.new()
	p_box.size = Vector3(1.55, 0.80, 0.04)
	plaque.mesh = p_box
	var p_mat := StandardMaterial3D.new()
	p_mat.albedo_color = Color(0.02, 0.05, 0.10, 0.95)
	p_mat.metallic = 0.2
	p_mat.roughness = 0.2
	plaque.material_override = p_mat
	sign_node.add_child(plaque)

	var p_border := MeshInstance3D.new()
	var pb_box := BoxMesh.new()
	pb_box.size = Vector3(1.59, 0.84, 0.02)
	p_border.mesh = pb_box
	p_border.material_override = r_mat
	p_border.position = Vector3(0, 0, -0.01)
	sign_node.add_child(p_border)

	var title_lbl := Label3D.new()
	title_lbl.text = data["title"]
	title_lbl.font_size = 26
	title_lbl.modulate = data["color"]
	title_lbl.outline_size = 8
	title_lbl.outline_modulate = Color(0.01, 0.02, 0.05)
	title_lbl.no_depth_test = true
	title_lbl.render_priority = 10
	title_lbl.position = Vector3(0, 0.20, 0.035)
	sign_node.add_child(title_lbl)

	var sub_lbl := Label3D.new()
	sub_lbl.text = data["sub"]
	sub_lbl.font_size = 17
	sub_lbl.modulate = C_WHITE
	sub_lbl.outline_size = 6
	sub_lbl.outline_modulate = Color(0.01, 0.02, 0.05)
	sub_lbl.no_depth_test = true
	sub_lbl.render_priority = 10
	sub_lbl.position = Vector3(0, 0.02, 0.035)
	sign_node.add_child(sub_lbl)

	var btn_lbl := Label3D.new()
	btn_lbl.text = "✦ CLICK OR PRESS [%d] TO ENGAGE ✦" % (data["id"] + 1)
	btn_lbl.font_size = 16
	btn_lbl.modulate = data["color"]
	btn_lbl.outline_size = 8
	btn_lbl.outline_modulate = Color(0.01, 0.02, 0.05)
	btn_lbl.no_depth_test = true
	btn_lbl.render_priority = 10
	btn_lbl.position = Vector3(0, -0.20, 0.035)
	sign_node.add_child(btn_lbl)

	# Collision Shape for Raycast Interaction — ENLARGED for reliable clicking
	var coll := CollisionShape3D.new()
	coll.name = "CollisionShape3D"
	var shape := CylinderShape3D.new()
	shape.radius = 1.2    # Wider for easier clicking
	shape.height = 2.8    # Taller to catch aim above pedestal
	coll.shape = shape
	coll.position = Vector3(0, 1.4, 0)
	body.add_child(coll)

	return body


# ============================================================
# HUB INTERACTION & ANIMATION
# ============================================================

func _process(delta: float):
	time_elapsed += delta

	# Rotate and animate Central Algorithm Core
	if algorithm_core:
		if core_inner:
			core_inner.rotate_y(1.0 * delta)
			core_inner.position.y = sin(time_elapsed * 2.0) * 0.06
		if core_outer_ring1:
			core_outer_ring1.rotate_y(1.5 * delta)
			core_outer_ring1.rotate_x(0.5 * delta)
		if core_outer_ring2:
			core_outer_ring2.rotate_y(-1.2 * delta)
			core_outer_ring2.rotate_z(0.6 * delta)

	# Rotate topic holographic glyphs
	for i in range(topic_glyphs.size()):
		var glyph = topic_glyphs[i]
		if is_instance_valid(glyph):
			glyph.rotate_y(1.0 * delta)
			glyph.position.y = 1.75 + sin(time_elapsed * 2.2 + i * 1.2) * 0.05


func on_topic_pedestal_hover(topic_idx: int, is_hover: bool):
	if topic_idx < 0 or topic_idx >= topic_glyphs.size():
		return
	var glyph = topic_glyphs[topic_idx]
	if is_instance_valid(glyph):
		var target_scale = Vector3.ONE * (1.25 if is_hover else 1.0)
		var tween = create_tween()
		if tween != null:
			tween.tween_property(glyph, "scale", target_scale, 0.25).set_trans(Tween.TRANS_BACK)


func on_topic_selected(topic_idx: int):
	if lesson_manager and lesson_manager.has_method("try_launch_lesson"):
		lesson_manager.try_launch_lesson(topic_idx)
	elif lesson_manager and lesson_manager.has_method("launch_lesson"):
		lesson_manager.launch_lesson(topic_idx)


func refresh_hub_unlock_labels():
	var pm = get_node_or_null("/root/ProgressManager")
	if hub_container == null:
		return
	var sub = hub_container.get_node_or_null("HubSubWelcome")
	if sub and pm:
		if pm.module1_complete:
			sub.text = "Module 1 complete — free roam any chapter • [H] Hub • [R] Restart lesson"
		else:
			sub.text = "Unlocked through Chapter %d • Click pedestal or [1][2][3] • ESC frees mouse" % (pm.highest_unlocked + 1)


func set_hub_active(active: bool):
	hub_active = active
	if hub_container:
		hub_container.visible = active
		for p in topic_pedestals:
			if is_instance_valid(p):
				var coll = p.get_node_or_null("CollisionShape3D")
				if coll:
					coll.disabled = not active
	if active:
		refresh_hub_unlock_labels()


# ============================================================
# GAME SYSTEMS INITIALIZATION
# ============================================================

func create_dsa_systems():
	var array_script = load("res://array_system.gd")
	if array_script == null:
		push_error("Could not load res://array_system.gd")
		return

	array_system = array_script.new()
	array_system.name = "ArraySystem"
	add_child(array_system)

	array_system.position = Vector3(0, 0.45, -3.2)
	array_system.visible = false


func create_game_ui():
	var ui_script = load("res://game_ui.gd")
	if ui_script == null:
		push_error("Could not load res://game_ui.gd")
		return

	game_ui = ui_script.new()
	game_ui.name = "GameUI"
	add_child(game_ui)


func create_player():
	var player_script = load("res://player.gd")
	if player_script == null:
		push_error("Could not load res://player.gd")
		return

	player = player_script.new()
	player.name = "Player"
	player.position = Vector3(0.0, 0.0, 6.2)
	add_child(player)


func setup_system_connections():
	if player and game_ui:
		player.setup_game_ui(game_ui)


func create_lesson_manager():
	var lm_script = load("res://lesson_manager.gd")
	if lm_script == null:
		push_error("Could not load res://lesson_manager.gd")
		return

	lesson_manager = lm_script.new()
	lesson_manager.name = "LessonManager"
	add_child(lesson_manager)

	lesson_manager.setup(array_system, game_ui)
	lesson_manager.start_lesson()
