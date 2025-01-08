extends Node

var grids:Dictionary

func _ready() -> void:
	GlobalSignals.connect("newGridRequested",spawnNewGrid)
	
	
	
	
	
	
func spawnNewGrid(playerId, Pos):
	var grids_size = grids.size()
	var newgrid = load("res://Scenes/Grid/Grid.tscn").instantiate()
	newgrid.transform.origin = Pos
	newgrid.name = str(grids_size)
	add_child(newgrid,true)
	
	grids[grids_size] = {
		"owner": playerId,
		"node": newgrid,
		"name": grids_size
	}
