class_name global extends Node

var player: Player

var ScenePath = "res://Scenes/Scenes/"

var post = Vector2i(160, 80)
var map = "teste"

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
		
		main.remove_child(from)
		from.queue_free()
		main.add_child(currentMap)
	else:
		push_error("Falha ao carregar")

func getManager():
	return get_tree().root.get_node("Manager Scene")

#Instruções
#\n = mudar caixa de dialogo
#\d = andar direita
#\b = andar baixo
#\e = andar esquerda
#\c = andar cima
#Controlar Npcs?
#\t = texto e aparecer caixa de dialogo
#"" = dialogo depois do \t
#\e = emojis Obs: futuramente
#\w = esperar
#como fazer para algo fazer duas coisas ao mesmo temPo? <- talvez uma função especifica para os npcs?

func cutScene(actions: String = ""):
	inCut = true
	var i = 0
	while i < actions.length():
		if actions[i] == '\\':
			i += 1
			match actions[i]:
				'n':
					print("esperar input")
				't':
					var text = []
					while actions[i] != "\\":
						i+=1
						if i < actions.length():
							text.append(actions[i])
						else:
							break
					text = arrayToString(text)
					Dialog(text)
					
		i+=1

func Dialog(text: String = "Aff"):
	player.callDialog(text)
	
func arrayToString(array: Array):
	var s = ""
	for i in array:
		s+=String(i)
	print(s)
	return s
	
