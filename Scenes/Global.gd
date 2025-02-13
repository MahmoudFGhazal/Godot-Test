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

func cutScene(caminho: String = ""):
	var dados = lerjson(caminho)
	var actions = dados["actions"]
	inCut = true
	
	for action_group in actions:
		for action_data in action_group:
			executeAction(action_data)
		
		await await_all(action_group.size())
	inCut = false

var completed_count = 0

func await_all(size):
	var on_completed = func():
		completed_count+=1
	
	self.connect("completed", on_completed)
	
	while completed_count < size:
		await self.completed
		
	completed_count = 0
	self.disconnect("completed", on_completed)

signal completed

func executeAction(action_data):
	var character = action_data["character"]
	var action = action_data["action"]
	
	if character == "player":
		await executePlayerAction(action)
	elif character.is_valid_int():
		var NPC = searchNPC(character)
		print(NPC)
		await player.ControlTimer(0.1)
	
	emit_signal("completed")

func executePlayerAction(action_data):
	var i = 0
	while i < action_data.length():
		match action_data[i]:
				'd':
					await controlPlayer(Vector2(1,0))
				'a':
					await controlPlayer(Vector2(-1,0))
				's':
					await controlPlayer(Vector2(0,1))
				'w':
					await controlPlayer(Vector2(0,-1))
				'l':
					await controlPlayer(Vector2(1,0), true)
				'j':
					await controlPlayer(Vector2(-1,0), true)
				'k':
					await controlPlayer(Vector2(0,1), true)
				'i':
					await controlPlayer(Vector2(0,-1), true)
				'e':
					var time = ""
					i+=1
					while i < action_data.length() and (action_data[i].is_valid_int() or action_data[i] == "."):
						time += action_data[i]
						i+=1
					var timeWait: float = convertType(time, Types.float)
					await wait(timeWait, searchTimerID())
					continue
				'<':
					var text = []
					i+=1
					while i < action_data.length() and action_data[i] != '>':
						text.append(action_data[i])
						i+=1
					text.append(action_data[i])
					await player.callDialog(text)
		i+=1

func executeNPCAction(NPC, action_data):
	pass

func controlPlayer(dir:Vector2, run:bool = false):
	player.statesControl(dir, run)
	while player.playerstate != player.State.Idle:
		await player.get_tree().process_frame

func searchNPC(id):
	var npcs_node = get_tree().current_scene.get_node("Npcs")
	for npc in npcs_node.get_children():
		if npc.ID == id:
			return npc
	return null

enum Types{array, string, int, float}

func convertType(variable, newType:Types):
	if variable == null:
		return
	
	var intermediate = variable
	
	if typeof(variable) == TYPE_ARRAY:
		intermediate = ""
		for p in variable:
			intermediate += str(p)
	elif typeof(variable) != TYPE_STRING:
		intermediate = str(variable)
	
	match newType:
		Types.array:
			return intermediate.split(",") if "," in intermediate else intermediate.split(" ")
		Types.string:
			return intermediate
		Types.int:
			return int(intermediate) if intermediate.is_valid_integer() else 0
		Types.float:
			return float(intermediate) if intermediate.is_valid_float() else 0.0
	
	return variable

var timers:Dictionary = {}

func wait(time: float, id: int):
	if timers.has(id):
		if !timers[id].is_stopped():
			await timers[id].timeout
		return
	else:
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.one_shot = true
		timers[id] = new_timer
	
	var timer = timers[id]
	timer.stop()
	timer.wait_time = time
	timer.start()
	await timer.timeout
	
	timers.erase(id)
	timer.queue_free()

func searchTimerID():
	var cont = 0
	while(true):
		if !timers.has(cont):
			break
		cont+=1
	return cont
