extends Node3D


## This will determin the Growcycles that will be done on spawn. 40 will make a devent pregrown oak
@export var pre_grow = 0

var selfnutriantuse = 0.1
var maxsegmentage = 20
var maxStalklenght = 1
var limbstraightness = 0.9
var growUp = 0.2 # 0.3 and grow down 0 makes limbs gradually grow upwards
var growdown = -0.05
var brachmaxangel:float = 7.0
var branchminangle:float = 4.0
var newLimbLenght = 0.1

class TreeSegment:
	var age := 0
	var position: Vector3
	var direction: Vector3  # Not normalized — includes length
	var strength: float
	var children: Array = []
	var depth:int = 0
	
	func _init(pos: Vector3, dir: Vector3, str: float):
		position = pos
		direction = dir
		strength = str

var meshes:Array

var STBranches:SurfaceTool
var branch_mesh

var STLeaves:SurfaceTool = SurfaceTool.new()
var leaf_mesh

var root:TreeSegment

func _init(pre_grow_amount:int = 0) -> void:
	pre_grow = pre_grow_amount

func _ready() -> void:
	STBranches  = SurfaceTool.new()
	
	root = TreeSegment.new(Vector3.ZERO,Vector3.UP/2,0.1)
	
	for x in range(pre_grow):
		grow_tree(randf_range(0.5,1),root)
	
	
	STBranches.begin(Mesh.PRIMITIVE_TRIANGLES)
	STLeaves.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	draw_tree(root)
	
	STBranches.generate_normals()
	branch_mesh = MeshInstance3D.new()
	branch_mesh.material_override = preload("res://Materials/Simple_Bark.tres")
	branch_mesh.mesh = STBranches.commit()
	add_child(branch_mesh)
	
	STLeaves.generate_normals()
	leaf_mesh = MeshInstance3D.new()
	leaf_mesh.material_override = preload("res://Materials/simple_Leafes.tres")
	leaf_mesh.mesh = STLeaves.commit()
	add_child(leaf_mesh)



func grow_tree(nut:float, segment:TreeSegment):
	
	nut = nut * (0.7 + min(segment.strength,0.3))

	segment.strength += max(nut/150,0)
	
	if segment.children.is_empty():
		segment.direction *= 1.0+(nut)
		segment.age += 1
		
		if segment.direction.length() > maxStalklenght:
			# create and add the main stamm.
			var ranrage = (1-limbstraightness)*newLimbLenght 
			var new_dir = segment.direction/5 + Vector3(randf_range(-ranrage,ranrage),randf_range(growdown,growUp),randf_range(-ranrage,ranrage))
			var new_pos = segment.position + segment.direction
			
			var branch = TreeSegment.new(new_pos,new_dir,segment.strength*0.8)
			segment.children.append(branch)

			if segment.depth < 9:
				#create side branches
				var dir_normal = segment.direction.normalized()
				var branch_angle = randf_range(PI / brachmaxangel, PI / branchminangle)  # 40°–70°
				var axis = dir_normal.cross(Vector3.UP).normalized()
				if axis.length_squared() == 0:
					axis = Vector3.RIGHT
				new_dir = dir_normal.rotated(axis, branch_angle).normalized()
				new_dir = new_dir.rotated(dir_normal, randf_range(-PI, PI))  # Add twist
				new_dir *= segment.direction.length() * randf_range(0.01, 0.2)
				new_pos = segment.position + segment.direction
				var new_strength = segment.strength * randf_range(0.1, 0.2)

				var child = TreeSegment.new(new_pos, new_dir, new_strength)
				segment.children.append(child)
	
	else:
		segment.direction *= 1.0+(nut/100) * (maxsegmentage - min(segment.age,maxsegmentage))/maxsegmentage
		for x:TreeSegment in segment.children:
			x.position = segment.position + segment.direction*0.99
			x.depth = segment.depth + 1
			grow_tree(nut,x)

func draw_tree(segment:TreeSegment):

	var end_strenght
	if segment.children.is_empty():
		end_strenght = 0
	else:
		end_strenght = segment.children[0].strength
	
	create_tapered_cylinder(segment.position,segment.position + segment.direction,segment.strength,end_strenght)
	
	var leafSize = min(segment.depth/2.0,1.5)/1.5
	if segment.depth > 2:
		create_leaf_plane(segment.position,segment.direction,leafSize)
	
	for x in segment.children:
		draw_tree(x)



func _process(delta: float) -> void:
	if Input.is_action_pressed("debug3"):
		grow_tree(0.5,root)

		STBranches.begin(Mesh.PRIMITIVE_TRIANGLES)
		STLeaves.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		draw_tree(root)
		
		STLeaves.generate_normals()
		STBranches.generate_normals()
		leaf_mesh.mesh = STLeaves.commit()
		branch_mesh.mesh = STBranches.commit()


func create_tapered_cylinder(start_pos: Vector3, end_pos: Vector3, start_radius: float, end_radius: float, segments: int = 8) -> MeshInstance3D:
	var direction = end_pos - start_pos
	var length = direction.length()
	if length == 0:
		return null

	var z_axis = direction.normalized()

	# Choose a helper vector that's not parallel to the direction
	var temp_up
	
	if abs(z_axis.dot(Vector3.UP)) > 0.99:
		temp_up = Vector3.FORWARD
	else:
		temp_up = Vector3.UP

	# Create orthonormal basis manually (right-handed)
	var x_axis = z_axis.cross(temp_up).normalized()
	var y_axis = x_axis.cross(z_axis).normalized()

	for i in segments:
		var angle1 = TAU * float(i) / segments
		var angle2 = TAU * float(i + 1) / segments

		var u1 = float(i) / segments
		var u2 = float(i + 1) / segments

		# Local circle positions
		var circle1_start = x_axis * cos(angle1) + y_axis * sin(angle1)
		var circle1_end = x_axis * cos(angle2) + y_axis * sin(angle2)

		# Bottom ring
		var p1 = start_pos + circle1_start * start_radius
		var p2 = start_pos + circle1_end * start_radius

		# Top ring
		var p3 = end_pos + circle1_end * end_radius
		var p4 = end_pos + circle1_start * end_radius

		# UV coordinates
		var v_bottom = 0.0
		var v_top = 1.0
		STBranches.set_uv(Vector2(u1, v_bottom))
		STBranches.add_vertex(p1)

		STBranches.set_uv(Vector2(u2, v_bottom))
		STBranches.add_vertex(p2)

		STBranches.set_uv(Vector2(u2, v_top))
		STBranches.add_vertex(p3)

		STBranches.set_uv(Vector2(u1, v_bottom))
		STBranches.add_vertex(p1)
		
		STBranches.set_uv(Vector2(u2, v_top))
		STBranches.add_vertex(p3)

		
		STBranches.set_uv(Vector2(u1, v_top))
		STBranches.add_vertex(p4)
	return 

func create_leaf_plane(position: Vector3, direction: Vector3,size:float = 1) -> MeshInstance3D:

	var up = direction.normalized()

	# Pick a fallback vector not parallel to up
	var fallback = Vector3.FORWARD
	if abs(up.dot(fallback)) > 0.99:
		fallback = Vector3.RIGHT

	# Get right vector
	var right = up.cross(fallback).normalized()

	# Apply random yaw — this is your "leaf twist"
	var yaw_angle = randf_range(-PI, PI)
	right = right.rotated(up, yaw_angle)

	# Forward is optional; used for normal orientation
	var forward = right.cross(up).normalized()

	# Now build your plane using 'right' (width) and 'up' (height)
	var half_width = 0.5  * size
	var half_height = 0.5  * size

	var p1 = position - right * half_width - up * half_height
	var p2 = position - right * half_width + up * half_height
	var p3 = position + right * half_width + up * half_height
	var p4 = position + right * half_width - up * half_height
	

	STLeaves.set_uv(Vector2(0,1))
	STLeaves.add_vertex(p1)
	STLeaves.set_uv(Vector2(1,1))
	STLeaves.add_vertex(p2)
	STLeaves.set_uv(Vector2(1,0))
	STLeaves.add_vertex(p3)
	STLeaves.set_uv(Vector2(0,1))
	STLeaves.add_vertex(p1)
	STLeaves.set_uv(Vector2(1,0))
	STLeaves.add_vertex(p3)
	STLeaves.set_uv(Vector2(0,0))
	STLeaves.add_vertex(p4)

	#STLeaves.generate_normals()
	#var mesh = STLeaves.commit()

	#var mi := MeshInstance3D.new()
	#mi.mesh = mesh
	#mi.material_override = preload("res://Materials/simple_Leafes.tres")
	return #mi
