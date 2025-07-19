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

var dropid = 0

var debugSwitch = false
var lables:Array

func _ready() -> void:
	print("Seed:",seed)
	GlobalSignals.connect("GenereateNewRegion",generateRegion)
	
	region_size = 512 # 256 = 8KM^2 
	
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 12
	noise.fractal_lacunarity = 3.5 # Frequency multiplier between subsequent octaves. Increasing this value results in higher octaves producing noise with finer details
	noise.fractal_gain = 0.30 # lower means more low frequenzy
	noise.frequency = 1/6000.0 # higher means lower requenzy
	
	thread.start(runNoise)
	var range = 2
	for x in range(-range,range):
		for y in range(-range,range):
			generateRegion(Vector3(x,0,y)*512)


var dirX = 0
var dirY = 0
var speed = 0 # change down under
var water = 1 # change down under
var sediment = 0  # change down under
var evaporateSpeed = 0.05
var inertia = 0.8 # 0.8 is a realistic looking value
var sedimentCapacityFactor = 10
var minSedimentCapacity = 0.01 
var depositSpeed = 0.2
var erodeSpeed = 0.1
var gravity = 0.5 # 
var posX = randi_range(0,10)
var posY = randi_range(0,10)

func _process(delta: float) -> void:
	mutextaskwork.lock()
	for x in work.keys():
		data.import_images([work[x], null, null], x, 0, 1000)
		work.erase(x)
	mutextaskwork.unlock()
	
	if Input.is_action_just_pressed("debug2"):
		for entry in lables:
			entry.free()
		lables.clear()
			
	
	if Input.is_action_just_pressed("debug3"):
		debugSwitch = not debugSwitch
		print(debugSwitch)
	
	if Input.is_action_pressed("debugg"):
		for t in range(30):
			posX = randi_range(-1000,1000)
			posY = randi_range(-1000,1000)
			water = 1.5
			sediment = 0
			speed = 2
			dirX = 0
			dirY = 0 
			dropid += 1
			for i in range(60):
				var gridX:int = int(posX)
				var gridY:int = int(posY)
				
				var text = ""
				
				var curHight = data.get_height(Vector3(gridX,0,gridY))
				if curHight < 0:
					break
					
					
				var gradientX = ((data.get_height(Vector3(gridX+1,0,gridY)) - curHight) + (curHight - data.get_height(Vector3(gridX-1,0,gridY))))/2
				var gradientY = ((data.get_height(Vector3(gridX,0,gridY+1)) - curHight) + (curHight - data.get_height(Vector3(gridX,0,gridY-1))))/2
				
				dirX = (dirX * inertia - gradientX * (1 - inertia))
				dirY = (dirY * inertia - gradientY * (1 - inertia))
				
				var len = sqrt(dirX * dirX + dirY * dirY);

				if len != 0:
					dirX /= len
					dirY /= len
				
				posX += dirX
				posY += dirY
				
				var deltaHeight = data.get_height(Vector3(int(posX),0,int(posY))) - curHight
				
				var sedimentCapacity = max(-(deltaHeight/10) * speed * water * sedimentCapacityFactor, minSedimentCapacity)

				if (sediment > sedimentCapacity || deltaHeight > 0):
					var amountToDeposit = 0
					if deltaHeight > 0:
						amountToDeposit = min (deltaHeight, sediment)
						text += "deLvl:" + str(snapped(amountToDeposit,0.01)) + "\n"
					else:
						amountToDeposit = (sediment - sedimentCapacity) * depositSpeed
						text += "deCap:" + str(snapped(amountToDeposit,0.01)) + "\n"
					sediment -= amountToDeposit
					
					data.set_height(Vector3(gridX,0,gridY),curHight + amountToDeposit)
					
				else:
					var amountToErode = min((sedimentCapacity - sediment) * erodeSpeed, -deltaHeight)
					sediment += amountToErode
					
					text += "er:" + str(snapped(amountToErode,0.01)) + "\n"
					for X in range(-2,2):
						for Y in range(-2,2):
							var brushhight = data.get_height(Vector3(gridX+X,0,gridY+Y))
							var dist = sqrt(X * X + Y * Y);
							data.set_height(Vector3(gridX+X,0,gridY+Y),brushhight - amountToErode/(dist+1))
											
				if debugSwitch:
					var debugg = Label3D.new()
					debugg.text = "test123"
					debugg.pixel_size =  0.005
					debugg.billboard = BaseMaterial3D.BILLBOARD_ENABLED
					add_child(debugg)
					debugg.transform.origin = Vector3(gridX,curHight+1.5,gridY)
					
					dropid
					text += "id:" + str(dropid) + "\n"
					text += "dh:" + str(snapped(deltaHeight,0.001)) + "\n"
					text += "S:" + str(snapped(sediment,0.001)) + "\n"
					text += "SC:" + str(snapped(sedimentCapacity,0.001)) + "\n"
					text += "speed:" + str(snapped(speed,0.001)) + "\n"
					text += "wat:" + str(snapped(water,0.001)) + "\n"
					debugg.text = text
					lables.append(debugg)
					
				speed = sqrt(max(speed * speed - deltaHeight * gravity,0))
				water *= (1 - evaporateSpeed)
		data.update_maps(Terrain3DRegion.TYPE_HEIGHT)
	

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
