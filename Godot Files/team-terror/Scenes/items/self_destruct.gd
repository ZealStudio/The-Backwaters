extends StaticBody3D

@export var body : Node3D 

func self_destruct():
	body.queue_free()
