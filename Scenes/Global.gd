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

func lerjson(caminho: String) -> Dictionary:
	var file = FileAccess.open(caminho, FileAccess.READ)
	if file:
		var conteudo = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(conteudo)
		
		if result == OK:
			return json.data
		else:
			print("Erro parsear JSON: ", json.get_error_message())
			return{}
	else:
		print("Arquivo n encotnrado: ", caminho)
		return {}

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
#\d = andar direita
#\b = andar baixo
#\e = andar esquerda
#\c = andar cima
#\l = correr direita
#\k = correr baixo
#\j = correr esquerda
#\i = correr cima
#Controlar Npcs?
#\e = emojis Obs: futuramente
#\w = esperar
#como fazer para algo fazer duas coisas ao mesmo temPo? <- talvez uma função especifica para os npcs?

enum typeActions {none, text, walk}
var currentAction = typeActions.none

func cutScene(caminho: String = ""):
	var dados = lerjson(caminho)
	var actions = dados["actions"]

	inCut = true
	var i = 0
	while i < actions.length():
		match actions[i]:
			'd':
				await controlPlayer(Vector2(1,0))
			'e':
				await controlPlayer(Vector2(-1,0))
			'b':
				await controlPlayer(Vector2(0,1))
			'c':
				await controlPlayer(Vector2(0,-1))
			'l':
				await controlPlayer(Vector2(1,0), true)
			'j':
				await controlPlayer(Vector2(-1,0), true)
			'k':
				await controlPlayer(Vector2(0,1), true)
			'i':
				await controlPlayer(Vector2(0,-1), true)
			'<':
				var text = []
				i+=1
				while actions[i] != '>':
					text.append(actions[i])
					i+=1
				text.append(actions[i])
				await player.callDialog(text)
					
		i+=1
	inCut = false

func controlPlayer(dir:Vector2i, run:bool = false):
	player.statesControl(dir, run)
	while player.playerstate != player.State.Idle:
		await player.get_tree().process_frame

func arrayToString(array: Array):
	var s = ""
	for i in array:
		s+=String(i)
	return s

func wait():
	pass
