extends Node2D

@onready var camera: Camera2D = $Camera2D

var amplitude: float = 0.02
var speed: float = 1.0
var time: float = 0.0

func _process(delta):
	time += delta

	var offset = sin(time * speed) * amplitude
	camera.rotation = offset
