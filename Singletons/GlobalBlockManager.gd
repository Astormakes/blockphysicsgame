extends Node

const var blockcatalog: Dictionary = {}

var up = Vector3.UP
var down = Vector3.DOWN
var left = Vector3.LEFT
var right = Vector3.RIGHT
var forward = Vector3.FORWARD
var back = Vector3.BACK


# Initialize blocks in the catalog
func _ready():
	initialize_block_catalog()

func _process(_delta: float) -> void:
	pass

# Function to populate the block catalog with data
func initialize_block_catalog():
	blockcatalog[0] = {
		"showName": "Metal Block",
		"path": "",
		"mesh": "res://Meshes/DefaultBoxMesh.tres",
		"material": "res://Materials/MultiMeshBlockTexture.tres",
		"color": Color(110,110,110,255)/255,
		"type": "block",
		"cost": 10,
		"mass": 7,
		"maxHP": 500,
		"size": Vector3(0.2,.2,0.2)
	}
	blockcatalog[1] = {
		"showName": "Alu Block",
		"path": "",
		"mesh": "res://Meshes/DefaultBoxMesh.tres",
		"material": "res://Materials/MultiMeshBlockTexture.tres",
		"color": Color(200,200,200,255)/255,
		"type": "block",
		"cost": 25,
		"mass": 3,
		"maxHP": 200,
		"size": Vector3(0.2,.2,0.2)
	}
	blockcatalog[2] = {
		"showName": "Wood Block",
		"path": "",
		"mesh": "res://Meshes/DefaultBoxMesh.tres",
		"material": "res://Materials/MultiMeshBlockTexture.tres",
		"color": Color(150,90,60,255)/255,
		"type": "block",
		"cost": 5,
		"mass": 1,
		"maxHP": 30,
		"size": Vector3(0.2,.2,0.2)
	}
	blockcatalog[3] = {
		"showName": "Lead Block",
		"path": "",
		"mesh": "res://Meshes/DefaultBoxMesh.tres",
		"material": "res://Materials/MultiMeshBlockTexture.tres",
		"color": Color(20,30,35,255)/255,
		"type": "block",
		"cost": 10,
		"mass": 25,
		"maxHP": 200,
		"size": Vector3(0.2,.2,0.2)
	}	
	blockcatalog[4] = {
		"showName": "Metal 1x1x1 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x1 Slope.tres",
		"shape": "res://prebuilds/1x1x1_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(110,110,110,255)/255,
		"type": "shape",
		"cost": 7,
		"mass": 3.5,
		"maxHP": 30,
		"size": Vector3(0.2,0.2,0.2)
	}
	blockcatalog[5] = {
		"showName": "Alu 1x1x1 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x1 Slope.tres",
		"shape": "res://prebuilds/1x1x1_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(200,200,200,255)/255,
		"type": "shape",
		"cost": 20,
		"mass": 1.5,
		"maxHP": 100,
		"size": Vector3(0.2,0.2,0.2)
	}
	blockcatalog[6] = {
		"showName": "Wood 1x1x1 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x1 Slope.tres",
		"shape": "res://prebuilds/1x1x1_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(150,90,60,255)/255,
		"type": "shape",
		"cost": 4,
		"mass": 0.25,
		"maxHP": 30,
		"size": Vector3(0.2,0.2,0.2)
	}
	blockcatalog[7] = {
		"showName": "Metal 1x1x2 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x2 Slope.obj",
		"shape": "res://prebuilds/1x1x2_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(110,110,110,255)/255,
		"type": "shape",
		"cost": 13,
		"mass": 7,
		"maxHP": 500,
		"size": Vector3(0.4,0.2,0.2)
	}
	blockcatalog[8] = {
		"showName": "Alu 1x1x2 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x2 Slope.obj",
		"shape": "res://prebuilds/1x1x2_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(200,200,200,255)/255,
		"type": "shape",
		"cost": 35,
		"mass": 3,
		"maxHP": 200,
		"size": Vector3(0.4,0.2,0.2)
	}
	blockcatalog[9] = {
		"showName": "Wood 1x1x2 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x2 Slope.obj",
		"shape": "res://prebuilds/1x1x2_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(150,90,60,255)/255,
		"type": "shape",
		"cost": 7,
		"mass": 1,
		"maxHP": 30,
		"size": Vector3(0.4,0.2,0.2)
	}
	blockcatalog[10] = {
		"showName": "Metal 1x1x3 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x3 Slope.obj",
		"shape": "res://prebuilds/1x1x3_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(110,110,110,255)/255,
		"type": "shape",
		"cost": 7,
		"mass": 10.5,
		"maxHP": 30,
		"size": Vector3(0.6,0.2,0.2)
	}
	blockcatalog[11] = {
		"showName": "Alu 1x1x3 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x3 Slope.obj",
		"shape": "res://prebuilds/1x1x3_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(200,200,200,255)/255,
		"type": "shape",
		"cost": 20,
		"mass": 7.5,
		"maxHP": 100,
		"size": Vector3(0.6,0.2,0.2)
	}
	blockcatalog[12] = {
		"showName": "Wood 1x1x3 Slope",
		"path": "",
		"mesh": "res://Meshes/1x1x3 Slope.obj",
		"shape": "res://prebuilds/1x1x3_Slope_ColisionShape.tscn",
		"material": "res://Materials/defaultStructualMaterial.tres",
		"color": Color(150,90,60,255)/255,
		"type": "shape",
		"cost": 4,
		"mass": 1.5,
		"maxHP": 30,
		"size": Vector3(0.6,0.2,0.2),
		"flows": [up,forward,left,right]
	}
