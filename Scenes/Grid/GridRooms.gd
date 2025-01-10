extends Node

var Parts: Dictionary = {}


var work: bool = false


var thread1 : Thread

var Positions:Array

var end = false

var semaphore: Semaphore
var mutex: Mutex

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gridscene = get_node("..")
	gridscene.connect("parts_updated", Parts_update)
	thread1 = Thread.new()
	thread1.start(run_rooms)
	semaphore = Semaphore.new()
	mutex = Mutex.new()
	
func _exit_tree() -> void:
		end = true
		semaphore.post()
		thread1.wait_to_finish()


func Parts_update(Send: Dictionary) -> void:
	Parts = Send
	mutex.lock()
	work = true
	mutex.unlock()
	
func _process(delta: float) -> void:
	if work:
		mutex.lock()
		Positions = Parts.keys()
		mutex.unlock()
		
		semaphore.post()

func run_rooms():

	var directions: Array = [Vector3i.LEFT,Vector3i.FORWARD, Vector3i.RIGHT, Vector3i.UP, Vector3i.FORWARD, Vector3i.BACK,Vector3i.DOWN]
	
	var x: float
	var y: float
	var z: float
	
	
	var minVec: Vector3
	var maxVec: Vector3
	
	var found
	
	var rooms: Array[Array] = []
	while true:
		
		minVec = Vector3(9999, 9999, 9999)  # Start with a high min value
		maxVec = Vector3(-9999, -9999, -9999) 
			
		for pos in Positions:
			minVec = minVec.min(pos)
			maxVec = maxVec.max(pos)
			
		x = minVec.x - 1
		y = minVec.y - 1
		z = minVec.z - 1  # You can adjust this offset if necessary
			
		rooms.clear()
			
		while true:
			var pos: Vector3i = Vector3(x, y, z)
			
			if Positions.has(pos):  # Check if the position is occupied
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
									found = null
									break
							else:
								#print("neigh found")
								room.append(pos)
								found = i
								break
				if found == null:
					var newRoom:Array = [pos]
					rooms.append(newRoom)
					#print("new room discoverd ->",pos)
				
				x += 1
				
			if x > maxVec.x+1:
				x = minVec.x-1  # Reset x to the start position for the next line
				y += 1  # Move to the next line
			if y > maxVec.y+1:
				y = minVec.y-1  # Reset y for the next depth level
				z += 1  # Move to the next z depth level
			if z > maxVec.z+1:
				mutex.lock()
				work = false
				mutex.unlock()
				print("Finished, ", rooms.size(), " rooms found!")
				break
		semaphore.wait()
		if end:
			break
