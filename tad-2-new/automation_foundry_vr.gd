extends Node3D
class_name AutomationFoundryVR

const REQUIRED_PRIMES = 7

var terminal: CTerminal
var machinery: FactoryMachinery
var laser_grid: LaserGrid
var xr_interface: XRInterface

func _ready():
	print("[SYSTEM] Booting Engine 2: VR Automation Foundry...")
	_initialize_vr()
	_procedurally_generate_room()
	_build_vr_player()
	_connect_compilers()

func _initialize_vr():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("[SYSTEM] Headset linked. Entering immersion.")
		
		# This is the crucial line that tells Godot to output to your VR headset
		get_viewport().use_xr = true 
		
		# Turn off V-Sync as OpenXR handles its own framerate pacing
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		print("[FATAL ERROR] OpenXR not initialized. Is your headset plugged in?")

func _build_vr_player():
	# 1. The physical center of your play area
	var xr_origin = XROrigin3D.new()
	add_child(xr_origin)
	xr_origin.position = Vector3(0, 0, 8) # Stand back from the lasers

	# 2. Your Headset
	var xr_camera = XRCamera3D.new()
	xr_origin.add_child(xr_camera)

	# 3. Your Left Hand (Meltdown switch)
	var left_hand = XRController3D.new()
	left_hand.tracker = "left_hand"
	left_hand.button_pressed.connect(_on_left_hand_button)
	xr_origin.add_child(left_hand)

	# 4. Your Right Hand (Prime Loop switch)
	var right_hand = XRController3D.new()
	right_hand.tracker = "right_hand"
	right_hand.button_pressed.connect(_on_right_hand_button)
	xr_origin.add_child(right_hand)

func _procedurally_generate_room():
	laser_grid = LaserGrid.new()
	add_child(laser_grid)
	laser_grid.build_grid(REQUIRED_PRIMES)
	
	machinery = FactoryMachinery.new()
	add_child(machinery)
	machinery.build_arms()
	
	terminal = CTerminal.new()
	add_child(terminal)

func _connect_compilers():
	terminal.prime_found.connect(_on_prime_found)
	terminal.infinite_loop_detected.connect(_on_meltdown)

# VR Interaction Mapping
func _on_right_hand_button(button_name: String):
	# 'trigger_click' is the standard OpenXR trigger pull
	if button_name == "trigger_click":
		terminal.compile_code("prime_loop")

func _on_left_hand_button(button_name: String):
	if button_name == "trigger_click":
		terminal.compile_code("infinite_loop")

func _on_prime_found(prime: int, index: int):
	laser_grid.shutdown_layer(index)

func _on_meltdown():
	machinery.trigger_meltdown()
	_spawn_alarm_lights()

func _spawn_alarm_lights():
	var alarm = OmniLight3D.new()
	alarm.light_color = Color.RED
	alarm.light_energy = 15.0
	alarm.position = Vector3(0, 5, 0)
	add_child(alarm)
	
	var tween = create_tween().set_loops()
	tween.tween_property(alarm, "light_energy", 0.0, 0.5)
	tween.tween_property(alarm, "light_energy", 15.0, 0.5)
