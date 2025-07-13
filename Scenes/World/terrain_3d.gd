extends Terrain3D

var seed = 1

func _ready() -> void:
	print("terrain ready")
	GlobalSignals.connect("GenereateNewRegion",generateRegion)

func generateRegion(pos:Vector3):
	print(pos)
	var existingRegions = data.get_regions_all()
	
	
	var RegionPos:Vector3
	RegionPos.x = floor(pos.x/512)
	RegionPos.z = floor(pos.z/512)
	
	print(RegionPos)
	print(existingRegions)
	print()
	
	if(not existingRegions.has(Vector2i(RegionPos.x,RegionPos.z))):
		RegionPos = Vector3(RegionPos.x*512 + 256,0,RegionPos.z*512 + 256)
		
		var noise1 := FastNoiseLite.new()
		noise1.seed = seed
		noise1.frequency = 1.0/25000 # big mountians
		var noise1Mul = 1
		
		var noise2 := FastNoiseLite.new()
		noise2.seed = seed+1
		var noise2Mul = 0.2 # smaler hills
		noise2.frequency = 1/5000
		
		var noise3 := FastNoiseLite.new()
		noise3.seed = seed+2
		var noise3Mul = 0.01 # small dips and bips
		noise2.frequency = 1/1000
		
		var img: Image = Image.create_empty(512, 512, false, Image.FORMAT_RF)
		for x in img.get_width():
			for y in img.get_height():
				var xo = x + RegionPos.x
				var yo = y + RegionPos.z
				img.set_pixel(x, y,Color((noise1.get_noise_2d(xo, yo)*noise1Mul) + (noise2.get_noise_2d(xo, yo)*noise2Mul)  + (noise3.get_noise_2d(xo, yo)*noise3Mul), 0., 0., 1.))
		region_size = 512
		data.import_images([img, null, null], RegionPos, 0, 500)
		
