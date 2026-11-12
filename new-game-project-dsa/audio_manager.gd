## ============================================================
## DSA ACADEMY — AUDIO MANAGER
##
## Procedural audio feedback for the game.
## Uses AudioStreamGenerator for simple synthesized sounds
## so no external audio files are needed.
##
## Add as autoload: AudioManager
## ============================================================

extends Node


# ============================================================
# AUDIO PLAYERS
# ============================================================

var _hover_player: AudioStreamPlayer
var _click_player: AudioStreamPlayer
var _compare_player: AudioStreamPlayer
var _wrong_player: AudioStreamPlayer
var _success_player: AudioStreamPlayer
var _level_complete_player: AudioStreamPlayer


# ============================================================
# READY
# ============================================================

func _ready():
	_hover_player = _create_player()
	_click_player = _create_player()
	_compare_player = _create_player()
	_wrong_player = _create_player()
	_success_player = _create_player()
	_level_complete_player = _create_player()


func _create_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.bus = "Master"
	player.volume_db = -8.0
	add_child(player)
	return player


# ============================================================
# SOUND GENERATION
# ============================================================

func _generate_tone(frequency: float, duration: float, volume: float = 0.3) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in range(num_samples):
		var t := float(i) / sample_rate
		var envelope := 1.0 - (float(i) / num_samples)  # Fade out
		envelope = envelope * envelope  # Exponential decay
		var sample := sin(t * frequency * TAU) * volume * envelope
		data[i] = int((sample + 1.0) * 0.5 * 255.0)

	audio.data = data
	return audio


func _generate_noise_burst(duration: float, volume: float = 0.15) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in range(num_samples):
		var envelope := 1.0 - (float(i) / num_samples)
		var sample := (randf() * 2.0 - 1.0) * volume * envelope
		data[i] = int((sample + 1.0) * 0.5 * 255.0)

	audio.data = data
	return audio


# ============================================================
# PUBLIC API
# ============================================================

func play_hover_sound():
	_hover_player.stream = _generate_tone(880.0, 0.06, 0.15)
	_hover_player.play()


func play_click_sound():
	_click_player.stream = _generate_tone(660.0, 0.1, 0.25)
	_click_player.play()


func play_comparison_sound():
	_compare_player.stream = _generate_tone(440.0, 0.15, 0.2)
	_compare_player.play()


func play_wrong_sound():
	_wrong_player.stream = _generate_tone(220.0, 0.25, 0.3)
	_wrong_player.play()


func play_success_sound():
	# Two ascending tones
	_success_player.stream = _generate_tone(523.0, 0.15, 0.3)
	_success_player.play()
	# Schedule second tone
	var timer = get_tree().create_timer(0.15)
	timer.timeout.connect(func():
		_success_player.stream = _generate_tone(784.0, 0.2, 0.35)
		_success_player.play()
	)


func play_level_complete_sound():
	# Three ascending tones for celebration
	var tones := [523.0, 659.0, 784.0]
	for i in range(tones.size()):
		var timer = get_tree().create_timer(0.2 * i)
		var freq = tones[i]
		timer.timeout.connect(func():
			_level_complete_player.stream = _generate_tone(freq, 0.3, 0.35)
			_level_complete_player.play()
		)


func play_warp_sound():
	# Sweeping sci-fi frequency shift
	var base_freq := 300.0
	for i in range(4):
		var timer = get_tree().create_timer(0.08 * i)
		var freq = base_freq + i * 220.0
		timer.timeout.connect(func():
			_click_player.stream = _generate_tone(freq, 0.12, 0.28)
			_click_player.play()
		)


func play_portal_hover_sound():
	_hover_player.stream = _generate_tone(1046.0, 0.1, 0.18)
	_hover_player.play()

