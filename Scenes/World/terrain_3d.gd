extends Terrain3D

var noise = FastNoiseLite.new()

var seed = 402 #Time.get_unix_time_from_system()#0 

var threads:Array

var chunks:Dictionary

var mapdirectory = "res://Scenes/World/TerrainData/"

func _ready() -> void:
	GlobalSignals.connect("GenereateNewRegion",generateRegion)

	# region_size * 32 = max size of map lol

	region_size = 2048
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 9
	noise.fractal_lacunarity = 3.0 # Frequency multiplier between subsequent octaves. Increasing this value results in higher octaves producing noise with finer details
	noise.fractal_gain = 0.30 # lower means more low frequenzy
	noise.frequency = 1/4000.0 # higher means lower requenzy	
	
func generateRegion(pos:Vector3):
	threads.append(Thread.new())
	threads[threads.size()-1].start(generate.bind(pos)) # starts the generating of regions and saves them as regions in the data directory
	
	
	
func generate(pos:Vector3):
	# calculates the regions individual positions from the pos
	var chunkPos = floor((pos-Vector3(region_size/2,0,region_size/2))/region_size)*region_size
	var region:Array = [0,0,0,0]
	region[0] = floor((chunkPos + Vector3(0,0,0))/region_size)
	region[1] = floor((chunkPos + Vector3(region_size,0,0))/region_size)
	region[2] = floor((chunkPos + Vector3(0,0,region_size))/region_size)
	region[3] = floor((chunkPos + Vector3(region_size,0,region_size))/region_size)
	
	# creates the strings for the tres files of the map data for these 4 regions
	var regionstring = ["","","",""]
	
	for i in range(4):
		var posStringX
		if region[i].x >= 0:
			posStringX = "_" + str(int(region[i].x)).pad_zeros(2)
		else:
			posStringX = str(int(region[i].x)).pad_zeros(2)
			
		var posStringY
		if region[i].z >= 0:
			posStringY = "_" + str(int(region[i].z)).pad_zeros(2)
		else:
			posStringY = str(int(region[i].z)).pad_zeros(2)
		
		regionstring[i] = mapdirectory + "terrain3d" + posStringX + posStringY + ".res"

	# checks if these regions exist based on the strings and starts a thread that will create that region if it dosent.
	var region_threads = []
	for i in range(4):
		if not FileAccess.file_exists(regionstring[i]):
			print("create region1 ", region[i]*region_size)
			threads.append(Thread.new())
			threads[threads.size()-1].start(runNoise.bind(region[i]*region_size,chunkPos),0)
			region_threads.append(threads[threads.size()-1])

	# waits for the threads to be done generating the regions
	while true:
		for i in range(99999): pass 
		var done = true
		for t in region_threads:
			if t.is_alive():
				done = false
		if done:
			print("regions generated")
			break
	
	# takes the 4 regions for that chunk and turns them into a single image to be processed by the rain.

	var size = Vector2i(region_size,region_size)
	var full_size = size * 2
	var stiched = Image.create(full_size.x, full_size.y, false, Image.FORMAT_RF)

	var imgs = [
		load(regionstring[0]).height_map,
		load(regionstring[1]).height_map,
		load(regionstring[2]).height_map,
		load(regionstring[3]).height_map]

	var positions = [
		Vector2i(0, 0),
		Vector2i(size.x, 0),
		Vector2i(0, size.y),
		Vector2i(size.x, size.y)]

	for i in range(4):
		stiched.blit_rect(imgs[i], Rect2i(Vector2i.ZERO, size), positions[i])
	
	
	var iterations = region_size*2000
	for i in range(iterations):
		if i % (iterations/100) == 0:
			print(ceil((float(i)/iterations)*100))
			
		var posX = randi_range(region_size*0.5,region_size*1.5)
		var posY = randi_range(region_size*0.5,region_size*1.5)
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
		
		var curHight = stiched.get_pixel(posX,posY).r
		if curHight < 1:
			for x in range(-2,3):
				for y in range(-2,3):
					var sposx = posX + x
					var sposy = posY + y
					var avg = 0
					for xi in range(-1,2):
						for yi in range(-1,2):
							avg += curHight -  stiched.get_pixel(sposx+xi,sposy+yi).r
					stiched.set_pixel(sposx,sposy,Color(curHight - avg/9,0,0))
		else:
			for p in range(50):
				var gridX:int = int(posX)
				var gridY:int = int(posY)
				curHight = stiched.get_pixel(gridX,gridY).r #data.get_height(pos)
					
				var gradientX = stiched.get_pixel(gridX+1,gridY).r - curHight #data.get_height(Vector3(gridX+1,0,gridY)) - curHight
				var gradientY = stiched.get_pixel(gridX,gridY+1).r - curHight #data.get_height(Vector3(gridX,0,gridY+1)) - curHight
				
				dirX = (dirX * inertia - gradientX * (1 - inertia))
				dirY = (dirY * inertia - gradientY * (1 - inertia))
				
				var maxlen = max(abs(dirX),abs(dirY))
				if maxlen != 0:
					dirX = dirX / maxlen
					dirY = dirY / maxlen
				
				posX += dirX
				posY += dirY
				var deltaHeight = stiched.get_pixel(int(posX),int(posY)).r - curHight #data.get_height(Vector3(,0,int(posY))) - curHight
				
				var sedimentCapacity = max(-(deltaHeight/10) * speed * water * sedimentCapacityFactor, minSedimentCapacity)
				
				if (sediment > sedimentCapacity || deltaHeight > 0):
					var amountToDeposit = 0
					if deltaHeight > 0:
						amountToDeposit = min (deltaHeight, sediment)
					else:
						amountToDeposit = (sediment - sedimentCapacity) * depositSpeed
					sediment -= amountToDeposit
					
					stiched.set_pixel(gridX,gridY,Color(curHight + amountToDeposit,0,0)) #data.set_height(pos,curHight + amountToDeposit)
				else:
					var amountToErode = min((sedimentCapacity - sediment) * erodeSpeed, -deltaHeight)
					sediment += amountToErode
					
					stiched.set_pixel(gridX,gridY,Color(curHight - amountToErode,0,0)) #data.set_height(pos,curHight - amountToErode)
				speed = sqrt(max(speed * speed - deltaHeight * gravity,0))
				water *= (1 - evaporateSpeed)
	
	# split that image back apart and save it as individual regions back to the files.
	var result: Array[Image] = []
	for ipos in positions:
		var sub = Image.create(size.x, size.y, false, stiched.get_format())
		sub.blit_rect(stiched, Rect2i(ipos, size), Vector2i.ZERO)
		result.append(sub)
	
	for i in range(4):
		var tempregion = Terrain3DRegion.new()
		tempregion.region_size = region_size
		tempregion.location = Vector2i(region[i].x,region[i].z)
		tempregion.set_map(Terrain3DRegion.TYPE_HEIGHT,result[i])
		tempregion.save(regionstring[i])
	
	print("done")
	return
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("debug2"):
		data.load_directory(mapdirectory)
	if Input.is_action_just_pressed("debugg"):
		var playerpos = GlobalServerHandler.playerpositions[0]
		generateRegion(playerpos)

	if Input.is_action_pressed("debug3"):
		rain(GlobalServerHandler.playerpositions[0])
		

func runNoise(Pos:Vector3 = Vector3(0,0,0),chunk = Vector3(0,0,0)):
		var img: Image = Image.create_empty(region_size, region_size, false, Image.FORMAT_RF)
		var imgx = img.get_height()
		var imgy = img.get_width()
		for x in imgx:
			for y in imgy:
				var hight = noise.get_noise_2d(x + Pos.x, y + Pos.z)*1000
				img.set_pixel(x, y,Color(hight, 0., 0., 1.))
		
		var posStringX
		if Pos.x >= 0:
			posStringX = "_" + str(int(Pos.x/region_size)).pad_zeros(2)
		else:
			posStringX = str(int(Pos.x/region_size)).pad_zeros(2)
		
		var posStringY
		if Pos.z >= 0:
			posStringY = "_" + str(int(Pos.z/region_size)).pad_zeros(2)
		else:
			posStringY = str(int(Pos.z/region_size)).pad_zeros(2)
			
		var savestring = mapdirectory + "terrain3d" + posStringX + posStringY + ".res"
		var region = Terrain3DRegion.new()
		
		region.region_size = region_size
		region.location = Vector2i(floor(Pos.x/region_size),floor(Pos.z/region_size))
		region.set_map(Terrain3DRegion.TYPE_HEIGHT,img)
		region.save(savestring)
		return

func rain(targetpos:Vector3):
	
	var chunkPos = floor((targetpos+Vector3(region_size/2,0,region_size/2))/region_size)*region_size
	for i in range(500):
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
		var gravity = 0.3 
		
		var curHight = data.get_height(Vector3(posX,0,posY))
		if curHight < 1:
			for x in range(-2,2):
				for y in range(-2,2):
					var sposx = posX + x
					var sposy = posY + y
					var avg = 0
					avg += curHight - data.get_height(Vector3(sposx+1,0,sposy))
					avg += curHight - data.get_height(Vector3(sposx-1,0,sposy))
					avg += curHight - data.get_height(Vector3(sposx,0,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx,0,sposy-1))
					avg += curHight - data.get_height(Vector3(sposx+1,0,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx-1,0,sposy+1))
					avg += curHight - data.get_height(Vector3(sposx-1,0,sposy-1))
					avg += curHight - data.get_height(Vector3(sposx+1,0,sposy-1))
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
