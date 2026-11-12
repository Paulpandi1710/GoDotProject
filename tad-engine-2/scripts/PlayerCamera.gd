extends Camera3D

# ============================================================
# PLAYER CAMERA — Engine 2, Automation Foundry
# PC build: WASD + mouse look
# VR build: Replace with XRCamera3D and XROrigin3D
# ============================================================

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.002
@export var sprint_multiplier: float = 2.0

var mouse_captured: bool = false
var velocity: Vector3 = Vector3.ZERO
var pitch: float = 0.0

# Camera bounds — keep player inside factory
const MIN_POS := Vector3(-10.0, 0.5, -10.0)
const MAX_POS := Vector3(10.0, 5.0, 10.0)

# Terminal focus mode — disable movement when typing
var terminal_focus: bool = false


func _ready() -> void:
	_capture_mouse()
	# Scale FOV based on display resolution
	var screen: Vector2i = DisplayServer.window_get_size()
	var base_fov: float = 75.0
	var aspect: float = float(screen.x) / float(screen.y)
	fov = base_fov * clamp(aspect / (16.0 / 9.0), 0.8, 1.2)


func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func _release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


func _input(event: InputEvent) -> void:
	# Toggle terminal focus with Tab
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		terminal_focus = !terminal_focus
		if terminal_focus:
			_release_mouse()
		else:
			_capture_mouse()

	# Escape = release mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_release_mouse()

	# Click to recapture
	if event is InputEventMouseButton and event.pressed and not terminal_focus:
		_capture_mouse()

	# Mouse look
	if event is InputEventMouseMotion and mouse_captured and not terminal_focus:
		rotation.y -= event.relative.x * look_sensitivity
		pitch = clamp(pitch - event.relative.y * look_sensitivity, -PI / 3.0, PI / 3.0)
		rotation.x = pitch


func _process(delta: float) -> void:
	if terminal_focus:
		return

	var direction := Vector3.ZERO
	var speed := move_speed * (sprint_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)

	if Input.is_key_pressed(KEY_W):
		direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += transform.basis.x
	if Input.is_key_pressed(KEY_Q):
		direction -= Vector3.UP
	if Input.is_key_pressed(KEY_E):
		direction += Vector3.UP

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = velocity.lerp(direction * speed, delta * 8.0)
	position += velocity * delta
	position = position.clamp(MIN_POS, MAX_POS)


# Called by Engine2Main to lock camera during cutscenes
func lock_camera() -> void:
	set_process(false)
	set_process_input(false)


func unlock_camera() -> void:
	set_process(true)
	set_process_input(true)
