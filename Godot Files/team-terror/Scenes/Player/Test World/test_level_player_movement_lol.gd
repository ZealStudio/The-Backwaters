extends Node3D

@export var BackgroundTest: AudioStreamPlayer
var isMusic = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isMusic!=true:
		isMusic = true
		BackgroundTest.play()
		await(BackgroundTest.finished)
		isMusic=false
		pass
	pass
