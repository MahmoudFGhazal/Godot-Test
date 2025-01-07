class_name ManagerScene extends Node

var player: Player
var player_scene: PackedScene
var ScenePath = "res://Scenes/Scenes/"

var pos = Vector2i(160, 80)
var map = "teste"

func _ready() -> void:
	player_scene = preload("res://Scenes/Entities/Characters/Player/Player.tscn")
	initPlayer(map, pos)
	

func initPlayer(toSceneName: String, pos: Vector2i):
	player = player_scene.instantiate()
	if player == null:
		print("Player não encontrado na cena atual.")
		return
		
	var fullPath:String = (ScenePath + toSceneName + ".tscn")
	var new_scene = load(fullPath)
	
	if new_scene is PackedScene:
		var scene_instance = new_scene.instantiate()
		
		get_tree().root.add_child(scene_instance)
		get_tree().current_scene = scene_instance
		
		get_tree().current_scene.add_child(player)
		player.position = pos
	else:
		push_error("Falha ao carregar")

#Teoricamente está certo
func changeScene(from, toSceneName: String, pos: Vector2i):
	player = from.get_node("Player")
	player.get_parent().remove_child(player)
	print("oi")
	var fullPath = ScenePath + toSceneName + ".tscn"
	var new_scene = load(fullPath)
	
	if new_scene is PackedScene:
		var scene_instance = new_scene.instantiate()
		
		get_tree().root.add_child(scene_instance)
		get_tree().current_scene = scene_instance
		
		get_tree().current_scene.add_child(player)
		player.position = pos
	else:
		push_error("Falha ao carregar")
