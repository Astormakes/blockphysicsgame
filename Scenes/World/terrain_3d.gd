extends Terrain3D

var seed = Time.get_unix_time_from_system()

var RegionPos:Vector3

var thread = Thread.new()

var seedoffset = 0

var mutextasklist = Mutex.new()
var mutextaskwork = Mutex.new()

var tasklist:Array
var work:Dictionary

var noise1 := FastNoiseLite.new()
var noise2 := FastNoiseLite.new()
var noise3 := FastNoiseLite.new()

var noise1Mul = 1
var noise2Mul = 0.1 # smaler hills
var noise3Mul = 0.005 # small dips and bips

func _ready() -> void:
	print("Seed ",seed)
	print("terrain ready")
	GlobalSignals.connect("GenereateNewRegion",generateRegion)
	
	region_size = 512 # 256 = 8KM^2 
	
	noise1.seed = seed
	noise1.frequency = 1.0/15000 # big mountians

	noise2.seed = seed+1
	noise2.frequency = 1/4000

	noise3.seed = seed+2
	noise2.frequency = 1/1000
	
	thread.start(runNoise)
	var range = 1
	for x in range(-range,range):
		for y in range(-range,range):
			generateRegion(Vector3(x,0,y)*512)


func _process(delta: float) -> void:
	mutextaskwork.lock()
	for x in work.keys():
		data.import_images([work[x], null, null], x, 0, 1000)
		work.erase(x)
	mutextaskwork.unlock()
	
	if Input.is_action_pressed("debugg"):
		errosion(randi_range(-20,20),randi_range(-50,50))
	
func generateRegion(pos:Vector3):
	#print(pos," recieved pos")
	var existingRegions = data.get_regions_all()
	
	
	RegionPos.x = floor(pos.x/region_size)
	RegionPos.z = floor(pos.z/region_size)
	
	#print(RegionPos)
	#print(existingRegions)
	#print()
	
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
					var hight = (noise1.get_noise_2d(seedoffset+xo, yo)*noise1Mul) + (noise2.get_noise_2d(xo, yo)*noise2Mul)  + (noise3.get_noise_2d(xo, yo)*noise3Mul) + -0.1
					if hight < 0:
						hight = pow(hight+1,3)-1
					img.set_pixel(x, y,Color(hight, 0., 0., 1.))
			mutextaskwork.lock()
			work[Pos] = img
			mutextaskwork.unlock()

func errosion(x,y):
	var curHight = data.get_height(Vector3(x,0,y))
	var Sx = curHight - data.get_height(Vector3(x+1,0,y))
	var Sy = curHight - data.get_height(Vector3(x,0,y+1))
	data.set_height(Vector3(x,0,y),curHight-0.1)
	var vel = 0
	var Posx = x
	var Posy = y
	var Solid = 0.1
	
	for i in range(30):	
		curHight = data.get_height(Vector3(Posx,0,Posy))
		Sx = curHight - data.get_height(Vector3(Posx+1,0,Posy))
		Sy = curHight - data.get_height(Vector3(Posx,0,Posy+1))
			
		vel = abs(Sx)+abs(Sy)
		
		Solid += vel-0.1
		
		Posx += Sx
		Posy += Sy
		
		print("cH:",curHight)
		print("s:",Sx," ",Sy)
		print("p:",Posx," ",Posy)
		print("v",vel)
	
	data.update_maps(Terrain3DRegion.TYPE_HEIGHT)
