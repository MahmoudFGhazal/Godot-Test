extends CharacterBody2D
class_name Player

signal Player_entered_trigger
var entering_trigger = false

const spd = 3.85
const run_spd = 6
const jump_spd = 4.5
const TileSize = 80
var jumping = false

@onready var anitree = $AnimationTree
@onready var anistate = anitree.get("parameters/playback")
@onready var ray = $RayCasts/RayCast2D
@onready var ledge_ray = $RayCasts/LedgeRayCast2D
@onready var Iray = $RayCasts/InterectRayCast2D
@onready var action_ray = $RayCasts/ActionRayCast2D
@onready var water_ray = $RayCasts/WaterRayCast2D
@onready var shadow = $Shadow
@onready var menu = $UI/Menu
@onready var camera = $Camera2D
@onready var sprite = $Sprite2D
@onready var collisionShape = $CollisionShape2D
@onready var fadeAni = $Camera2D/Transition/AnimationFade
@onready var texto = $UI/Texto

var hasFadedtoBlack = false
var hasFadedtoNormal = false

enum collisions {world, ledge, interect, action, water}
enum States {Idle, Turn, Walk, Run, Swim}
enum FaceStates {left, right, up, down}
var playerstate = States.Idle
var facingstate = FaceStates.down 

var posinicial = Vector2(0,0)
var dir = Vector2(0,1)
var nextTile = 0.0

func _ready():
	sprite.visible = true
	posinicial = position
	anistate.travel("Parado")

func _physics_process(delta):
	updateAnimation()
	if entering_trigger:
		transition(delta)
	elif playerstate == States.Turn:
		pass
	elif playerstate == States.Idle:
		inputPlayer()
	elif playerstate == States.Walk or playerstate == States.Run:
		move(delta)
	else:
		playerstate = States.Idle

func updateAnimation():
	var blendPosition = getDirectionFace()

	if (TestCollision(collisions.world) or (TestCollision(collisions.water) and playerstate != States.Swim)) and playerstate != States.Turn:
		anitree.set("parameters/Parado/blend_position", blendPosition)
		anistate.travel("Parado")
		return
	
	
	match playerstate:
		States.Idle:
			anitree.set("parameters/Parado/blend_position", blendPosition)
			anistate.travel("Parado")
		States.Walk:
			anitree.set("parameters/Walk/blend_position", blendPosition)
			anistate.travel("Walk")
		States.Turn:
			anitree.set("parameters/Turn/blend_position", blendPosition)
			anistate.travel("Turn")
		States.Run:
			anitree.set("parameters/Run/blend_position", blendPosition)
			anistate.travel("Run")
		_:
			anistate.travel("Parado")

func inputPlayer():
	if Global.inCut:
		return
	
	var inputdir = Vector2(0, 0)
	if inputdir.y == 0:
		inputdir.x = int(Input.is_action_pressed("Direita")) - int(Input.is_action_pressed("Esquerda"))
	if inputdir.x == 0:
		inputdir.y = int(Input.is_action_pressed("Baixo")) - int(Input.is_action_pressed("Cima"))
	
	if Input.is_action_just_pressed("Teste"):
		fadeAni.play("FadetoBlack")
		fadeAni.play("FadetoNormal")
	
	if inputdir != Vector2.ZERO:
		if Input.is_action_pressed("Voltar"):
			statesControl(inputdir, true)
		else:
			statesControl(inputdir)
	else:
		if Input.is_action_just_pressed("Avançar"):
			if(TestCollision(collisions.action)):
				var collider = action_ray.get_collider()
				if collider and collider.has_method("action"):
					collider.action()
		playerstate = States.Idle
		
	updateAnimation()

func statesControl(direc:Vector2, run:bool = false):
	dir = direc
	
	posinicial = position
	if run:
		needtoturn()
		playerstate = States.Run
	else:
		if needtoturn():
			playerstate = States.Turn
			return
		playerstate = States.Walk
		

func needtoturn():
	var oldfacingdirection
	if dir.x < 0:
		oldfacingdirection = FaceStates.left
	elif dir.x > 0:
		oldfacingdirection = FaceStates.right
	elif dir.y < 0:
		oldfacingdirection = FaceStates.up
	elif dir.y > 0:
		oldfacingdirection = FaceStates.down
		
	if facingstate != oldfacingdirection:
		facingstate = oldfacingdirection
		return true
	else:
		
		return false

func finishedturning():
	playerstate = States.Idle

func move(delta):
	
	if TestCollision(collisions.interect):
		var collider = Iray.get_collider()
		if collider is Area2D:
			if !entering_trigger:
				entering_trigger = true
				hasFadedtoBlack = false
				hasFadedtoNormal = false
	elif (TestCollision(collisions.ledge) and facingstate == FaceStates.down) or jumping:
		#se o player começar o pulo antes de terminar o movimento
		if !jumping:
			position.x = ceil(position.x / 80) * 80
			position.y = ceil(position.y / 80) * 80
			posinicial = position
			nextTile = 0.0
		
		ray.global_position = Vector2(TileSize/2.0,TileSize/2.0) + posinicial + (2 * TileSize * dir)
		shadow.visible = true
		#para ver se tem alguma coisa depois do pulo
		if TestCollision(collisions.world):
			shadow.visible = false
			position = posinicial
			jumping = false
			playerstate = States.Idle
			ray.position = Vector2(8,8)
			return
		collisionShape.global_position = Vector2(TileSize/2.0,TileSize/2.0) + posinicial + (2 * TileSize * dir)
		
		nextTile += jump_spd * delta
		
		if nextTile >= 2.0:
			position = posinicial + (2 * TileSize * dir)
			nextTile = 0.0
			playerstate = States.Idle
			shadow.visible = false
			jumping = false
			sprite.position = Vector2(8, -1)
			ray.position = Vector2(8, 8)
			collisionShape.position = Vector2(8, 8)
			return
		else:
			jumping = true
			shadow.visible = true
			position = posinicial + TileSize * dir * nextTile
			var input = dir.y * 8 * nextTile 
			sprite.position.y = (- 5 - 1.2 * input + 0.087 * pow(input, 2))
	elif !TestCollision(collisions.world) and (!TestCollision(collisions.water) or playerstate == States.Swim) or (playerstate == States.Walk and nextTile != 0):
		nextTile += run_spd * delta if playerstate == States.Run else spd * delta
		
		if nextTile >= 1.0:
			position = posinicial + (TileSize * dir)
			nextTile = 0.0
			playerstate = States.Idle
			return
		else:
			position = posinicial + (TileSize * dir * nextTile)
	else:
		playerstate = States.Idle
		nextTile = 0.0
		posinicial = position
		
	updateAnimation()

func TestCollision(type:collisions):
	var nextstep:Vector2 = dir * 9
	
	match type:
		collisions.world:
			ray.target_position = nextstep
			ray.force_raycast_update()
			if ray.is_colliding():
				return true
		collisions.interect:
			Iray.target_position = nextstep
			Iray.force_raycast_update()
			if Iray.is_colliding():
				return true
		collisions.ledge:
			ledge_ray.target_position = nextstep / 1.125
			ledge_ray.force_raycast_update()
			if ledge_ray.is_colliding():
				return true
		collisions.action:
			action_ray.target_position = getDirectionFace() * 9
			action_ray.force_raycast_update()
			if action_ray.is_colliding():
				return true
		collisions.water:
			water_ray.target_position = nextstep
			water_ray.force_raycast_update()
			if water_ray.is_colliding():
				return true
	
	return false

func getDirectionFace():
	match facingstate:
		FaceStates.left:
			return Vector2(-1, 0)
		FaceStates.right:
			return Vector2(1, 0)
		FaceStates.up:
			return Vector2(0, -1)
		FaceStates.down:
			return Vector2(0, 1)

func transition(delta):
	nextTile += spd * delta
	if nextTile >= 1:
		fadeBlack()
		
		await Global.wait(1.0)
		
		fadeNormal()
		
		if entering_trigger:
			nextTile = 0.0
			entering_trigger = false
	else:
		position = posinicial + (TileSize * dir * nextTile)

func fadeBlack():
	if !hasFadedtoBlack:
		Global.inCut = true
		hasFadedtoBlack = true
		fadeAni.play("FadetoBlack")
		sprite.visible = false

func fadeNormal():
	var waitID = Global.searchTimerID()
	if !hasFadedtoNormal:
		hasFadedtoNormal = true
		facingstate = FaceStates.down
		playerstate = States.Idle
		updateAnimation()
		emit_signal("Player_entered_trigger")
		sprite.visible = true
		await Global.wait(1.0,waitID)
		fadeAni.play("FadetoNormal")
		await Global.wait(0.5,waitID)
		Global.inCut = false
	emit_signal("textFinished")

func callDialog(text):
	texto.process_mode = Node.PROCESS_MODE_INHERIT
	texto.visible = true
	texto.Texto(text)
	await textFinished

signal textFinished

func emitSignalText():
	emit_signal("textFinished")
