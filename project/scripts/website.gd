extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var player: AnimationPlayer = $AnimationPlayer
@onready var bloom: ColorRect = $Effects/Bloom

var last_beat: int = -1

var bloom_tween: Tween

func _ready() -> void:
	player.play("RESET")

func _process(_delta: float) -> void:
	if !music.playing:
		return
		
	var stream = music.stream
	if stream == null or stream.bpm <= 0.0:
		return
	
	var beat_length: float = 60.0 / stream.bpm
	var beat = floori(music.get_playback_position() / beat_length)
	
	if beat != last_beat:
		last_beat = beat
		
		if beat % 2 == 0:
			pulse_bloom()

func pulse_bloom() -> void:
	var shader_material: ShaderMaterial = bloom.material
	if shader_material == null:
		return

	if bloom_tween:
		bloom_tween.kill()

	shader_material.set_shader_parameter("bloom_intensity", 0.5)

	bloom_tween = create_tween()
	bloom_tween.tween_method(
		func(value: float):
			shader_material.set_shader_parameter("bloom_intensity", value),
		0.1,
		0.0,
		0.5
	)

func _on_dialogue_finished() -> void:
	last_beat = -1
	
	music.play()
	player.play("intro")
