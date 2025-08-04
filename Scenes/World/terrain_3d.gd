extends Terrain3D

var Gameseed = Time.get_unix_time_from_system()#0 #402
const set_region_size = 1024
var max_distance = 32 # in chunks

var threads:Array
var chunks:Dictionary
var noise = FastNoiseLite.new()

var mapdirectory = "res://Scenes/World/TerrainData/"
var tempdirectory = "res://Scenes/World/Temp/"

var outputmutex = Mutex.new()
var output_regions:Array 
var output:Array 

var checkCoordinates:Array
var wip_chunks:Array

func _ready() -> void:
	GlobalSignals.connect("GenereateNewRegion",generateRegion)
	
	checkCoordinates  = spiral_coordinates(max_distance)

	region_size = set_region_size
	noise.seed = Gameseed
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
		
		regionstring[i] = tempdirectory + "terrain3d" + posStringX + posStringY + ".res"
		
	# checks if these regions exist based on the strings and starts a thread that will create that region if it dosent or changes the poth string to the correct local of the allrady existing region.
	var region_threads = []
	for i in range(4):
		if not FileAccess.file_exists(regionstring[i].replace(tempdirectory,mapdirectory)):
			threads.append(Thread.new())
			threads[threads.size()-1].start(runNoise.bind(region[i]*region_size),0)
			region_threads.append(threads[threads.size()-1])
		else:
			regionstring[i] = regionstring[i].replace(tempdirectory,mapdirectory)
		
	# waits for the threads to be dont generating the regions
	var done = true
	for t:Thread in region_threads:
		t.wait_to_finish()
	print("regions generated")
	
	# takes the 4 regions for that chunk and turns them into a single image to be processed by the rain.

	var size = Vector2i(region_size,region_size)
	var full_size = size * 2
	var stiched = Image.create(full_size.x, full_size.y, false, Image.FORMAT_RF)


	var imgs = [
		load(regionstring[0]).height_map,
		load(regionstring[1]).height_map,
		load(regionstring[2]).height_map,
		load(regionstring[3]).height_map]

	
	for t in regionstring:
		DirAccess.remove_absolute(t)

	var positions = [
		Vector2i(0, 0),
		Vector2i(size.x, 0),
		Vector2i(0, size.y),
		Vector2i(size.x, size.y)]

	for i in range(4):
		stiched.blit_rect(imgs[i], Rect2i(Vector2i.ZERO, size), positions[i])
	
	var iterations = region_size*2000
	for i in range(iterations):
		#if i % (iterations/100) == 0:
			#print(ceil((float(i)/iterations)*100))
			
		var posX = randi_range(region_size/2,region_size+region_size/2)
		var posY = randi_range(region_size/2,region_size+region_size/2)
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
		outputmutex.lock()
		output_regions.append(tempregion)
		outputmutex.unlock()
	return
	
var framecounter = 0
func _process(_delta: float) -> void:

	# fetches the output from the threads
	outputmutex.lock()
	output.append_array(output_regions.duplicate())
	output_regions.clear()
	outputmutex.unlock()
	
	# lodas the regions one per frame to prevent laggspikes
	
	if Input.is_action_just_pressed("debug2"):
		data.load_directory(mapdirectory)
		
	# every 1000 frames check to upudate chunks
	if framecounter < 120:
		framecounter += 1
	else:
		framecounter = 0
		
		if output.size() > 0:
			var x:Terrain3DRegion = output.pop_back()
			data.add_region(x,true)
			data.save_region(x.location,mapdirectory)
#	if framecounter == 50:
#		
		
	if Input.is_action_just_pressed("debugg"):
		print("running regions ",wip_chunks.size())
		var regionstring = ["","","",""]
		var region:Array
		for pos in checkCoordinates:
			pos *= region_size
			var chunkPos = floor((pos-Vector2(region_size/2,region_size/2))/region_size)*region_size
			region = [null,null,null,null]
			region[0] = floor((chunkPos + Vector2(0,0))/region_size)
			region[1] = floor((chunkPos + Vector2(region_size,0))/region_size)
			region[2] = floor((chunkPos + Vector2(0,region_size))/region_size)
			region[3] = floor((chunkPos + Vector2(region_size,region_size))/region_size)
			
			for i in range(4):
				var posStringX
				if region[i].x >= 0:
					posStringX = "_" + str(int(region[i].x)).pad_zeros(2)
				else:
					posStringX = str(int(region[i].x)).pad_zeros(2)
					
				var posStringY
				if region[i].y >= 0:
					posStringY = "_" + str(int(region[i].y)).pad_zeros(2)
				else:
					posStringY = str(int(region[i].y)).pad_zeros(2)
				
				regionstring[i] = mapdirectory + "terrain3d" + posStringX + posStringY + ".res"
		
			var is_done = true
			for i in range(4):
				if not FileAccess.file_exists(regionstring[i]):
					is_done = false
			if is_done == false:
				var is_not_wip = true
				for regionpos in region:
					if wip_chunks.has(regionpos):
						wip_chunks.erase(regionpos)
						is_not_wip = false
				if is_not_wip:
					if true:#wip_chunks.size() < 4:
						wip_chunks.append_array(region)
						generateRegion(Vector3(pos.x,0,pos.y))
						print("starting ",wip_chunks)
					break
			#else:
			#	if wip_chunks.size() > 0:
			#		print("clearing ",wip_chunks)
			#		for r in region:
			#			if wip_chunks.has(r):
			#				pass
			#				#wip_chunks.erase(r)
			#		print("cleared ", wip_chunks)



func runNoise(Pos:Vector3 = Vector3(0,0,0)):
		var img: Image = Image.create_empty(region_size, region_size, false, Image.FORMAT_RF)
		var imgx = img.get_height()
		var imgy = img.get_width()
		for x in imgx:
			for y in imgy:
				var hight = noise.get_noise_2d(x + Pos.x, y + Pos.z)*500
				if hight < 0: hight = -pow(hight,1.5)
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
			
		var savestring = tempdirectory + "terrain3d" + posStringX + posStringY + ".res"
		var region = Terrain3DRegion.new()
		
		region.region_size = region_size
		region.location = Vector2i(floor(Pos.x/region_size),floor(Pos.z/region_size))
		region.set_map(Terrain3DRegion.TYPE_HEIGHT,img)
		region.save(savestring)
		return

# credit ChatGPT because im lazy and pre creating these is kinda smart ngl
func spiral_coordinates(distance: int) -> Array:
	var coords = []
	var x := 0
	var y := 0
	var dx := 1
	var dy := 0
	var steps := 1

	coords.append(Vector2(x, y))

	while steps <= distance * 2:
		for _i in range(2): # Every 2 turns, increase step size
			for _j in range(steps):
				x += dx
				y += dy
				if abs(x) <= distance and abs(y) <= distance:
					coords.append(Vector2(x, y))
			# Turn right
			var temp = dx
			dx = -dy
			dy = temp
		steps += 1

	return coords

func _exit_tree() -> void:
	for t:Thread in threads:
		t.wait_to_finish()
