extends Node
class_name AudioManager

static var clack_stream: AudioStream
static var success_stream: AudioStream
static var error_stream: AudioStream

static func _load_streams():
	if clack_stream == null:
		clack_stream = load("res://assets/audio/clack.wav")
	if success_stream == null:
		success_stream = load("res://assets/audio/success.wav")
	if error_stream == null:
		error_stream = load("res://assets/audio/error.wav")

static func play_3d_sound(type: String, pos: Vector3, caller: Node):
	_load_streams()
	
	var player = AudioStreamPlayer3D.new()
	if type == "clack":
		player.stream = clack_stream
		player.pitch_scale = randf_range(0.85, 1.15)
		player.volume_db = -5.0
	elif type == "success":
		player.stream = success_stream
		player.volume_db = -3.0
	elif type == "error":
		player.stream = error_stream
		player.volume_db = -1.0
		
	if player.stream == null:
		player.queue_free()
		return
		
	player.position = pos
	# Delete the AudioPlayer after it finishes playing to prevent memory leaks
	player.finished.connect(func(): player.queue_free())
	
	# Try to add it directly to a safe root or just the caller
	if is_instance_valid(caller):
		caller.add_child(player)
		player.play()
	else:
		player.queue_free()
