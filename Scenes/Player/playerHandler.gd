extends Node3D

@onready var cam = $Body/Head/Camera3D


var currentItemID = 0

func _ready() -> void:
	print(get_path())
	cam.current = is_multiplayer_authority()

func _enter_tree():
	set_multiplayer_authority(name.to_int())  # Set the multiplayer authority for the player
