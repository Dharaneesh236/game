extends Node

# Procedural Audio Synthesizer for RoboVerse
# Synthesizes clean sci-fi SFX and ambient audio at runtime using AudioStreamWAV

var sfx_pool: Array[AudioStreamPlayer] = []
var ambient_player: AudioStreamPlayer
var pool_size := 8
var current_sfx_idx := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create audio pool for simultaneous SFX playback
	for i in range(pool_size):
		var asp = AudioStreamPlayer.new()
		asp.bus = "Master"
		add_child(asp)
		sfx_pool.append(asp)

	# Ambient background hum
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	ambient_player.volume_db = -18.0
	add_child(ambient_player)
	start_ambient_drone()

func _get_free_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	# If all are busy, cycle through
	current_sfx_idx = (current_sfx_idx + 1) % pool_size
	return sfx_pool[current_sfx_idx]

func _generate_wav(samples: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = samples
	return wav

func play_ui_click(pitch: float = 1.0) -> void:
	var rate = 22050
	var dur = 0.04
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = 1.0 - (float(i) / count)
		var s = sin(TAU * 880.0 * pitch * t) * env * 0.4
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -8.0
	p.play()

func play_footstep() -> void:
	var rate = 22050
	var dur = 0.08
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = pow(1.0 - (float(i) / count), 2.0)
		var noise = (randf() * 2.0 - 1.0) * 0.25
		var low = sin(TAU * 90.0 * t) * 0.75
		var s = (noise + low) * env * 0.35
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -14.0
	p.play()

func play_spark() -> void:
	var rate = 22050
	var dur = 0.15
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var env = pow(1.0 - (float(i) / count), 1.5)
		var noise = (randf() * 2.0 - 1.0)
		if randf() > 0.3:
			noise *= 1.5
		var s = noise * env * 0.5
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -6.0
	p.play()

func play_robot_chirp(freq: float = 600.0) -> void:
	var rate = 22050
	var dur = 0.22
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var f = freq + sin(TAU * 18.0 * t) * 120.0
		var env = sin(PI * (float(i) / count))
		var s = sin(TAU * f * t) * env * 0.4
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -6.0
	p.play()

func play_repair_success() -> void:
	# Rising 4-note sci-fi fanfare: C5, E5, G5, C6
	var notes = [523.25, 659.25, 783.99, 1046.50]
	var rate = 22050
	var note_dur = 0.12
	var count = int(rate * note_dur * notes.size())
	var data = PackedByteArray()
	data.resize(count * 2)
	for n_idx in range(notes.size()):
		var f = notes[n_idx]
		var start_sample = int(n_idx * rate * note_dur)
		var samples_in_note = int(rate * note_dur)
		for i in range(samples_in_note):
			var idx = start_sample + i
			var t = float(i) / rate
			var env = pow(1.0 - (float(i) / samples_in_note), 1.2)
			var s = (sin(TAU * f * t) + 0.3 * sin(TAU * f * 2.0 * t)) * env * 0.45
			var sample_val = int(clamp(s * 32767.0, -32768, 32767))
			data.encode_s16(idx * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -4.0
	p.play()

func play_gate() -> void:
	var rate = 22050
	var dur = 1.0
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = sin(PI * (float(i) / count))
		var f = 80.0 + (t / dur) * 160.0
		var hum = sin(TAU * f * t) * 0.4
		var friction = (randf() * 2.0 - 1.0) * 0.15
		var s = (hum + friction) * env * 0.5
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -5.0
	p.play()

func play_hazard_zap() -> void:
	var rate = 22050
	var dur = 0.25
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var buzz = sin(TAU * 120.0 * t) * 0.4
		var crackle = (randf() * 2.0 - 1.0) * 0.5
		var env = 1.0 - (float(i) / count)
		var s = (buzz + crackle) * env * 0.5
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -4.0
	p.play()

func play_beam_activation() -> void:
	var rate = 22050
	var dur = 2.5
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var prog = t / dur
		var f = 60.0 + prog * 800.0
		var env = min(prog * 2.0, 1.0) * (1.0 - prog * 0.2)
		var harmonic = sin(TAU * f * t) * 0.5 + sin(TAU * (f * 1.5) * t) * 0.25
		var s = harmonic * env * 0.6
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -2.0
	p.play()

func start_ambient_drone() -> void:
	var rate = 22050
	var dur = 4.0
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		# Seamless loopable low sci-fi drone
		var s1 = sin(TAU * 55.0 * t) * 0.4
		var s2 = sin(TAU * 82.4 * t) * 0.25
		var s3 = sin(TAU * 110.0 * t) * 0.15
		var s = (s1 + s2 + s3) * 0.4
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = count
	ambient_player.stream = wav
	ambient_player.play()

func play_airlock_denied() -> void:
	var rate = 22050
	var dur = 0.35
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = pow(1.0 - (float(i) / count), 1.2)
		# Dual harsh square/buzz tone
		var f1 = 130.0
		var f2 = 85.0
		var s1 = 0.4 if sin(TAU * f1 * t) > 0.0 else -0.4
		var s2 = 0.3 if sin(TAU * f2 * t) > 0.0 else -0.3
		var s = (s1 + s2) * env * 0.6
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -4.0
	p.play()

func play_airlock_unlocked() -> void:
	var rate = 22050
	var dur = 0.8
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = sin(PI * (float(i) / count))
		# High-tech chime followed by pressurized hydraulic whoosh
		var chime = sin(TAU * (587.33 + t * 400.0) * t) * 0.35
		var hiss = (randf() * 2.0 - 1.0) * 0.25 * (t / dur)
		var s = (chime + hiss) * env * 0.6
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -5.0
	p.play()

func play_elemental_beam(beam_idx: int) -> void:
	var freqs = [440.0, 554.37, 659.25, 783.99] # Solar, Logic, Decryption, Kinetic
	var base_f = freqs[beam_idx % freqs.size()]
	var rate = 22050
	var dur = 0.75
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var env = pow(sin(PI * (float(i) / count)), 0.8)
		var f = base_f + sin(TAU * 12.0 * t) * 35.0
		var harm = sin(TAU * f * t) * 0.5 + sin(TAU * (f * 2.0) * t) * 0.25
		var s = harm * env * 0.55
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -3.0
	p.play()

func play_overcharge_rumble() -> void:
	var rate = 22050
	var dur = 2.2
	var count = int(rate * dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t = float(i) / rate
		var prog = t / dur
		var f = 45.0 + prog * 180.0
		var rumble = sin(TAU * f * t) * 0.6 + sin(TAU * (f * 0.5) * t) * 0.3
		var crackle = (randf() * 2.0 - 1.0) * prog * 0.35
		var env = min(prog * 3.0, 1.0) * (1.0 - prog * 0.1)
		var s = (rumble + crackle) * env * 0.65
		var sample_val = int(clamp(s * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -2.0
	p.play()

func play_grand_fanfare() -> void:
	# Epic triumphal sci-fi victory chord fanfare: C4, G4, C5, E5, G5, C6 in majestic progression
	var chords = [
		[261.63, 329.63, 392.00],        # C Major
		[349.23, 440.00, 523.25],        # F Major
		[392.00, 493.88, 587.33],        # G Major
		[523.25, 659.25, 783.99, 1046.5] # Epic High C Crescendo
	]
	var rate = 22050
	var chord_dur = 0.38
	var total_dur = chord_dur * chords.size()
	var count = int(rate * total_dur)
	var data = PackedByteArray()
	data.resize(count * 2)
	for c_idx in range(chords.size()):
		var chord = chords[c_idx]
		var start_sample = int(c_idx * rate * chord_dur)
		var samples_in_chord = int(rate * chord_dur)
		for i in range(samples_in_chord):
			var idx = start_sample + i
			var t = float(i) / rate
			var env = pow(1.0 - (float(i) / samples_in_chord), 0.9)
			var sum = 0.0
			for f in chord:
				sum += sin(TAU * f * t) * 0.22 + sin(TAU * f * 2.0 * t) * 0.08
			var s = sum * env * 0.6
			var sample_val = int(clamp(s * 32767.0, -32768, 32767))
			data.encode_s16(idx * 2, sample_val)
	var wav = _generate_wav(data, rate)
	var p = _get_free_player()
	p.stream = wav
	p.volume_db = -1.0
	p.play()

