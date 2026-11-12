extends Node3D

# ============================================================
# ENGINE 2 — THE AUTOMATION FOUNDRY
# Unit 3: Iteration — for/while loops control the factory
# ============================================================

enum GameState {
	INTRO,
	PLAYING,
	COMPILING,
	LOCKDOWN,
	VICTORY
}

var current_state: GameState = GameState.INTRO

const TOTAL_LASER_LAYERS: int = 5
var laser_layers_cleared: int = 0

var loop_iterator: int = 0
var loop_target: int = 0
var loop_timer: Timer
var primes_found: Array[int] = []
var execution_running: bool = false

var lockdown_timer: Timer
const LOCKDOWN_DURATION: float = 8.0

var challenges := [
	{
		"id": "for_conveyor",
		"title": "CHALLENGE 1 — Restore Automated Assembly Lines",
		"description": "Use a [b]for loop[/b] to send 10 continuous power pulses to the conveyor machinery.",
		"hint": "for (int i = 1; i <= 10; i++) { printf(\"%d\\n\", i); }",
		"validate": "_validate_for_loop",
		"laser_reward": 1,
	},
	{
		"id": "while_arms",
		"title": "CHALLENGE 2 — Calibrate the Robotic Arms",
		"description": "Use a [b]while loop[/b] to count DOWN from 5 to 1.\nThe arms require a looping power signal countdown.",
		"hint": "int i = 5; while (i >= 1) { printf(\"%d\\n\", i); i--; }",
		"validate": "_validate_while_loop",
		"laser_reward": 1,
	},
	{
		"id": "nested_pattern",
		"title": "CHALLENGE 3 — Sync the Assembly Pattern",
		"description": "Use [b]nested for loops[/b] to print a 3x3 grid of '#' symbols.\nThe arms must synchronize to this pattern.",
		"hint": "for(int r=0;r<3;r++){ for(int c=0;c<3;c++){ printf(\"# \"); } printf(\"\\n\"); }",
		"validate": "_validate_nested_loop",
		"laser_reward": 1,
	},
	{
		"id": "prime_laser",
		"title": "CHALLENGE 4 — PRIME SEQUENCE (Laser Grid)",
		"description": "Generate all [b]prime numbers[/b] from 2 to 30.\nThe laser grid will sequentially shut down, matching your loop iterations.",
		"hint": "for(int n=2;n<=30;n++){ int p=1; for(int i=2;i<n;i++) if(n%i==0){p=0;break;} if(p) printf(\"%d\\n\",n); }",
		"validate": "_validate_primes",
		"laser_reward": 2,
	},
]

var current_challenge_index := 0

var code_edit: CodeEdit
var compile_btn: Button
var output_label: RichTextLabel
var hint_btn: Button
var stage_label: Label
var laser_status: Label
var alarm_label: Label
var intro_panel: Panel
var terminal_panel: Panel
var status_hud: Panel

# THE UPDATED PATH: Tells the Game Master the UI is inside the 3D Terminal!
@onready var ui_manager                      = $CTerminal/ScreenViewport/UI

@onready var conveyor_system: Node3D         = $FactoryFloor/ConveyorSystem
@onready var robotic_arms: Node3D            = $FactoryFloor/RoboticArms
@onready var laser_grid: Node3D              = $FactoryFloor/LaserGrid
@onready var vault_door: Node3D              = $FactoryFloor/VaultDoor
@onready var ambient_player: AudioStreamPlayer = $AudioManager/AmbientPlayer
@onready var compile_sound: AudioStreamPlayer  = $AudioManager/CompileSound
@onready var alarm_sound: AudioStreamPlayer    = $AudioManager/AlarmSound
@onready var victory_sound: AudioStreamPlayer  = $AudioManager/VictorySound


func _ready() -> void:
	_setup_timers()
	_scale_all_nodes()
	_init_ui()
	_set_state(GameState.INTRO)

func _init_ui() -> void:
	if not ui_manager.has_method("build_all"):
		push_error("Engine2Main: $UI node does not have the UI script attached! Check your file names.")
		return

	ui_manager.build_all()

	code_edit      = ui_manager.code_edit
	compile_btn    = ui_manager.compile_btn
	output_label   = ui_manager.output_label
	hint_btn       = ui_manager.hint_btn
	stage_label    = ui_manager.stage_label
	laser_status   = ui_manager.laser_status
	alarm_label    = ui_manager.alarm_label
	intro_panel    = ui_manager.intro_panel
	terminal_panel = ui_manager.terminal_panel
	status_hud     = ui_manager.status_hud

	compile_btn.pressed.connect(_on_compile_pressed)
	hint_btn.pressed.connect(_on_hint_pressed)
	ui_manager.start_btn.pressed.connect(_on_start_pressed)

	_load_challenge(0)

func _scale_all_nodes() -> void:
	var screen_size: Vector2i = DisplayServer.window_get_size()
	var base_w: float = 1920.0
	var base_h: float = 1080.0
	var scale_x: float = float(screen_size.x) / base_w
	var scale_y: float = float(screen_size.y) / base_h
	var factory_scale: Vector3 = Vector3(scale_x, scale_y, min(scale_x, scale_y))
	$FactoryFloor.scale = factory_scale.clamp(Vector3(0.5, 0.5, 0.5), Vector3(2.0, 2.0, 2.0))

func _setup_timers() -> void:
	loop_timer = Timer.new()
	loop_timer.wait_time = 0.3
	loop_timer.one_shot = false
	loop_timer.timeout.connect(_on_loop_tick)
	add_child(loop_timer)

	lockdown_timer = Timer.new()
	lockdown_timer.wait_time = LOCKDOWN_DURATION
	lockdown_timer.one_shot = true
	lockdown_timer.timeout.connect(_on_lockdown_end)
	add_child(lockdown_timer)

func _set_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.INTRO:
			intro_panel.visible = true
			terminal_panel.visible = false
			status_hud.visible = false
			_pause_factory()

		GameState.PLAYING:
			intro_panel.visible = false
			terminal_panel.visible = true
			status_hud.visible = true
			alarm_label.visible = false
			compile_btn.disabled = false
			_start_ambient()
			call_deferred("_focus_editor")

		GameState.COMPILING:
			compile_btn.disabled = true
			output_label.clear()
			output_label.append_text("[color=#00ff88][ COMPILING... ][/color]\n")

		GameState.LOCKDOWN:
			alarm_label.visible = true
			alarm_label.text = "⚠ LOCKDOWN — INFINITE LOOP DETECTED ⚠"
			compile_btn.disabled = true
			_trigger_lockdown_vfx()
			alarm_sound.play()
			lockdown_timer.start()

		GameState.VICTORY:
			terminal_panel.visible = false
			_trigger_victory()

func _focus_editor() -> void:
	if code_edit:
		code_edit.grab_focus()

func _on_start_pressed() -> void:
	_set_state(GameState.PLAYING)

func _load_challenge(index: int) -> void:
	if index >= challenges.size():
		_set_state(GameState.VICTORY)
		return

	current_challenge_index = index
	var ch: Dictionary = challenges[index]

	stage_label.text = "STAGE %d / %d   |   %s" % [index + 1, challenges.size(), ch["title"]]
	laser_status.text = "LASER LAYERS ACTIVE: %d / %d" % [TOTAL_LASER_LAYERS - laser_layers_cleared, TOTAL_LASER_LAYERS]

	output_label.clear()
	output_label.append_text("[color=#ffdd44][b]%s[/b][/color]\n\n" % ch["title"])
	output_label.append_text("[color=#aaaaff]%s[/color]\n\n" % ch["description"])
	output_label.append_text("[color=#888888]Write your C code in the editor above and press COMPILE.[/color]\n")

	code_edit.text = "// Engine 2 — Automation Foundry\n// Write your loop here:\n\n#include <stdio.h>\n\nint main() {\n\n    return 0;\n}\n"

func _on_compile_pressed() -> void:
	if current_state != GameState.PLAYING:
		return
	_set_state(GameState.COMPILING)
	compile_sound.play()
	await get_tree().create_timer(1.2).timeout
	_evaluate_code(code_edit.text)

func _on_hint_pressed() -> void:
	var ch: Dictionary = challenges[current_challenge_index]
	output_label.append_text("\n[color=#ff9944][b]HINT:[/b] %s[/color]\n" % ch["hint"])

func _evaluate_code(code: String) -> void:
	var ch: Dictionary = challenges[current_challenge_index]
	var method_name: String = ch["validate"]

	if _detect_infinite_loop(code):
		_trigger_lockdown()
		return

	var result: Dictionary = call(method_name, code)

	if result["pass"]:
		output_label.append_text("\n[color=#00ff88][b]✔ COMPILE SUCCESS![/b][/color]\n")
		output_label.append_text("[color=#00ffcc]%s[/color]\n" % result["message"])
		_on_challenge_passed(ch)
	else:
		output_label.append_text("\n[color=#ff4444][b]✘ COMPILE FAILED[/b][/color]\n")
		output_label.append_text("[color=#ff8888]%s[/color]\n" % result["message"])
		output_label.append_text("[color=#888888]Check your logic and try again.[/color]\n")
		_set_state(GameState.PLAYING)

func _detect_infinite_loop(code: String) -> bool:
	var lower := code.to_lower()
	if lower.contains("while(1)") or lower.contains("while( 1 )") \
	or lower.contains("while(true)") or lower.contains("for(;;)") \
	or lower.contains("for( ; ; )"):
		return true

	var while_re := RegEx.new()
	while_re.compile(r"while\s*\([^)]+\)")
	var wm := while_re.search(code)
	if wm:
		var condition := wm.get_string()
		var var_re := RegEx.new()
		var_re.compile(r"[a-zA-Z_]\w*")
		var vars := var_re.search_all(condition)
		var has_mutation := false
		for v in vars:
			var vname := v.get_string()
			if vname in ["while", "int", "float", "true", "false"]:
				continue
			if code.contains(vname + "++") or code.contains("++" + vname) \
			or code.contains(vname + "--") or code.contains("--" + vname) \
			or code.contains(vname + " +=") or code.contains(vname + " -=") \
			or code.contains(vname + "="):
				has_mutation = true
				break
		if not has_mutation and wm:
			return true
	return false

func _validate_for_loop(code: String) -> Dictionary:
	var has_for := code.contains("for")
	var has_i_init := (code.contains("i = 1") or code.contains("i=1"))
	var has_condition := (code.contains("<= 10") or code.contains("<=10") or code.contains("< 11") or code.contains("<11"))
	var has_increment := (code.contains("i++") or code.contains("++i") or code.contains("i += 1") or code.contains("i+=1"))
	var has_printf := code.contains("printf")

	if not has_for: return {"pass": false, "message": "No 'for' keyword found. Use a for loop!"}
	if not has_i_init: return {"pass": false, "message": "Initialize your counter to 1 (i = 1)."}
	if not has_condition: return {"pass": false, "message": "Loop must run while i <= 10."}
	if not has_increment: return {"pass": false, "message": "Increment your counter with i++."}
	if not has_printf: return {"pass": false, "message": "Use printf() to output each number."}
	return {"pass": true, "message": "Machinery reacting in real-time... 10 power pulses looping ✔"}

func _validate_while_loop(code: String) -> Dictionary:
	var has_while := code.contains("while")
	var has_init := (code.contains("i = 5") or code.contains("i=5"))
	var has_condition := (code.contains("i >= 1") or code.contains("i>=1") or code.contains("i > 0") or code.contains("i>0"))
	var has_decrement := (code.contains("i--") or code.contains("--i") or code.contains("i -= 1") or code.contains("i-=1"))
	var has_printf := code.contains("printf")

	if not has_while: return {"pass": false, "message": "No 'while' keyword found. Use a while loop!"}
	if not has_init: return {"pass": false, "message": "Initialize counter to 5 (i = 5)."}
	if not has_condition: return {"pass": false, "message": "Condition should be i >= 1 or i > 0."}
	if not has_decrement: return {"pass": false, "message": "Decrement your counter with i--."}
	if not has_printf: return {"pass": false, "message": "Use printf() to output each number."}
	return {"pass": true, "message": "Robotic arms calibrating to looping signal countdown ✔"}

func _validate_nested_loop(code: String) -> Dictionary:
	var for_count := code.split("for").size() - 1
	if for_count < 2: return {"pass": false, "message": "Need TWO for loops (nested). Outer for rows, inner for columns."}

	var has_hash := (code.contains("\"#\"") or code.contains("'#'") or code.contains("\"# \""))
	if not has_hash: return {"pass": false, "message": "Print the '#' character in the inner loop."}

	var has_newline := (code.contains("\\n") or code.contains("printf(\"\\n\")") or code.contains("puts"))
	if not has_newline: return {"pass": false, "message": "Add a newline (\\n) after each row in the outer loop."}

	var has_3 := (code.contains("< 3") or code.contains("<3") or code.contains("<= 2") or code.contains("<=2") or code.contains("< 4") or code.contains("<4"))
	if not has_3: return {"pass": false, "message": "Both loops should run 3 times (i < 3)."}
	return {"pass": true, "message": "Assembly grid pattern locked in! Robotic arms synced 3×3 ✔"}

func _validate_primes(code: String) -> Dictionary:
	var has_outer_for := code.contains("for")
	var has_modulo := code.contains("%")
	var has_inner_loop := (code.split("for").size() - 1 >= 2) or code.contains("while")
	var has_printf := code.contains("printf")

	if not has_outer_for: return {"pass": false, "message": "Use an outer for loop to iterate numbers 2 to 30."}
	if not has_modulo: return {"pass": false, "message": "Use the modulo operator % to check divisibility."}
	if not has_inner_loop: return {"pass": false, "message": "Use a nested loop to test each number for factors."}
	if not has_printf: return {"pass": false, "message": "Use printf() to print each prime found."}

	var has_range := (code.contains("30") or code.contains("<= 30") or code.contains("<=30"))
	if not has_range: return {"pass": false, "message": "Your loop must go up to 30."}

	primes_found = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	return {"pass": true, "message": "10 PRIMES COMPILED. Linking physical machinery to iteration array... ✔"}


func _on_challenge_passed(ch: Dictionary) -> void:
	var reward: int = ch["laser_reward"]
	laser_layers_cleared += reward
	laser_layers_cleared = min(laser_layers_cleared, TOTAL_LASER_LAYERS)

	laser_status.text = "LASER LAYERS ACTIVE: %d / %d" % [TOTAL_LASER_LAYERS - laser_layers_cleared, TOTAL_LASER_LAYERS]

	match ch["id"]:
		"for_conveyor":
			_animate_conveyor_start()
		"while_arms":
			_animate_arms_calibrate()
		"nested_pattern":
			_animate_arms_grid()
		"prime_laser":
			_animate_laser_prime_sequence()

	await get_tree().create_timer(2.5).timeout

	if laser_layers_cleared >= TOTAL_LASER_LAYERS:
		_set_state(GameState.VICTORY)
	else:
		current_challenge_index += 1
		_load_challenge(current_challenge_index)
		_set_state(GameState.PLAYING)


func _pause_factory() -> void:
	if conveyor_system:
		for belt in conveyor_system.get_children():
			if belt.has_method("stop_belt"):
				belt.stop_belt()

func _start_ambient() -> void:
	if ambient_player and not ambient_player.playing:
		ambient_player.play()

func _animate_conveyor_start() -> void:
	output_label.append_text("\n[color=#00ffaa]► POWER PULSES ROUTING TO CONVEYOR...[/color]\n")
	loop_iterator = 0
	loop_target = 10
	execution_running = true
	loop_timer.start()

	for belt in conveyor_system.get_children():
		if belt.has_method("start_belt"):
			belt.start_belt()

func _on_loop_tick() -> void:
	if not execution_running:
		loop_timer.stop()
		return
	loop_iterator += 1
	output_label.append_text("[color=#00ff88]  Loop pulse %d matching physical machinery...[/color]\n" % loop_iterator)
	_flash_laser_layer(loop_iterator - 1)
	if loop_iterator >= loop_target:
		loop_timer.stop()
		execution_running = false

func _animate_arms_calibrate() -> void:
	output_label.append_text("\n[color=#00ffaa]► ROBOTIC ARMS CALIBRATING...[/color]\n")
	var count := 5
	for arm in robotic_arms.get_children():
		var tween := create_tween()
		tween.tween_property(arm, "rotation_degrees:z", -45.0, 0.3)
		tween.tween_property(arm, "rotation_degrees:z", 0.0, 0.3)
		tween.tween_property(arm, "rotation_degrees:z", -30.0, 0.3)
		tween.tween_property(arm, "rotation_degrees:z", 0.0, 0.3)
		count -= 1
		output_label.append_text("[color=#00ff88]  Arm countdown loop tracking: %d[/color]\n" % count)

func _animate_arms_grid() -> void:
	output_label.append_text("\n[color=#00ffaa]► ASSEMBLY PATTERN SYNCING...[/color]\n")
	var arms := robotic_arms.get_children()
	var arm_idx := 0
	for r in range(3):
		for c in range(3):
			if arm_idx < arms.size():
				var arm := arms[arm_idx]
				var tween := create_tween()
				tween.tween_property(arm, "position", arm.position + Vector3(c * 0.5, 0, r * 0.5), 0.4)
				tween.tween_property(arm, "position", arm.position, 0.4)
				arm_idx += 1
			output_label.append_text("[color=#00ff88]  Grid position [%d][%d] locked ✔[/color]\n" % [r, c])

func _animate_laser_prime_sequence() -> void:
	output_label.append_text("\n[color=#ff4444]► SEQUENTIALLY DEACTIVATING LASER GRID... MATCHING LOOP ITERATIONS...[/color]\n")
	var layers := laser_grid.get_children()
	var delay := 0.0

	for i in range(layers.size()):
		var layer: Node3D = layers[i]
		var prime_label := primes_found[i] if i < primes_found.size() else 0
		var tween := create_tween()
		tween.tween_interval(delay)
		tween.tween_callback(func():
			output_label.append_text("[color=#ff4400]  Prime %d generated → Physical Layer %d DEACTIVATED ✔[/color]\n" % [prime_label, i + 1])
		)
		tween.tween_property(layer, "visible", false, 0.0)
		tween.tween_property(layer, "scale", Vector3.ZERO, 0.5)
		delay += 0.6

	await get_tree().create_timer(delay + 1.0).timeout
	_animate_vault_open()

func _flash_laser_layer(index: int) -> void:
	var layers := laser_grid.get_children()
	if index < layers.size():
		var layer: Node3D = layers[index]
		var tween := create_tween()
		tween.tween_property(layer, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
		tween.tween_property(layer, "scale", Vector3.ONE, 0.1)

func _animate_vault_open() -> void:
	output_label.append_text("\n[color=#ffff00][b]► PHYSICAL DOORS ARE UNLOCKING...[/b][/color]\n")
	if vault_door:
		var tween := create_tween()
		tween.tween_property(vault_door, "position:y", vault_door.position.y + 6.0, 3.0) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)


func _trigger_lockdown() -> void:
	_set_state(GameState.LOCKDOWN)

func _trigger_lockdown_vfx() -> void:
	output_label.clear()
	output_label.append_text("[color=#ff0000][b]⚠ INFINITE LOOP DETECTED ⚠[/b][/color]\n")
	output_label.append_text("[color=#ff4444]Robotic arms are spinning out of control!\nSPARKS ARE FLYING ACROSS THE FACTORY FLOOR!\n[/color]")
	output_label.append_text("[color=#ff8800]FACILITY LOCKDOWN INITIATED — %d seconds[/color]\n" % int(LOCKDOWN_DURATION))

	for arm in robotic_arms.get_children():
		var tween := create_tween().set_loops(4)
		tween.tween_property(arm, "rotation_degrees:y", 360.0, 0.5)

	for layer in laser_grid.get_children():
		var tween := create_tween().set_loops(8)
		tween.tween_property(layer, "scale", Vector3(1.3, 1.3, 1.3), 0.2)
		tween.tween_property(layer, "scale", Vector3.ONE, 0.2)

func _on_lockdown_end() -> void:
	output_label.append_text("\n[color=#00ff88][ LOCKDOWN LIFTED — Check your loop logic and try again ][/color]\n")
	alarm_label.visible = false
	alarm_sound.stop()
	_set_state(GameState.PLAYING)


func _trigger_victory() -> void:
	output_label.clear()
	output_label.append_text("[color=#ffff00][b]🏭 AUTOMATION FOUNDRY — ONLINE[/b][/color]\n\n")
	output_label.append_text("[color=#00ff88]All laser layers DEACTIVATED.\n[/color]")
	output_label.append_text("[color=#00ffcc]Heavy vault doors OPEN.\n[/color]")
	output_label.append_text("[color=#ffffff]Engine 2 is fully operational. Assembly lines restored.\n\n[/color]")
	output_label.append_text("[color=#ffdd44][b]Proceed deeper into the facility to ENGINE 3 — THE DATA VAULT[/b][/color]\n")

	victory_sound.play()
	ambient_player.stop()

	for child in $FactoryFloor.get_children():
		var tween := create_tween()
		tween.tween_property(child, "scale", child.scale * 1.1, 2.0).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(3.0).timeout
	stage_label.text = "✔ ENGINE 2 COMPLETE — ENGINE 3 UNLOCKED"
	laser_status.text = "ALL SYSTEMS NOMINAL"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if current_state == GameState.INTRO and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			_on_start_pressed()
		elif current_state == GameState.PLAYING and event.keycode == KEY_ENTER and event.ctrl_pressed:
			_on_compile_pressed()ww
