extends Node

var Parts: Dictionary = {}
var Positions: Array

var minVec: Vector3
var maxVec: Vector3

var directions: Array = [Vector3i.LEFT, Vector3i.DOWN, Vector3i.FORWARD]

var rooms: Array = []

var x: float
var y: float
var z: float

var checkspeed = 1000
var work: bool = false

var found

var volumes:Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gridscene = get_node("..")
	gridscene.connect("parts_updated", Parts_update)

func Parts_update(Send: Dictionary) -> void:
	minVec = Vector3(9999, 9999, 9999)  # Start with a high min value
	maxVec = Vector3(-9999, -9999, -9999)  # Start with a low max value
	Parts = Send
	Positions = Parts.keys()
	
	for pos in Positions:
		minVec = minVec.min(pos)
		maxVec = maxVec.max(pos)
	
	x = minVec.x - 1
	y = minVec.y - 1
	z = minVec.z - 1  # You can adjust this offset if necessary
	
	work = true
	rooms.clear()
	volumes.clear()

func _process(delta: float) -> void:
		
	if Input.is_action_just_pressed("debugg"):
		run_rooms()

func run_rooms():
	if work:
		for l in range(1):
			var pos: Vector3i = Vector3(x, y, z)
			$"../MeshInstance3D".transform.origin = Vector3(pos)/5
			
			if Positions.has(pos):  # Check if the position is occupied
				print("--occupied")
				if(Parts[pos].type == "shape" or Parts[pos].type == "reference"):
					var blockPos = pos
					var blockvolume
					var BlockID
					var flows
					var angle
					if Parts[pos].type == "reference":
						blockPos = Parts[pos].origin
						blockvolume = 0
						BlockID = Parts[blockPos].BlockId
						flows = (GlobalBlockManager.blockcatalog[BlockID].flows)
						angle = Parts[blockPos].position.basis
						flows.append(Vector3i.LEFT)
					else:
						BlockID = Parts[blockPos].BlockId
						blockvolume = GlobalBlockManager.blockcatalog[BlockID].volume
						flows = (GlobalBlockManager.blockcatalog[BlockID].flows)
						angle = Parts[blockPos].position.basis
					found = null
					for dir in flows:
						var check = pos + Vector3i(Vector3(dir).rotated(angle.x,PI/2).snapped(Vector3.ONE))
						print(check)
						for i in range(rooms.size()):
							var room:Array = rooms[i]
							if room.has(check):
								if found != null:
									if found != i:
										var room1 = rooms[found]
										var room2 = rooms[i]
										rooms.erase(room1)
										rooms.erase(room2)
										rooms.append(Array(room1 + room2))
										var volume1 = volumes[i]
										var volume2 = volumes[found]
										volumes.erase(volume1)
										volumes.erase(volume2)
										volumes.append(volume1+volume2)
										
										found = null
										print("merging")
										break
								else:
									print(i,"neigh found",volumes)
									volumes[i] += blockvolume
									room.append(pos)
									found = i
									break
					if found == null:
						var newRoom:Array = [pos]
						rooms.append(newRoom)
						volumes.append(blockvolume)
						print("new room discoverd ->",pos)
				x += 1  # If occupied, check the next block
			else:
				found = null
				for dir in directions:
					var check = dir + pos
					for i in range(rooms.size()):
						var room:Array = rooms[i]
						if room.has(check):
							if found != null:
								if found != i:
									var room1 = rooms[found]
									var room2 = rooms[i]
									rooms.erase(room1)
									rooms.erase(room2)
									rooms.append(Array(room1 + room2))
									var volume1 = volumes[i]
									var volume2 = volumes[found]
									volumes.erase(volume1)
									volumes.erase(volume2)
									volumes.append(volume1+volume2)
									
									found = null
									print("merging")
									break
							else:
								print(i,"neigh found",volumes)
								volumes[i] += 8
								room.append(pos)
								found = i
								break
				if found == null:
					var newRoom:Array = [pos]
					rooms.append(newRoom)
					volumes.append(8)
					print("new room discoverd ->",pos)
				x += 1
			if x > maxVec.x+1:
				x = minVec.x-1  # Reset x to the start position for the next line
				y += 1  # Move to the next line
			if y > maxVec.y+1:
				y = minVec.y-1  # Reset y for the next depth level
				z += 1  # Move to the next z depth level
			if z > maxVec.z+1:
				work = false
				print("Finished, ", rooms.size(), " rooms found!, volumes:", volumes)
				break
