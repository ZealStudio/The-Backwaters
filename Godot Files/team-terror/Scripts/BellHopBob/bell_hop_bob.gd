extends CharacterBody3D


const SPEED = 1.0

var player = null
@export var playerNode : CharacterBody3D
@export var nav_agent : NavigationAgent3D
@export var seenTimer : Timer
@export var stalkingTimer : Timer
@export var wanderTimer : Timer
@export var idleTimer : Timer
@export var sight : RayCast3D

@onready var testingTimer = $"Testing Timer"
var seen : bool
var idleTimerStarted : bool
var randomPos

#States
enum ENTITY_STATE{
	IDLE,
	CHASE,
	STALKING,
	WANDERING
}
@export var entity_state = ENTITY_STATE.IDLE


func _ready():
	randomPos = setRandomPos()
func _process(delta):
	#reset velocity
	velocity = Vector3.ZERO
	#If player is seen
	if sight.get_collider() == playerNode:
		seen = true
	else:
		seen = false
	#Change state
	if seen == true:
		entity_state = 1
	#States
	match entity_state:
		0: #Idle
			#Stop moving for a little
			if idleTimerStarted == false:
				idleTimer.start()
				idleTimerStarted = true
			#Switch to wander on idle timeout
			
			pass
		1: #Chase - When seen/Heard
			#Get players location
			setTarget(playerNode.global_transform.origin)
			#move to location
			look_at(playerNode.global_transform.origin)
			moveTo()
			#If player is out of los
			if seen == false:
				seenTimer.start()
				#Wander
			
			
		2: #Stalking - Get closer to player
			#Get Players Pos
			setTarget(playerNode.global_transform.origin)
			#Move To
			look_at(playerNode.global_transform.origin)
			moveTo()
			#Start Timer
			stalkingTimer.start()
			
		3: #Wandering
			#Find random Pos
			if(abs(randomPos.x - global_position.x) <= 10 and abs(randomPos.z - global_position.z) <= 10) or wanderTimer.time_left <=0:
				randomPos = setRandomPos()
				wanderTimer.wait_time = 60.0
				wanderTimer.start()
			#set Target
			setTarget(randomPos)
			#Move to
			moveTo()
			look_at(global_transform.origin + velocity)
			#on target Reached reset or on timeout

	move_and_slide()

#Functions
func lookAt(target):
	self.rotate_y(1)

func setTarget(target):
	nav_agent.set_target_position(target)

func moveTo():
	var next_nav_point = nav_agent.get_next_path_position()
	var Newvelocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	set_velocity(Newvelocity)

func setRandomPos():
	var pos = Vector3(randf_range(playerNode.global_position.x-40, playerNode.global_position.x+40), position.y,
		 		randf_range(playerNode.global_position.z-40, playerNode.global_position.z+40))
	print_debug(pos)
	return pos

#timers
func _on_idle_timer_timeout() -> void:
	#switch to wander
	print_debug("Idle Timeout")
	entity_state = 3
	idleTimerStarted = false

func _on_seen_timer_timeout() -> void:
	#switch to wander
	entity_state = 3

func _on_stalking_timer_timeout() -> void:
	#Swtich to wander
	entity_state = 3

func _on_wander_timer_timeout() -> void:
	#Swtich to idle
	entity_state = 0

#testing stuff
func _on_testing_timer_timeout() -> void:
	if entity_state == 0:
		print_debug("idle")
	elif entity_state == 1:
		print_debug("Chase")
	elif entity_state == 2:
		print_debug("Stalking")
	elif entity_state == 3:
		print_debug("wandering")
	#print(idleTimer.time_left)
	print_debug(nav_agent.distance_to_target())

'
func look_at(target):
	pass

func chase():
	look_at(player.position)
	nav_agent.target_position = player.global_position

func wandering():
	look_at(global_transform.origin + velocity)
	hasSeen = false
	nav_agent.target_position = randomPos
	if(abs(randomPos.x - global_position.x) <= 5 and abs(randomPos.z - global_position.z) <= 5) or wanderTimer <=0:
		randomPos = Vector3(randf_range(player.global_position.x-40, player.global_position.x+40), position.y,
		 randf_range(player.global_position.z-40, player.global_position.z+40))
		wanderTimer = 60.0
'
