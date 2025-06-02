extends Node

var Parts: Dictionary = {}

var minVec: Vector3i
var maxVec: Vector3i

var Rooms:Dictionary
var RoomsVol:Array

const halfPI = PI/2

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
	
	var x:int = minVec.x
	var y:int = minVec.y
	var z:int = minVec.z
	
	var maxX = maxVec.x
	var maxY = maxVec.y
	var maxZ = maxVec.z
	
	var minX = minVec.x
	var minY = minVec.y
	var minZ = minVec.z
	
	var absmaxX = maxX - minX
	var absmaxY = maxY - minY
	var absmaxZ = maxZ - minZ
	
	var blocklist:Array # this will save the "state" of each block and it will be the grid for the depth first search: it will step though this list using the same while true shit xyz... then when it found an room block it will disvorder the whole room. each block thats been found to be in this room, will be set to 0 in this list so its ignored in the future.
	var airblock = [Vector3i.BACK,Vector3i.UP,Vector3i.LEFT,Vector3i.RIGHT,Vector3i.FORWARD,Vector3i.DOWN]
	
	while(true):
		var index:int = (x-minX) + ((y-minY)*(absmaxX+1)) + ((z-minZ)*((absmaxX+1)*(absmaxY+1))) # this calcutes the index of the packed array from x,y,z
		var pos = Vector3i(x,y,z)
		if not Parts.has(pos):
			blocklist.insert(index,airblock) # if the block is not occupied its considerd air
		else:
			var Partspos = Parts[pos]
			var current = []
			if Parts[pos].type == "block": #  if its a solid block then it wont flow at all.
				blocklist.insert(index,[])
			else:
				if Parts[pos].type == "reference": # if its a reference like the tail of a slope then it uses the secondary flow of that origin and rotates it to the blocks rotation same for below just without the reference
					current = GlobalBlockManager.blockcatalog[Parts[Partspos.origin].blockid].flowsSecondary 
				else:
					current = GlobalBlockManager.blockcatalog[Partspos.blockid].flows
				var out:Array
				for flow in current: # this will take each block and its flows and rotate them to the angle of the block in the grid
					out.append(flow * Partspos.position.basis) 
				blocklist.insert(index,out)
			
		x += 1 
		if x > maxX:
			x = minX
			y += 1 
		if y > maxY:
			y = minY
			z += 1
		if z > maxZ:
			break	

	x = minVec.x #resetting shit.
	y = minVec.y
	z = minVec.z
	print("\n blocklist prep done:")
	for test in blocklist:
		print(test)
	print()

	# blocklist has index int and each blocks flows in arrays in it. 
	var tasklist:PackedVector3Array = [] # has positions of blocks that have been found to be connected rooms in it...
	while(true): # in this we will actually discover the rooms.
		var index:int = (x-minX) + ((y-minY)*(absmaxX+1)) + ((z-minZ)*((absmaxX+1)*(absmaxY+1))) # this calcutes the index of the packed array from x,y,z
		if blocklist[index] != []: # if x,y,z has flows at all. add it to the tasklist to be ckecked.
			tasklist.append(Vector3i(x,y,z))
			
		var roomtemp:Array = [] # this will have all the rooms blocks positions in it.
		while not tasklist.is_empty(): #if there are blocks of a room known work though them.
			var taskpos:Vector3i = tasklist[tasklist.size()-1] # pop
			tasklist.remove_at(tasklist.size()-1) # pop the last block off the tasklist.
			var indextemp:int = (taskpos.x-minX) + ((taskpos.y-minY)*(absmaxX+1)) + ((taskpos.z-minZ)*((absmaxX+1)*(absmaxY+1))) # get the index for the current block
			roomtemp.append(taskpos) # this also needs to check if this block is at the grids edge because if so, its automatically considerd room 0 which is the surroinding air.
			var isatmosphere = false
			
			for dirtemp:Vector3i in blocklist[indextemp]: # this should cycle though the flow directions of the current block. if a block that flows right, is has a block on its right side that flows left then that block should be added to the task list.
				var checkpos:Vector3i = dirtemp+taskpos
				print(checkpos)
				var checkblockindex = (checkpos.x-minX) + ((checkpos.y-minY)*(absmaxX+1)) + ((checkpos.z-minZ)*((absmaxX+1)*(absmaxY+1)))
				print(checkpos)
				
				#print(checkblockindex)
				print(blocklist) 
				
				
				# GIVING UP TRYING TO DO SPEED
				# all my effort to use arrays and packed arrays (which are too lmited so i threw them out some time ago) just makes me need to use so many workarounds that in the end im unsure if it is even faster
				# im going to retry with dictonary
				
				if blocklist:
					var checkblocksflows = blocklist[checkblockindex]
					print("block in grid")
					
				
				
			# i remember having had a good idea about how to make room detection way simpler but i cant remember :( ... *5 minutes later* I REMEMBER NOW...
			# instead of having nested lists with rooms and blocks rooms. I just have a list with all blocks positions and their assosiated room number instead.
			# rooms[vec(1,1,1)] = r1 for example... that makes a lot of things way easier.
			
		x += 1 
		if x > maxX:
			x = minX
			y += 1 
		if y > maxY:
			y = minY
			z += 1
		if z > maxZ:
			break	
		
		#$"../MeshInstance3D".transform.origin = Vector3(x,y,z)/5 # place debugging ghost
