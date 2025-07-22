extends Terrain3D

var seed = 1752945376.131 #Time.get_unix_time_from_system()

var RegionPos:Vector3

var thread = Thread.new()

var seedoffset = 0

var mutextasklist = Mutex.new()
var mutextaskwork = Mutex.new()

var tasklist:Array
var work:Dictionary

var noise = FastNoiseLite.new()
var noiseoffset = 0

var boundRange

func _ready() -> void:
	print("Seed:",seed)
	GlobalSignals.connect("GenereateNewRegion",generateRegion)
	
	region_size = 1024 # 512 = 16KM^2 
	
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 8
	noise.fractal_lacunarity = 3.5 # Frequency multiplier between subsequent octaves. Increasing this value results in higher octaves producing noise with finer details
	noise.fractal_gain = 0.30 # lower means more low frequenzy
	noise.frequency = 1/6000.0 # higher means lower requenzy
	
	thread.start(runNoise)
	var range = 1
	for x in range(-range,range):
		for y in range(-range,range):
			generateRegion(Vector3(x,0,y)*region_size)
	boundRange = range*region_size
	print(boundRange)
var dirX = 0
var dirY = 0
var speed = 0 # change down under
var water = 1 # change down under
var sediment = 0  # change down under
var evaporateSpeed = 0.05
var inertia = 0.8 # 0.8 is a realistic looking value
var sedimentCapacityFactor = 10
var minSedimentCapacity = 0.01 
var depositSpeed = 0.3
var erodeSpeed = 0.1
var gravity = 0.3 # 
var posX = randi_range(0,10)
var posY = randi_range(0,10)

func _process(delta: float) -> void:
	mutextaskwork.lock()
	for x in work.keys():
		data.import_images([work[x], null,null], x, 0, 1000)
		work.erase(x)
	mutextaskwork.unlock()

	if Input.is_action_pressed("debugg"):
		for t in range(200):
			posX = randi_range(-boundRange,boundRange)/10
			posY = randi_range(-boundRange,boundRange)/10
			water = 1.5
			sediment = 0
			speed = 2
			dirX = 0
			dirY = 0 
			
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
				for i in range(50):
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
					
					if abs(posX) > boundRange or abs(posY) > boundRange:
						break
					
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
		data.update_maps(Terrain3DRegion.TYPE_HEIGHT)
		data.update_maps(Terrain3DRegion.TYPE_CONTROL)
		data.update_maps(Terrain3DRegion.TYPE_COLOR)
		

func generateRegion(pos:Vector3):
	var existingRegions = data.get_regions_all()
	
	RegionPos.x = floor(pos.x/region_size)
	RegionPos.z = floor(pos.z/region_size)
	
	if(not existingRegions.has(Vector2i(RegionPos.x,RegionPos.z))):
		RegionPos = Vector3(RegionPos.x*region_size + region_size/2,0,RegionPos.z*region_size + region_size/2)
		mutextasklist.lock()
		tasklist.append(RegionPos)
		mutextasklist.unlock()

func runNoise():
	while true:
		if not tasklist.is_empty():
			mutextasklist.lock()
			var Pos = tasklist.pop_back()
			mutextasklist.unlock()
			var img: Image = Image.create_empty(region_size, region_size, false, Image.FORMAT_RF)
			for x in img.get_width():
				for y in img.get_height():
					var xo = x + Pos.x
					var yo = y + Pos.z
					var hight = noise.get_noise_2d(noiseoffset+xo, yo)
					if hight < 0:
						hight = pow(hight+1,1.5)-1
					img.set_pixel(x, y,Color(hight, 0., 0., 1.))
			mutextaskwork.lock()
			work[Pos] = img
			mutextaskwork.unlock()
