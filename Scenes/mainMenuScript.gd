extends Control

@onready var Adressfied = $TextEdit

var peer = ENetMultiplayerPeer.new()
var address
var port = 16969


func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("enter"):
		_on_join_pressed()


func _on_host_pressed() -> void:
	GlobalServerHandler._on_host(int(port))
	queue_free()

func _on_join_pressed() -> void:
	GlobalServerHandler._on_join(Adressfied.text,port)
	queue_free()
