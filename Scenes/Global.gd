class_name global extends Node

var player: Player

var ScenePath = "res://Scenes/Scenes/"

var post = Vector2i(160, 80)
var map = "teste2"

var currentMap: Node

var inCut:bool = false
var paused:bool = false

func _ready() -> void:
	initWorld(map, post)

func initWorld(toSceneName: String, pos: Vector2i):
	var player_scene = preload("res://Scenes/Entities/Characters/Player/Player.tscn")
	player = player_scene.instantiate()
		
	var fullPath:String = ScenePath + toSceneName + ".tscn"
	var new_scene = load(fullPath)
	
	if new_scene is PackedScene:
		var main = getManager()
		currentMap = new_scene.instantiate()
		
		main.call_deferred("add_child", currentMap)
		
		main.call_deferred("add_child", player)
		player.position = pos
		
		
		
	else:
		push_error("Falha ao carregar")

func print_tre(node: Node = null, indent: int = 0) -> void:
	if node == null:
		node = get_tree().root  # Define o nó inicial como root, se não for fornecido
	var indentation = "  ".repeat(indent)
	print(indentation + node.name)  # Imprime o nome do nó com indentação
	for child in node.get_children():
		print_tre(child, indent + 1)

#Teoricamente está certo
func changeScene(from: Node2D, toSceneName: String, pos: Vector2i):
	var fullPath = ScenePath + toSceneName + ".tscn"
	var new_scene = load(fullPath)
	
	if new_scene is PackedScene:
		var main = getManager()
		currentMap = new_scene.instantiate()
		player.position = pos
		
		main.call_deferred("remove_child", from)
		main.call_deferred("add_child", currentMap)
		
		inCut = false
	else:
		push_error("Falha ao carregar")

func getManager():
	return get_tree().root.get_node("Manager Scene")
