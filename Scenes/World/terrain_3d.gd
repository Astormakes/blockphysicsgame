extends Terrain3D

var noise = FastNoiseLite.new()

var seed = 401 #Time.get_unix_time_from_system()#0 

var threads:Array

var mapdirectory = "res://Scenes/World/TerrainData/"

func _ready() -> void:
	GlobalSignals.connect("GenereateNewRegion",generateRegion)

	region_size = 2048#2048
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 9
	noise.fractal_lacunarity = 3.5 # Frequency multiplier between subsequent octaves. Increasing this value results in higher octaves producing noise with finer details
	noise.fractal_gain = 0.30 # lower means more low frequenzy
	noise.frequency = 1/4000.0 # higher means lower requenzy	
	
	
func generateRegion(pos:Vector3):
	var work = Terrain3DRegion.new()
	if pos.x < region_size/2 or pos.x > region_size*32 or pos.z < region_size/2 or pos.z > region_size*32:
		print("ERROR: Out of Bounds!")
		return
	var chunkPos = floor((pos-Vector3(region_size/2,0,region_size/2))/region_size)*region_size
	var region1 = floor((chunkPos + Vector3(0,0,0))/region_size)
	var region2 = floor((chunkPos + Vector3(region_size,0,0))/region_size)
	var region3 = floor((chunkPos + Vector3(0,0,region_size))/region_size)
	var region4 = floor((chunkPos + Vector3(region_size,0,region_size))/region_size)
	
	var region1string = mapdirectory + "terrain3d_" + str(int(region1.x)).pad_zeros(2) + "_" + str(int(region1.z)).pad_zeros(2) + ".res"
	var region2string = mapdirectory + "terrain3d_" + str(int(region2.x)).pad_zeros(2) + "_" + str(int(region2.z)).pad_zeros(2) + ".res"
	var region3string = mapdirectory + "terrain3d_" + str(int(region3.x)).pad_zeros(2) + "_" + str(int(region3.z)).pad_zeros(2) + ".res"
	var region4string = mapdirectory + "terrain3d_" + str(int(region4.x)).pad_zeros(2) + "_" + str(int(region4.z)).pad_zeros(2) + ".res"


	print("region1:" + region1string)
	print("region2:" + region2string)
	print("region3:" + region3string)
	print("region4:" + region4string)
	
	if not FileAccess.file_exists(region1string):
		print("create region1 ", region1*region_size)
		threads.append(Thread.new())
		threads[threads.size()-1].start(runNoise.bind(region1*region_size),2)
	
	if not FileAccess.file_exists(region2string):
		print("create region2 ", region2*region_size)
		threads.append(Thread.new())
		threads[threads.size()-1].start(runNoise.bind(region2*region_size),2)
	
	if not FileAccess.file_exists(region3string):
		print("create region3 ", region3*region_size)
		threads.append(Thread.new())
		threads[threads.size()-1].start(runNoise.bind(region3*region_size),2)
	
	if not FileAccess.file_exists(region4string):
		print("create region4 ", region4*region_size)
		threads.append(Thread.new())
		threads[threads.size()-1].start(runNoise.bind(region4*region_size),2)
	
	

func _process(delta: float) -> void:
	if Input.is_action_just_released("debug2"):
		data.load_directory("res://Scenes/World/TerrainData/")
	if Input.is_action_just_pressed("debugg"):
		var playerpos = GlobalServerHandler.playerpositions[0]
		generateRegion(playerpos)
	if Input.is_action_pressed("debug3"):
		rain(GlobalServerHandler.playerpositions[0])
		
	
func runNoise(Pos:Vector3 = Vector3(0,0,0)):
		var img: Image = Image.create_empty(region_size, region_size, false, Image.FORMAT_RF)
		var imgx = img.get_height()
		var imgy = img.get_width()
		for x in imgx:
			for y in imgy:
				var hight = noise.get_noise_2d(x + Pos.x, y + Pos.z)*1000
				img.set_pixel(x, y,Color(hight, 0., 0., 1.))
		var savestring = mapdirectory + "terrain3d_" + str(int(Pos.x/region_size)).pad_zeros(2) + "_" + str(int(Pos.z/region_size)).pad_zeros(2) + ".res"
		var region = Terrain3DRegion.new()
		region.region_size = region_size
		region.location = Vector2i(floor(Pos.x/region_size),floor(Pos.z/region_size))
		region.set_map(Terrain3DRegion.TYPE_HEIGHT,img)
		region.save(savestring)

func rain(targetpos:Vector3):
	
	var chunkPos = floor((targetpos+Vector3(region_size/2,0,region_size/2))/region_size)*region_size
	for i in range(2000):
		var posX = chunkPos.x + randi_range(-region_size,region_size)/2
		var posY = chunkPos.z + randi_range(-region_size,region_size)/2
		var water = 1.5
		var sediment = 0
		var speed = 2
		var dirX = 0
		var dirY = 0 
		var evaporateSpeed = 0.05
		var inertia = 0.8 # 0.8 is a realistic looking value
		var sedimentCapacityFactor = 10
		var minSedimentCapacity = 0.01 
		var depositSpeed = 0.3
		var erodeSpeed = 0.1
		var gravity = 0.3 # 
		
		var curHight = data.get_height(Vector3(posX,0,posY))
		if curHight < 1:
			for x in range(-1,1):
				for y in range(-1,1):
					var sposx = posX + x
					var sposy = posY + y
					var avg = 0
					avg += curHight - data.get_height(Vector3(sposx+1,0,sposy))
					avg += curHight - data.get_height(Vector3(sposx-1,0,sposy))
					avg += curHight - data.get_height(Vector3(sposx,0,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx,0,sposy-1))
					avg += curHight - data.get_height(Vector3(sposx+1,0,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx,-1,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx-1,0,sposy-1))
					avg += curHight - data.get_height(Vector3(sposx,+1,sposy+1))
					data.set_height(Vector3(sposx,0,sposy),curHight - avg/9)
		else:
			for p in range(70):
				var gridX:int = int(posX)
				var gridY:int = int(posY)
				var pos = Vector3(gridX,0,gridY)
				curHight = data.get_height(pos)
					
				var gradientX = data.get_height(Vector3(gridX+1,0,gridY)) - curHight
				var gradientY = data.get_height(Vector3(gridX,0,gridY+1)) - curHight
				
				dirX = (dirX * inertia - gradientX * (1 - inertia))
				dirY = (dirY * inertia - gradientY * (1 - inertia))
				
				var maxlen = max(abs(dirX),abs(dirY))
				if maxlen != 0:
					dirX = dirX / maxlen
					dirY = dirY / maxlen
				
				posX += dirX
				posY += dirY
				var deltaHeight = data.get_height(Vector3(int(posX),0,int(posY))) - curHight
				
				var sedimentCapacity = max(-(deltaHeight/10) * speed * water * sedimentCapacityFactor, minSedimentCapacity)
				
				if (sediment > sedimentCapacity || deltaHeight > 0):
					var amountToDeposit = 0
					if deltaHeight > 0:
						amountToDeposit = min (deltaHeight, sediment)
					else:
						amountToDeposit = (sediment - sedimentCapacity) * depositSpeed
					sediment -= amountToDeposit
					
					data.set_height(pos,curHight + amountToDeposit)
				else:
					var amountToErode = min((sedimentCapacity - sediment) * erodeSpeed, -deltaHeight)
					sediment += amountToErode
					
					data.set_height(pos,curHight - amountToErode)
				speed = sqrt(max(speed * speed - deltaHeight * gravity,0))
				water *= (1 - evaporateSpeed)
	#data.update_maps(Terrain3DRegion.TYPE_COLOR)
	data.update_maps(Terrain3DRegion.TYPE_HEIGHT)

func _exit_tree() -> void:
	for t in threads:
		t.wait_to_finish()
