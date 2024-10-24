extends CharacterBody3D
#pause my menu idiot
@export var PauseMenu: Control
var paused = false

#SFX
@export var Walk: AudioStreamPlayer
@export var Run: AudioStreamPlayer
#I didn't finish this oops
const JUMP_VELOCITY = 4.5
#Speed and camera sensitivity vars
@export var sensitivity_camera = .001
@export var player_speed = 2.5
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
#Stamina check
@onready var stamina=100
@onready var max_stamina=200
@onready var isSprint= false
@onready var isTired= false
@onready var isSound= false
#Camera effects color might not be used im sorry :(
@export var camera_fov =50
@export var camera_color = 0
#Flashlight stuff, first exporting AND THEN KILLING
@onready var hand :=$Hand
@onready var flashlight :=$Hand/Flashlight
@onready var isFlashlighting= true
@onready var flashBright = 3.5
@onready var flashlight_timer := $Hand/Flashlight/Flashlight_Battery 
@onready var isFlashingdead = false
@onready var flicker = false

#Interactable distance from the player for doors and getting keys or whatever
@export var interactable : RayCast3D

#Do you have a key on spawn? no so die.
var gotKey = false
#Animation vars including another fucking boolean because it will play over itself
@export var headBobbing : AnimationPlayer
var isAnimating = false

func _ready() -> void:
	flashlight_timer.start()
	pass

#literally the camera function

func _unhandled_input(event: InputEvent) -> void:
	#clamps values, for some reason it works better here so lets call it magic
	stamina = clamp(stamina,0,max_stamina)

	if get_tree().paused==false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*sensitivity_camera)
			camera.rotate_x(-event.relative.y*sensitivity_camera)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(70))
		
		#flashlight rotate moment
			flashlight.rotate_y(-event.relative.x*sensitivity_camera)
			flashlight.rotation.x=camera.rotation.x
	if get_tree().paused==true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pass
#die
func _die():
	#Go to game over screen
	pass

#literally the everything function
func _physics_process(delta: float) -> void:
	
	if flashlight_timer.get_time_left()<20:
		flashBright = randf_range(0,.7)
		pass
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#Plays the head bobbing animation while a direction is being played, it should be easy to
		#edit within the animation tab so LOL
		if isSprint ==false:
			if isAnimating == false:
				isAnimating = true
				headBobbing.play("player_walk_headbob")
				await(headBobbing.animation_finished)
				isAnimating =false
		if isSprint == true:
			if isAnimating == false:
				isAnimating = true
				headBobbing.play("player_run_headbob")
				await(headBobbing.animation_finished)
				isAnimating =false
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)
	camera.fov=lerp(camera.fov,float(camera_fov),.1)
	#Sprint
	if direction and isSprint==true and isTired!=true:
		stamina -= 2
	else:
		if stamina < 200:
			stamina +=1
	if stamina <10:
		isTired=true
	elif stamina>180:
		isTired=false
	move_and_slide()

func get_key():
	gotKey = true
	pass

#input testing but we need to get rid of test inputs in the final build
func _input(event: InputEvent) -> void:
	#increase fov test and decrease
	if Input.is_action_pressed("test_inp_1"):
		camera_fov +=10
	if Input.is_action_pressed("test_inp_2"):
		camera_fov -=10
	#exits the game so you don't click on x or whatever
	if Input.is_action_just_pressed("exit_test"):
		get_tree().quit()
	#Zoom
	if Input.is_action_just_pressed('right_click'):
		camera_fov = 25
	if Input.is_action_just_released('right_click'):
		camera_fov = 50
	#Sprint
	if Input.is_action_pressed("sprint") and isTired==false:
		player_speed = 6
		isSprint=true
	elif isTired==true: 
		player_speed = 2.5
		isSprint=false
	if Input.is_action_just_released("sprint"):
		isSprint = false
		player_speed = 2.5
		pass
	#checks if the light is on and how much energy it should have
	if Input.is_action_just_pressed("left_click"):
		if isFlashlighting == true and isFlashingdead==false:
			isFlashlighting = false
			flashlight_timer.set_paused(true)
		elif isFlashlighting == false and isFlashingdead ==false:
			isFlashlighting = true
			flashlight_timer.set_paused(false)
	if isFlashlighting == true:
		flashlight.light_energy = flashBright
	else:
		flashlight.light_energy = 0
	#walking sound DELETE ASAP
	if velocity.x!=0 and velocity.z!=0 and isSound != true and is_on_floor():
		isSound = true
		Walk.play()
		await(Walk.finished)
		isSound=false
		pass
	#Warp DELETE LATER
	if Input.is_action_just_pressed("test3"):
		SceneTransition.scene_transition_cloud("res://Player/Test World/test_level_player_movement_lol.tscn")
	pass
	#fire it out smartass
	#This is a mess... It's all the item interactables and we're looking for the static body 3d's that we can take.
	#Why did I do it like this? Because collider != null wasn't working. yeah. What the fuck man
	if Input.is_action_just_pressed("interaction"):
		#collider object gets the object so we can pull their function so like collider.die()
		var collider= interactable.get_collider()
		if collider is StaticBody3D:
			#Door transition stuff, for in between areas.
			if collider.is_in_group("door_transition"):
				collider.interact()
			#Door opening when in the main level using a mess of area3d
			if collider.is_in_group("left_side_hinge"):
				collider.left_open()
			if collider.is_in_group("right_side_hinge"):
				collider.right_open()
			#Getting your keys, don't forget them next time, plays text also to be more clear
			if collider.is_in_group("key1"):
				get_key();
				collider.self_destruct()
				TextOverlay.Get_Key_Area_1()
			#Can't open a locked door unless gotKey = true
			if collider.is_in_group("locked_door"):
				if gotKey == true:
					collider.left_open()
				else:
					TextOverlay.Door_Locked()
	#these functions will handle pause for now but I THINK this is the neatest it can look rn
	if Input.is_action_just_pressed("pause"):
		Pause()
#Pause, completely pauses everything so you can go into options
func Pause():
	if get_tree().paused == false:
		PauseMenu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		Engine.time_scale = 0

	#else:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#PauseMenu.hide()
		#get_tree().paused = false
		#Engine.time_scale = 1
