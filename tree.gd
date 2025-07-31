extends Node3D

var selfnutriantuse = 0.01
var maxsegmentage = 20
var maxStalklenght = 1

class TreeSegment:
	var age := 0
	var position: Vector3
	var direction: Vector3  # Not normalized — includes length
	var strength: float
	var children: Array = []

	func _init(pos: Vector3, dir: Vector3, str: float):
		position = pos
		direction = dir
		strength = str

var meshes:Array

var root:TreeSegment

func _ready() -> void:
	root = TreeSegment.new(Vector3.ZERO,Vector3.UP*0.4,0.02)
	draw_tree(root)
	
func grow_tree(nut:float, segment:TreeSegment):
	var numChildren = segment.children.size()
	
	nut = nut - (segment.strength+segment.direction.length())*selfnutriantuse
	
	segment.strength += max(nut/150,0)
	
	if segment.children.is_empty():
		segment.direction *= 1.01+(nut) * (maxsegmentage - min(segment.age,maxsegmentage))/maxsegmentage
		segment.age += 1
		
		if segment.direction.length() > maxStalklenght:
			# create and add the main stamm.
			var new_dir = segment.direction/5 + Vector3(randf_range(-0.01,0.01),randf_range(0,0.1),randf_range(-0.01,0.01))
			var new_pos = segment.position + segment.direction
			
			var branch = TreeSegment.new(new_pos,new_dir,segment.strength*0.8)
			segment.children.append(branch)
			
			# create side branches
			var dir_normal = segment.direction.normalized()
			var branch_angle = randf_range(PI / 6.0, PI / 3.0)  # 30°–60°
			var axis = dir_normal.cross(Vector3.UP).normalized()
			if axis.length_squared() == 0:
				axis = Vector3.RIGHT
			new_dir = dir_normal.rotated(axis, branch_angle).normalized()
			new_dir = new_dir.rotated(dir_normal, randf_range(-PI, PI))  # Add twist
			new_dir *= segment.direction.length() * randf_range(0.01, 0.2)

			new_pos = segment.position + segment.direction
			var new_strength = segment.strength * randf_range(0.1, 0.5)

			var child = TreeSegment.new(new_pos, new_dir, new_strength)
			segment.children.append(child)
	
	else:
		segment.direction *= 1.0+(nut/100) * (maxsegmentage - min(segment.age,maxsegmentage))/maxsegmentage
		for x:TreeSegment in segment.children:
			x.position = segment.position + segment.direction
			grow_tree(nut,x)
	

func draw_tree(segment:TreeSegment):
	var end_strenght
	if segment.children.is_empty():
		end_strenght = 0
	else:
		end_strenght = segment.children[0].strength
	
	var mesh = create_tapered_cylinder(segment.position,segment.position + segment.direction,segment.strength,end_strenght)
	
	add_child(mesh)
	meshes.append(mesh)
	
	for x in segment.children:
		draw_tree(x)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug3"):
		grow_tree(0.3,root)
		for x:Node3D in meshes:
			x.queue_free()
			meshes.erase(x)
		draw_tree(root)

func create_tapered_cylinder(start_pos: Vector3, end_pos: Vector3, start_radius: float, end_radius: float, segments: int = 8) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var direction = end_pos - start_pos
	var length = direction.length()
	if length == 0:
		return null

	# Build a transform looking along the direction of the branch
	var transform = Transform3D()
	#transform.basis = transform.basis.looking_at(direction,Vector3.FORWARD)
	var anglex = direction.angle_to(Vector3.LEFT)-PI/2
	var angley = direction.angle_to(Vector3.FORWARD)-PI/2
	
	transform.basis = transform.basis.rotated(Vector3.FORWARD,anglex)
	transform.basis = transform.basis.rotated(Vector3.RIGHT,angley)
	#transform.basis = transform.basis.orthonormalized()
	transform.origin = start_pos

	for i in segments:
		var angle1 := (i / float(segments)) * TAU
		var angle2 := ((i + 1) / float(segments)) * TAU

		# Circular base
		var p1 := Vector3(cos(angle1) * start_radius, 0, sin(angle1) * start_radius)
		var p2 := Vector3(cos(angle2) * start_radius, 0, sin(angle2) * start_radius)

		# Circular top
		var p3 := Vector3(cos(angle2) * end_radius, length, sin(angle2) * end_radius)
		var p4 := Vector3(cos(angle1) * end_radius, length, sin(angle1) * end_radius)

		# Transform to world space
		p1 = transform * p1
		p2 = transform * p2
		p3 = transform * p3
		p4 = transform * p4

		# Side quad split into 2 triangles
		st.add_vertex(p1)
		st.add_vertex(p2)
		st.add_vertex(p3)

		st.add_vertex(p1)
		st.add_vertex(p3)
		st.add_vertex(p4)

	st.generate_normals()
	var mesh = st.commit()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	return mesh_instance
