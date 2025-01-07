extends Control

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var world: PackedScene = load("res://Scenes/World.tscn")
var player_scene: PackedScene = load("res://Scenes/player.tscn")

var world_scene: Node = null

func _ready() -> void:
	pass

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
	world_scene.add_child(player) # Add to the world scene
	
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
