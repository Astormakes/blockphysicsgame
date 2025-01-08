extends Node

var Parts: Dictionary = {}
var Positions: Array

var minVec: Vector3
var maxVec: Vector3

var directions: Array = [Vector3.LEFT * 0.2, Vector3.FORWARD * 0.2, Vector3.DOWN * 0.2, Vector3.BACK * 0.2]

var rooms: Array = []

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
	
	x = minVec.x - 0.2
	y = minVec.y - 0.2
	z = minVec.z - 0.2  # You can adjust this offset if necessary
	
	work = true
	rooms.clear()
	
func _process(delta: float) -> void:
	counter += 1
	
	if counter > 1:
		counter = 0
		run_rooms()
	
	if Input.is_action_just_pressed("debugg"):
		run_rooms()

func run_rooms():
	if work:
		for l in range(100):
			var pos: Vector3 = Vector3(x, y, z)
			#$"../MeshInstance3D".transform.origin = pos
			
			if Positions.has(pos):  # Check if the position is occupied
				#print("--occupied moving on")
				x += 0.2  # If occupied, check the next block
			else:
				#print("--free pace")
				var found = false
				for dir in directions:
					var check: Vector3 = dir + pos
					#print(check)
					for room in rooms:
						for x in room:
							if check.is_equal_approx(x):
								room.append(pos)
								found = true
								break
						if found:
							break
					if found:
						break
				if found == false:
					rooms.append([pos])
					#print("new room discoverd ->",pos)
				
				x += 0.2
				
			if x > maxVec.x+0.2:
				x = minVec.x-0.2  # Reset x to the start position for the next line
				y += 0.2  # Move to the next line
			if y > maxVec.y+0.2:
				y = minVec.y-0.2  # Reset y for the next depth level
				z += 0.2  # Move to the next z depth level
			if z > maxVec.z+0.2:
				work = false  # End the work after checking all blocks
				print("Finished, ", rooms.size(), " rooms found!")
				break
