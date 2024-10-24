extends Button

@export var PauseMenu : Control

func _on_pressed() -> void:
	PauseMenu.hide()
	get_tree().paused = false
	Engine.time_scale = 1
