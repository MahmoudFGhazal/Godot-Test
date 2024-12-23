extends Control

@onready var arrow = $NinePatchRect/TextureRect
var currentOp = 0

func _ready():
	visible = false
	z_index = 3

func Menu():
	if Input.is_action_just_pressed("Baixo"):
		if currentOp+1 > 5:
			currentOp = 0
		else:
			currentOp+=1
	elif Input.is_action_just_pressed("Cima"):
		if currentOp-1 < 0:
			currentOp = 5
		else:
			currentOp-=1
	arrow.position.y = 6.5 + currentOp * 14
	if Input.is_action_just_pressed("Avançar"):
		match currentOp:
			0:
				print("pokedex")
			1:
				print("pokemon")
			2:
				print("bag")
			3:
				print("nome")
			4:
				print("save")
			5:
				print("opcoes")
			6:
				print("sair")
	if Input.is_action_just_pressed("Pause") or Input.is_action_just_pressed("Voltar"):
		visible = false
		var player = get_parent()
		var anitree = player.get_node("AnimationTree") 
		anitree.active = true
		manager_scene.menuActive = false
		await get_tree().create_timer(1).timeout
