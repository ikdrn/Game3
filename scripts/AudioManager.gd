extends Node

var _player := AudioStreamPlayer.new()
var _stream := AudioStreamGenerator.new()
var _playback: AudioStreamGeneratorPlayback

const SAMPLE_RATE := 44100.0
const TAU := PI * 2.0

func _ready() -> void:
	_stream.mix_rate = SAMPLE_RATE
	_stream.buffer_length = 0.4
	_player.stream = _stream
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback()

func play_gunshot(profile: String) -> void:
	if _playback == null:
		return
	var duration := 0.12
	var decay := 40.0
	var base_freq := 180.0
	match profile:
		"AR":
			duration = 0.12
			decay = 40.0
			base_freq = 190.0
		"Pistol":
			duration = 0.15
			decay = 35.0
			base_freq = 170.0
		"Shotgun":
			duration = 0.25
			decay = 20.0
			base_freq = 130.0
		"Sniper":
			duration = 0.35
			decay = 15.0
			base_freq = 90.0
	_generate_shot(duration, decay, base_freq)

func _generate_shot(duration: float, decay: float, base_freq: float) -> void:
	var frames := int(duration * SAMPLE_RATE)
	for i in frames:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * decay)
		var noise := randf_range(-1.0, 1.0)
		var tone_a := sin(TAU * base_freq * t)
		var tone_b := sin(TAU * base_freq * 2.4 * t)
		var tone_c := sin(TAU * base_freq * 4.7 * t)
		var sample := (noise * 0.65 + tone_a * 0.2 + tone_b * 0.1 + tone_c * 0.05) * env * 0.6
		_playback.push_frame(Vector2(sample, sample))
