extends Control

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var world: PackedScene = load("res://Scenes/World/World.tscn")
var player_scene: PackedScene = load("res://Scenes/Player/player.tscn")


var world_scene: Node = null

var players = [] # ment for later, checking if a player is nearing a ungenerated region
var playerpositions = []

var regionSize = 1024

func _process(_delta: float) -> void:
	playerpositions.clear()
	for x:Node3D in players:
		playerpositions.append(x.get_child(0).global_position)

# Host a server
func _on_host(port: int) -> void:
	
	if peer.create_server(port) != OK:
		print("Failed to start server.")
		return
	
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.multiplayer_peer = peer
	
	# Load the world for the host
	world_scene = world.instantiate()
	add_child(world_scene)
	
	# Add the host player
	add_player(multiplayer.get_unique_id())
# Join as a client
func _on_join(ip: String, port: int) -> void:
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Client ID:", multiplayer.get_unique_id())
	
	# Load the world scene when connected
	world_scene = world.instantiate()
	add_child(world_scene)
	
	multiplayer.multiplayer_peer = peer
	print("Connected to server at", ip, ":", port)

# Add a player to the game
func add_player(id: int):
	if world_scene == null:
		world_scene = world.instantiate()
		add_child(world_scene)
	
	var player = player_scene.instantiate()
	player.name = str(id)
	player.transform.origin.y += 25 #Vector3(5000,25,5000)
	world_scene.add_child(player) # Add to the world scene
	players.append(player)
	
# Handle a new player connection (server only)
func on_peer_connected(id: int):
	print("Player connected with ID:", id)
	add_player(id)

# Handle player disconnection (server only)
func on_peer_disconnected(id: int):
	print("Player disconnected with ID:", id)
	var player = world_scene.get_node_or_null(str(id))
	if player:
		player.queue_free()
