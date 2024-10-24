extends Node3D

var opened = false
#Useless export because THEY SUCK aka they do not matter
@export var left_hinge : StaticBody3D
@export var opens : AnimationPlayer 
func _ready() -> void:
	left_hinge.connect("leftopens", open_left)

	pass
func open_left():
	if opened == false:
		opens.play("left_hinge")
		opened = true
		pass
	pass
