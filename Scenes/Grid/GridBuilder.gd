extends Node3D

signal parts_updated(parts: Dictionary)

var Parts: Dictionary
var deletedBlocks: Array

# Parts Structure[]
var multi_mesh_instance: MultiMeshInstance3D
var multi_mesh: MultiMesh

var defaultColisionshape = preload("res://prebuilds/defaultColisionShape.tscn")
var colisionshape1x1x2 = preload("res://prebuilds/1x1x2_Slope_ColisionShape.tscn")

var MaxSize = Vector3(20,20,20)
var MaxStructualBlocks = MaxSize.x * MaxSize.y * MaxSize.z

var delete_at = 6

var counter:int = 0

func _ready() -> void:
	GlobalSignals.connect("blockplacementRequested",blockplacementRequested)
	GlobalSignals.connect("blockremoveRequested",blockremoveRequested)
	
	
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.material_override = load(GlobalBlockManager.blockcatalog[0].material)
	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.set_use_colors(true)
	multi_mesh.mesh = load("res://Meshes/DefaultBoxMesh.tres")
	multi_mesh_instance.multimesh = multi_mesh
	add_child(multi_mesh_instance)
	
	multi_mesh.instance_count = MaxStructualBlocks
		
	spawn_block(Transform3D(Basis(),Vector3(0,0,0)),0)

func send_Parts(Parts):
		emit_signal("parts_updated",Parts)

func blockplacementRequested(gridname:String,playerId:int, pos:Transform3D, ItemID:int):
	if gridname == name:
		var type = GlobalBlockManager.blockcatalog[ItemID].type
		if type == "block":
			spawn_block(pos,ItemID)
			send_Parts(Parts)
		if type == "shape":
			spawn_shape(pos,ItemID)
			send_Parts(Parts)

func blockremoveRequested(gridname:String,playerId:int, pos:Transform3D):
	if gridname == name:
		var intpos = Vector3i(pos.origin*5)
		if Parts.has(intpos):
			var block_data = Parts[intpos] 
			var type = block_data.type
			if type == "block":
				remove_block(pos)
			if type == "shape":
				remove_shape(pos)
			if type == "reference":
				blockremoveRequested(gridname,playerId,Transform3D(Parts[block_data.origin].position.basis,Parts[block_data.origin].position.origin/5))
			
			send_Parts(Parts)
		else:
			print(" Block not found :(")

func remove_shape(pos: Transform3D):
	var PartsSize = Parts.size()
	var pos_vec = pos.origin  # Extract the position
	var intpos = Vector3i(pos_vec*5)
	var block_data = Parts[intpos]
	
	var new_block_mass = -block_data.mass
	self.mass += new_block_mass
	self.center_of_mass = (self.center_of_mass * (self.mass - new_block_mass) + pos_vec * new_block_mass) / self.mass
	if block_data.type == "shape":
		if block_data.size == Vector3(0.2,0.2,0.2):
			block_data.collider.queue_free()
			block_data.mesh.queue_free()
			Parts.erase(intpos)
		
		else:
			block_data.collider.queue_free()
			block_data.mesh.queue_free()

			var blockSizeRotated = (block_data.size*5).rotated(pos.basis.x,PI/2).abs().snapped(Vector3(0.2,0.2,0.2))
			# Iterate over all positions occupied by the block
			for x in range(blockSizeRotated.x):
				for y in range(blockSizeRotated.y):
					for z in range(blockSizeRotated.z):
						# Calculate the world position for each snap point
						var offset = Vector3(x, y, z) * 0.2  # Assuming 0.2 is the block size
						var snapped_pos = (pos_vec + offset).snapped(Vector3(0.2, 0.2, 0.2))
						# remove parts entries
						Parts.erase(Vector3i(snapped_pos*5))
		
		if get_child_count() <= delete_at:
			queue_free()
			print("bye")

func spawn_shape(pos: Transform3D, blockID: int):
	var pos_vec = pos.origin
	var PartsSize = Parts.size()
	var block_data = GlobalBlockManager.blockcatalog[blockID]
	var intpos = Vector3i(pos_vec*5)
	
	# Create the collider
	var collider = load(block_data.shape).instantiate()
	collider.transform = pos
	add_child(collider)
	
	# Create the mesh
	var mesh = MeshInstance3D.new()
	mesh.mesh = load(block_data.mesh)
	mesh.transform = pos
	add_child(mesh)
	
	# Apply material and color
	var meshmaterial = load("res://Materials/defaultStructualMaterial.tres").duplicate()
	meshmaterial.albedo_color = GlobalBlockManager.blockcatalog[blockID].color
	mesh.material_override = meshmaterial
	
	# Register the block in the center/origin position
	Parts[intpos] = {
		"type": block_data.type,
		"position": Transform3D(pos.basis,intpos),
		"BlockId": blockID,
		"color": block_data.color,
		"HP": block_data.maxHP,
		"collider": collider,
		"mesh": mesh,
		"mass": block_data.mass,
		"size": block_data.size
	}

	var new_block_mass = block_data.mass
	self.mass += new_block_mass
	self.center_of_mass = (self.center_of_mass * (self.mass - new_block_mass) + pos_vec * new_block_mass) / self.mass


	var blockSizeRotated = (block_data.size*5).rotated(pos.basis.x,PI/2).abs().snapped(Vector3(0.2,0.2,0.2))
	# Iterate over all positions occupied by the block
	for x in range(blockSizeRotated.x):
		for y in range(blockSizeRotated.y):
			for z in range(blockSizeRotated.z):
				# Calculate the world position for each snap point
				var offset = Vector3(x, y, z) * 0.2  # Assuming 0.2 is the block size
				var snapped_pos = Vector3i((pos_vec + offset).snapped(Vector3(0.2, 0.2, 0.2))*5)

				# Skip the origin position
				if snapped_pos == intpos:
					continue

				# Add a reference to the origin
				Parts[snapped_pos] = {
					"type": "reference",
					"origin": intpos
				}

func spawn_block(pos: Transform3D, blockID: int):
	var PartsSize = Parts.size()
	var pos_vec = pos.origin  # Extract the position
	var block_data = GlobalBlockManager.blockcatalog[blockID]
	var count
	var deletedBlocksSize = deletedBlocks.size()
	var intpos = Vector3i(pos_vec*5)
	if deletedBlocksSize > 0:
		count = deletedBlocks.pop_front()
	else:
		count = PartsSize
	
	multi_mesh.visible_instance_count = PartsSize + deletedBlocksSize + 1
	
	multi_mesh.set_instance_transform(count, Transform3D(Basis().scaled(Vector3(1,1,1)), pos_vec))
	multi_mesh.set_instance_color(count, block_data.color)

	var collider = defaultColisionshape.instantiate()
	collider.transform.origin = pos_vec
	add_child(collider)
	
	var new_block_mass = block_data.mass
	self.mass += new_block_mass
	
	# credit to chatgpt for optimizing this function and makeing this work just like that... 
	self.center_of_mass = (self.center_of_mass * (self.mass - new_block_mass) + pos_vec * new_block_mass) / self.mass


	Parts[intpos] = {
		"type": block_data.type,
		"position": intpos,
		"BlockId": blockID,
		"color": block_data.color,
		"HP": block_data.maxHP,
		"Multimesh": count,
		"collider": collider,
		"mass": block_data.mass
	}

func remove_block(pos: Transform3D):
	var PartsSize = Parts.size()
	var pos_vec = pos.origin  # Extract the position
	var block_data = Parts[Vector3i(pos_vec*5)]
	var mesh = block_data.Multimesh
	var deletedBlocksSize = deletedBlocks.size()
	var intpos = Vector3i(pos_vec*5)
	deletedBlocks.push_front(mesh)
	
	block_data.collider.queue_free()
	
	multi_mesh.visible_instance_count = PartsSize + deletedBlocksSize + 1
	multi_mesh.set_instance_transform(mesh, Transform3D(Basis().scaled(Vector3(0,0,0))))
	
	Parts.erase(intpos)
	
	var new_block_mass = -block_data.mass # be aware of the little minus sign lol
	self.mass += new_block_mass
	
	self.center_of_mass = (self.center_of_mass * (self.mass - new_block_mass) + pos_vec * new_block_mass) / self.mass
	
	if get_child_count() < delete_at:
		queue_free()
		print("bye")
