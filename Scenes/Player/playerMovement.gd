extends RigidBody3D

var speed := 300000
var mouseSpeed = 0.15
var runMul = 30
var movementDamping = Vector3(50000,300,50000)
var Enginedelta = 0

@onready var Head = $Head


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if is_multiplayer_authority():	
		Enginedelta = delta
		
		var inAir = 1
		var velocity = Vector3(0,0,0)
		
		if Input.is_action_pressed('forward'):
				velocity.z -= speed
		if Input.is_action_pressed('left'):
				velocity.x -= speed
		if Input.is_action_pressed('backward'):
				velocity.z += speed
		if Input.is_action_pressed('right'):
				velocity.x += speed
		if Input.is_action_pressed("run"):
				velocity = velocity * runMul
		if Input.is_action_pressed("jump"):
				velocity.y += 500000
		if Input.is_action_just_pressed("debugg"):
			var range = 4
			for x in range(-range,range):
				for y in range(-range,range):
					GlobalSignals.signalGenereateNewRegion(transform.origin + Vector3(x,0,y)*512)



		$".".set_constant_force(delta*(velocity.rotated(Vector3.UP,$".".rotation.y)*inAir-$".".linear_velocity*movementDamping*inAir)) # this is a dampener
		
		$".".apply_torque_impulse(delta*Vector3(0,-$".".angular_velocity.y*300,0))  #this is dampening for the rotation of the player pill

func _input(event):
	if not Input.is_action_pressed("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event is InputEventMouseMotion:
			Head.rotation_degrees.x = clamp(Head.rotation_degrees.x - event.relative.y * mouseSpeed,-80,90) # this rotates the players head
			$".".apply_torque_impulse(Enginedelta*Vector3(0,-event.relative.x*mouseSpeed*500,0)) # this rotates the playerpill based on mouseinput
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # this is what uncatches the mouse to close the game using alt key for example
