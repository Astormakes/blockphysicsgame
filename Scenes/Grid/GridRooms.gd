extends Node

var Parts: Dictionary = {}
var Positions: Array

var minVec: Vector3
var maxVec: Vector3

var directions: Array = [
	Vector3.FORWARD * 0.2, Vector3.BACK * 0.2, Vector3.LEFT * 0.2,
	Vector3.RIGHT * 0.2, Vector3.UP * 0.2, Vector3.DOWN * 0.2
]

var rooms: Array = [[]]

var x: float
var y: float
var z: float

var checkspeed = 1000
var work: bool = false

var counter = 0

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
	
	x = minVec.x
	y = minVec.y
	z = minVec.z - 0.2  # You can adjust this offset if necessary
	
	rooms[0] = [Vector3(x, y, z)]
	
	work = true

func _process(delta: float) -> void:
	counter += 1
	
	if counter > 30:
		counter = 0
		run_rooms()


func run_rooms():
	if work:
		print(Vector3(x, y, z))
		$"../MeshInstance3D".transform.origin = Vector3(x, y, z)
		
		for i in range(1):
			if Positions.has(Vector3(x, y, z)):  # Check if the position is occupied
				x += 0.2  # If occupied, check the next block
				print("occupied moving on")
			else:
				for dir in directions:
					var checkposition = Vector3(x, y, z) + dir
					$"../MeshInstance3D".transform.origin = checkposition
					for room in rooms:  # Check if position is part of any room
						for x in room:
							if x == checkposition:
								print("Room found for", checkposition)
								room.push_back(Vector3(x, y, z))  # Add the current position to the room
								x += 0.2
								break
					rooms.push_back(Vector3(x, y, z))
					x += 0.2
					print("making a new room")
					break
			if x >= maxVec.x:
				x = minVec.x  # Reset x to the start position for the next line
				y += 0.2  # Move to the next line
			if y >= maxVec.y:
				y = minVec.y  # Reset y for the next depth level
				z += 0.2  # Move to the next z depth level
			if z >= maxVec.z:
				work = false  # End the work after checking all blocks
				print("Finished")
				print(rooms)
