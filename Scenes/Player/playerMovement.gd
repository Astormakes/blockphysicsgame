extends RigidBody3D

var speed := 1
var mouseSpeed = 0.15
var runMul = 10
var movementDamping = Vector3(50000,300,50000)
var Enginedelta = 0

var noclip = true

@onready var Head = $Head


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if is_multiplayer_authority():	
		Enginedelta = delta
		
		if Input.is_action_just_pressed("noclip"):
			noclip = not noclip
			freeze = noclip
		var inAir = 1
		var velocity:Vector3 = Vector3(0,0,0)
		
		if Input.is_action_pressed('forward'):
				velocity.z = -speed
		if Input.is_action_pressed('left'):
				velocity.x = -speed
		if Input.is_action_pressed('backward'):
				velocity.z = speed
		if Input.is_action_pressed('right'):
				velocity.x = speed
		if Input.is_action_pressed("run"):
				velocity = velocity * runMul
		if Input.is_action_pressed("jump"):
				velocity.y = 5
		if Input.is_action_pressed("crouch"):
				velocity.y = -5
		
	
		if noclip:
			transform.origin += Head.basis * velocity
		else:
			var head_rotation = Head.global_transform.basis.get_euler()
			var yaw_only_basis = Basis(Vector3.UP, head_rotation.y)  # Only yaw
			apply_central_force(yaw_only_basis * velocity*300)

func _input(event):
	if not Input.is_action_pressed("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event is InputEventMouseMotion:
			Head.rotation_degrees.x = clamp(Head.rotation_degrees.x - event.relative.y * mouseSpeed,-89,89) # this rotates the players head
			Head.rotation_degrees.y = Head.rotation_degrees.y - event.relative.x * mouseSpeed # this rotates the players head
			
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # this is what uncatches the mouse to close the game using alt key for example
