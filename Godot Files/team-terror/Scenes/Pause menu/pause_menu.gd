extends Control
#We have two control nodes and do it like this so when you back out of options you can go to quit or 
#resume the game, pretty neat
@export var menu: Control
@export var options: Control

func _ready() -> void:
	menu.show()
	options.hide()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		menu.show()
		options.hide()

func _on_Resume_button_pressed():
	get_tree().paused=false
	hide()
	pass
func _on_Options_button_pressed():
	#go to options
	pass
func _on_Quit_button_pressed():
	get_tree().quit
	pass
