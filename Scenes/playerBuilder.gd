extends Node3D

var currentItemID = 0
@onready var raycast: RayCast3D = $Builder
@onready var ghost = $Ghost
# Called when the node enters the scene tree for the first time.

var blockSize:Vector3 = Vector3(1,1,1)
var blockidchanged:bool = true

var RotationVector:Basis
var halfPI = PI/2 # this is 90° in rads

const gridSize = Vector3(0.2,0.2,0.2)

var ghostmaterial:StandardMaterial3D = load(GlobalBlockManager.blockcatalog[currentItemID].material).duplicate()

func _ready() -> void:
	ghostmaterial.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pass
	
func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		# Handle item switching
		if Input.is_action_just_pressed("next_item") and currentItemID + 1 < GlobalBlockManager.blockcatalog.size():
			currentItemID += 1
			blockidchanged = true
		
		if Input.is_action_just_pressed("previous_item") and currentItemID > 0:
			currentItemID -= 1
			blockidchanged = true
		
		if Input.is_action_just_pressed("pitch_forward"):
			RotationVector = RotationVector.rotated(Vector3.FORWARD,halfPI)
		if Input.is_action_just_pressed("pitch_backwards"):
			RotationVector = RotationVector.rotated(Vector3.FORWARD,-halfPI)
		if Input.is_action_just_pressed("roll_left"):
			RotationVector = RotationVector.rotated(Vector3.LEFT,halfPI)
		if Input.is_action_just_pressed("roll_right"):
			RotationVector = RotationVector.rotated(Vector3.LEFT,-halfPI)
		if Input.is_action_just_pressed("yaw_left"):
			RotationVector = RotationVector.rotated(Vector3.UP,halfPI)
		if Input.is_action_just_pressed("yaw_right"):
			RotationVector = RotationVector.rotated(Vector3.UP,-halfPI)
		
			
			
		if blockidchanged:
			ghost.mesh = load(GlobalBlockManager.blockcatalog[currentItemID].mesh)
			ghostmaterial.albedo_color = GlobalBlockManager.blockcatalog[currentItemID].color * Color(1,1,1,0.5)
			ghost.material_override = ghostmaterial
			
			blockSize = GlobalBlockManager.blockcatalog[currentItemID].size
			blockidchanged = false
		
		$Control/Label.text = str(currentItemID) + " " + GlobalBlockManager.blockcatalog[currentItemID].showName
		
		##
		
		if Input.is_action_just_pressed("spawn_grid"):
			var pos = global_transform.origin + global_transform.basis.z * -2
			GlobalSignals.triggernewGridRequested(name.to_int(),pos)
		
		if raycast.is_colliding() and is_multiplayer_authority(): #
			ghost.visible = true
			var hit_object = raycast.get_collider()
			if hit_object:
				var hitpoint = raycast.get_collision_point()
				var hitNormal = raycast.get_collision_normal()
				
				var globalBlockPos = get_global_block_pos(hit_object,hitpoint,hitNormal,blockSize,RotationVector)
				ghost.global_transform = globalBlockPos
				
				if Input.is_action_just_pressed("mouse1"):
					var localBlockPos = get_local_block_pos(hit_object,hitpoint,hitNormal,blockSize,RotationVector)
					GlobalSignals.triggerBlockplacementRequested(hit_object.name,$"../..".name.to_int(),localBlockPos,currentItemID)
				
				if Input.is_action_just_pressed("mouse2"):
					var lookedatblockPos = get_local_looked_at(hit_object,hitpoint,hitNormal,RotationVector)
					GlobalSignals.triggerBlockremoveRequested(hit_object.name,$"../..".name.to_int(),lookedatblockPos)
		
		else:
			ghost.visible = false





# Pain.  Credit for the affine_inverse: https://www.reddit.com/r/godot/comments/17ki0r2/comment/k77use9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
# Pain 2. that was me who solved it. making it account for different sizes of blocks was a real mind breaker ... mostly emotioanlly ... the amount of chagnes i could make while still getting the same result is really incredible
func get_global_block_pos(ref_object:Node3D,hitpos:Vector3,hitnormal:Vector3,size:Vector3,angle:Basis) -> Transform3D: 
	var blocksize = size.rotated(angle.x,halfPI).abs().snapped(gridSize)
	var dist = abs((blocksize.rotated(hitnormal,halfPI)).x)
	var localpos = (ref_object.global_transform.inverse() *  (hitpos + hitnormal * dist/2)).snapped(gridSize)
	
	return Transform3D(ref_object.transform.basis*angle,ref_object.to_global(localpos))

func get_local_block_pos(ref_object:Node3D,hitpos:Vector3,hitnormal:Vector3,size:Vector3,angle:Basis) -> Transform3D: 
	var blocksize = size.rotated(angle.x,halfPI).abs().snapped(gridSize)
	var dist = abs((blocksize.rotated(hitnormal,halfPI)).x)
	var localpos = (ref_object.global_transform.inverse() *  (hitpos + hitnormal * dist/2)).snapped(gridSize)
	return Transform3D(angle,localpos)

func get_local_looked_at(ref_object:Node3D,hitpos:Vector3,hitnormal:Vector3,angle:Basis) -> Transform3D: 
	var localpos = (ref_object.global_transform.affine_inverse() * (hitpos + hitnormal*-0.01)).snapped(gridSize)
	return Transform3D(ref_object.transform.basis*angle,localpos)
