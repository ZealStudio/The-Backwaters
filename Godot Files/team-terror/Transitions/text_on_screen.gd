extends CanvasLayer
var textplaying = false
@export var text_play : AnimationPlayer
#Get key text so you can know wadda hell is doing on
func Get_Key_Area_1():
	if textplaying == false:
		textplaying=true
		text_play.play("key_text")
		await(text_play.animation_finished)
		text_play.play("key_fade_out")
		textplaying = false
#Door locked so you know it's locked
func Door_Locked():
	if textplaying ==false:
		textplaying = true
		text_play.play("door_locked_text")
		await(text_play.animation_finished)
		text_play.play("door_text_fade_out")
		textplaying = false
	
