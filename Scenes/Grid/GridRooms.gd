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
	
	var x:int = minVec.x
	var y:int = minVec.y
	var z:int = minVec.z
	
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
				if Part.type == "reference": # if its a reference like the tail of a slope then it uses the secondary flow of that origin and rotates it to the blocks rotation same for below just without the reference
					current = GlobalBlockManager.blockcatalog[Parts[Part.origin].blockid].flowsSecondary 
				else:
					current = GlobalBlockManager.blockcatalog[Part.blockid].flows
				
				blocklist[pos] = []
				for flow in current: # this will take each block and its flows and rotate them to the angle of the block in the grid
					blocklist[pos].append(flow * Part.position.basis.inverse()) 
			
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
	print("block list")
	for test in blocklist.keys():
		print(test," ",blocklist[test])
	print()
	
	blockroom.clear()
	roomVolumes.clear()
	var tasklist:PackedVector3Array = [] # has positions of blocks that have been found to be connected rooms in it...
	var roomnumber:int = 0
	while(true): # this will actually discover the rooms.
		var pos = Vector3i(x,y,z)
		print("___",Vector3i(x,y,z),"___")
		
		if blocklist[pos] != []: # if x,y,z has flows at all. add it to the tasklist to be ckecked.
			tasklist.append(pos)
			roomnumber += 1 # das problem ist wenn ein block als "surroundings" festgestellt wurde und blockroom auf 0 gesetzt wird, dann ein raum gefunden wird, und dann ein zweiter block der getrennt von den anderen surroundings
			
			print("found room:",roomnumber)
			
		while not tasklist.is_empty(): #if there are blocks of a room known work though them.
			var taskpos:Vector3i = tasklist[tasklist.size()-1] # pop
			tasklist.remove_at(tasklist.size()-1) # pop
			
			print("blocks in que:", tasklist.size())
			
			#if Parts[taskpos].type == "block":
			#	roomVolumes[roomnumber] += 8
			#else:
			#	roomVolumes[roomnumber] += GlobalBlockManager.blockcatalog[Parts[taskpos].blockid].volume
			
			var issuroundings = false
			for dirtemp:Vector3i in blocklist[taskpos]: # this should cycle though the flow directions of the current block. if a block that flows right, is has a block on its right side that flows left then that block should be added to the task list.
				var checkpos:Vector3i = dirtemp+taskpos
				
				if not blocklist.has(checkpos): # replace this with a < or > then for x,y,z to get a massive performace increase
					blockroom.set(taskpos,0)
					print("connected to surroundings",checkpos)
					issuroundings = true
				else:
					print("current block has:",blocklist[checkpos],"vs",dirtemp)
					if blocklist[checkpos].has(-dirtemp):
						print("connected room lol")
						tasklist.append(checkpos)
			blocklist[taskpos] = []
			if not issuroundings:
				blockroom.set(taskpos,roomnumber)
		x += 1 
		if x > maxX:
			x = minX
			y += 1 
		if y > maxY:
			y = minY
			z += 1
		if z > maxZ:
			break	
		
	print("roomnumber:",roomnumber)
	#print("blockroom:",blockroom)
	print("roomvolumes:",roomVolumes)
	print("done")
	
	
	
