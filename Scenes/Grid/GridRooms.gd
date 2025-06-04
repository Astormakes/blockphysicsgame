extends Node

var Parts: Dictionary = {}

var minVec: Vector3i
var maxVec: Vector3i

const halfPI = PI/2

var blockroom:Dictionary
var roomVolumes:Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gridscene = get_node("..")
	gridscene.connect("parts_updated", Parts_update)

func Parts_update(Send: Dictionary) -> void:
	minVec = Vector3(999, 999, 999)  # Start with a high min value
	maxVec = Vector3(-999, -999, -999)  # Start with a low max value
	Parts = Send.duplicate()
	for pos in Parts.keys():
		minVec = minVec.min(pos)
		maxVec = maxVec.max(pos)
		
	run_rooms()


#func _process(delta: float) -> void:
		
	#if Input.is_action_just_pressed("debugg"):
	#	run_rooms()

func run_rooms():
	
	var x:int = minVec.x-1
	var y:int = minVec.y-1
	var z:int = minVec.z-1
	
	var maxX = maxVec.x
	var maxY = maxVec.y
	var maxZ = maxVec.z
	
	var minX = minVec.x
	var minY = minVec.y
	var minZ = minVec.z
	
	
	var blocklist:Dictionary # this will save the "state" of each block and it will be the grid for the depth first search: it will step though this list using the same while true shit xyz... then when it found an room block it will disvorder the whole room. each block thats been found to be in this room, will be set to 0 in this list so its ignored in the future.
	var airblock = [Vector3i.BACK,Vector3i.UP,Vector3i.LEFT,Vector3i.RIGHT,Vector3i.FORWARD,Vector3i.DOWN]
	
	while(true):
		var pos = Vector3i(x,y,z)
		if not Parts.has(pos):
			blocklist[pos] = airblock # if the block is not occupied its considerd air
		else:
			var Part = Parts[pos]
			var current = []
			if Part.type == "block": #  if its a solid block then it wont flow at all. add empty flowarray to blocklist  and go to next block
				blocklist[pos] = []
			else:
				if Part.type == "reference": # if its a reference, like the tail of a slope, then it uses the secondary flow of that origin and rotates it to the blocks rotation same for below just without the reference
					current = GlobalBlockManager.blockcatalog[Parts[Part.origin].blockid].flowsSecondary 
				else:
					current = GlobalBlockManager.blockcatalog[Part.blockid].flows
				
				blocklist[pos] = []
				for flow in current: # this will take each block and its flows and rotate them to the angle of the block in the grid
					blocklist[pos].append(flow * Part.position.basis.inverse()) 
			
		x += 1 
		if x > maxX+1:
			x = minX-1
			y += 1 
		if y > maxY+1:
			y = minY-1
			z += 1
		if z > maxZ+1:
			break	

	x = minVec.x-1 #resetting shit.
	y = minVec.y-1
	z = minVec.z-1
	#print("block list")
	#for test in blocklist.keys():
#		print(test," ",blocklist[test])
	#print()
	
	#print("parts",Parts)
	
	blockroom.clear()
	roomVolumes.clear()
	var tasklist:PackedVector3Array = [] # has positions of blocks that have been found to be connected rooms in it...
	var roomnumber = 0
	while(true): # this will actually discover the rooms.
		var pos = Vector3i(x,y,z)
		
		#for test in blocklist.keys():
		#	print(test," ",blocklist[test])
		#print()
		
		# new room discoverd
		if blocklist[pos] != []: # if x,y,z has flows at all. add it to the tasklist to be ckecked.
			#print("new room:",pos)
			tasklist.append(pos)
			roomVolumes.append(0)
			roomnumber = roomVolumes.size()-1
			
		#print("roomnumber:",roomnumber)
		#print("___",Vector3i(x,y,z),"___")
			
			
		while not tasklist.is_empty(): #if there are blocks of a room known work though them.
			var taskpos:Vector3i = tasklist[tasklist.size()-1] # pop
			tasklist.remove_at(tasklist.size()-1) # pop
			
			blockroom.set(taskpos,roomnumber)
			
			if Parts.keys().has(taskpos):
				roomVolumes[roomnumber] += GlobalBlockManager.blockcatalog[Parts[taskpos].blockid].volume
			else:
				#print("Volume Airblock")
				roomVolumes[roomnumber] += 8
			
			# this should cycle though the flow directions of the current block. if a block that flows right, is has a block on its right side that flows left then that block should be added to the tasklist as its connected .
			for dirtemp:Vector3i in blocklist[taskpos]: 
				var checkpos:Vector3i = dirtemp+taskpos
				if (checkpos.x < minX-1 or checkpos.x > maxX+1 or
					checkpos.y < minY-1 or checkpos.y > maxY+1 or
					checkpos.z < minZ-1 or checkpos.z > maxZ+1):
						continue
						#print("ouf of bounds")
				else:
					#print("current block has:",blocklist[checkpos],"vs",dirtemp)
					if blocklist[checkpos].has(-dirtemp):
						tasklist.append(checkpos)
			
			blocklist[taskpos] = []
			
		x += 1 
		if x > maxX+1:
			x = minX-1
			y += 1 
		if y > maxY+1:
			y = minY-1
			z += 1
		if z > maxZ+1:
			break	
		

	
	print("blockroom:",blockroom)
	print("roomvolumes:",roomVolumes)	
	print("done")
	print()
