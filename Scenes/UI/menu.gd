extends Control

@onready var arrow = $NinePatchRect/TextureRect
var currentOp = 0

func _process(_unused_delta):
	if Input.is_action_just_pressed("Pause") and !Global.paused and !Global.inCut:
		pause()
	elif Input.is_action_just_pressed("Pause") and Global.paused:
		resume()
	elif Global.paused:
		Menu()

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
	

func resume():
	get_tree().paused = false
	visible = false
	Global.paused = false
	
func pause():
	get_tree().paused = true
	visible = true
	Global.paused = true
	
