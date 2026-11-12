extends Node

# ============================================================
# ENGINE 2 SCENE BUILDER
# Attach to a plain Node named "Engine2Boot" in engine_2_boot.tscn
# On run, builds and switches to the full Engine 2 scene.
# ============================================================

func _ready() -> void:
	call_deferred("_build_and_run")

func _build_and_run() -> void:
	var root: Node3D = _build_engine2_scene()
	get_tree().root.add_child(root)
	get_tree().current_scene = root
	queue_free()

func _build_engine2_scene() -> Node3D:
	var main := Node3D.new()
	main.name = "Engine2Main"
	main.set_script(load("res://scripts/Engine2Main.gd"))

	# ── World Environment ──────────────────────────────────
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.02)
	env.ambient_light_color = Color(0.05, 0.1, 0.06)
	env.ambient_light_energy = 0.4
	env.fog_enabled = true
	env.fog_density = 0.012
	env.fog_light_color = Color(0.03, 0.08, 0.04)
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.15
	world_env.environment = env
	main.add_child(world_env)
	world_env.owner = main

	# ── Directional Light ──────────────────────────────────
	var sun := DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_color = Color(0.7, 0.9, 0.75)
	sun.light_energy = 0.6
	sun.shadow_enabled = true
	main.add_child(sun)
	sun.owner = main

	# ── Factory Floor ──────────────────────────────────────
	var factory := Node3D.new()
	factory.name = "FactoryFloor"
	factory.set_script(load("res://scripts/FactoryFloor.gd"))
	main.add_child(factory)
	factory.owner = main

	for child_name: String in ["ConveyorSystem", "RoboticArms"]:
		var child := Node3D.new()
		child.name = child_name
		factory.add_child(child)
		child.owner = main

	var laser := Node3D.new()
	laser.name = "LaserGrid"
	laser.set_script(load("res://scripts/LaserGrid.gd"))
	laser.position = Vector3(0, 0, 3.0)
	factory.add_child(laser)
	laser.owner = main

	var vault := Node3D.new()
	vault.name = "VaultDoor"
	vault.set_script(load("res://scripts/VaultDoor.gd"))
	vault.position = Vector3(0, 2.0, -14.8)
	factory.add_child(vault)
	vault.owner = main

	# ── PHYSICAL C-TERMINAL AND EMBEDDED UI ─────────────────
	var terminal := Node3D.new()
	terminal.name = "CTerminal"
	terminal.set_script(load("res://scripts/CTerminal.gd"))
	terminal.position = Vector3(0, 0.3, 12.0)
	main.add_child(terminal)
	terminal.owner = main

	# Create the internal 3D monitor screen
	var viewport := SubViewport.new()
	viewport.name = "ScreenViewport"
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.gui_disable_input = false
	terminal.add_child(viewport)
	viewport.owner = main

	# Embed the UI directly into the 3D monitor
	var ui_script: Script = load("res://scripts/UIManagers.gd")
	if ui_script == null:
		push_error("ENGINE 2: Could not load UIManagers.gd!")
	else:
		var ui = Control.new()
		ui.name = "UI"
		ui.set_script(ui_script)
		viewport.add_child(ui)
		ui.owner = main

	# ── Player Camera ──────────────────────────────────────
	var camera := Camera3D.new()
	camera.name = "PlayerCamera"
	camera.set_script(load("res://scripts/PlayerCamera.gd"))
	
	# Position camera realistically in front of the 3D computer terminal
	camera.position = Vector3(0, 2.15, 13.3) 
	camera.rotation_degrees = Vector3(-4, 0, 0)
	camera.current = true
	main.add_child(camera)
	camera.owner = main

	# ── Audio Manager ──────────────────────────────────────
	var audio := Node.new()
	audio.name = "AudioManager"
	main.add_child(audio)
	audio.owner = main

	for snd_def: Array in [
		["AmbientPlayer", -12.0],
		["CompileSound",   -6.0],
		["AlarmSound",     -3.0],
		["VictorySound",   -8.0],
	]:
		var snd := AudioStreamPlayer.new()
		snd.name = snd_def[0]
		snd.volume_db = snd_def[1]
		audio.add_child(snd)
		snd.owner = main

	return main
