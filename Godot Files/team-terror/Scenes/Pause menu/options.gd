extends Button

@export var MasterOptions : Control
@export var PauseMenu : Control
func _ready() -> void:
	MasterOptions.hide()
	pass


func _on_pressed() -> void:
	PauseMenu.hide()
	MasterOptions.show()

	
