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
@onready var timer = $Timer
@onready var fadeAni = $Camera2D/Transition/AnimationFade
@onready var texto = $UI/Texto

var hasFadedtoBlack = false
var hasFadedtoNormal = false

enum collisions {world, ledge, interect, action, water}
enum State {Idle, Turn, Walk, Run, Swim}
enum Facing {left, right, up, down}
var playerstate = State.Idle
var facingstate = Facing.down 

var posinicial = Vector2(0,0)
var dir = Vector2(0,0)
var nextTile = 0.0

func _ready():
	sprite.visible = true
	posinicial = position
	anistate.travel("Parado")

func _physics_process(delta):
	if entering_trigger:
		transition(delta)
	elif playerstate == State.Turn:
		pass
	elif playerstate == State.Idle:
		inputPlayer()
	elif playerstate == State.Walk or playerstate == State.Run:
		move(delta)
	else:
		playerstate = State.Idle

func updateAnimation():
	var blendPosition = getDirectionFace()

	if (TestCollision(collisions.world) or (TestCollision(collisions.water) and playerstate != State.Swim)) and playerstate != State.Turn:
		anitree.set("parameters/Parado/blend_position", blendPosition)
		anistate.travel("Parado")
		return
	
	
	match playerstate:
		State.Idle:
			anitree.set("parameters/Parado/blend_position", blendPosition)
			anistate.travel("Parado")
		State.Walk:
			anitree.set("parameters/Walk/blend_position", blendPosition)
			anistate.travel("Walk")
		State.Turn:
			anitree.set("parameters/Turn/blend_position", blendPosition)
			anistate.travel("Turn")
		State.Run:
			anitree.set("parameters/Run/blend_position", blendPosition)
			anistate.travel("Run")
		_:
			anistate.travel("Parado")

func inputPlayer():
	if Global.inCut:
		return
	
	
	if dir.y == 0:
		dir.x = int(Input.is_action_pressed("Direita")) - int(Input.is_action_pressed("Esquerda"))
	if dir.x == 0:
		dir.y = int(Input.is_action_pressed("Baixo")) - int(Input.is_action_pressed("Cima"))
	
	if Input.is_action_just_pressed("Teste"):
		fadeAni.play("FadetoBlack")
		await ControlTimer(1.0)
		fadeAni.play("FadetoNormal")
	
	if dir != Vector2.ZERO:
		if Input.is_action_pressed("Voltar"):
			needtoturn()
			posinicial = position
			playerstate = State.Run
		elif needtoturn():
			playerstate = State.Turn
		else:
			posinicial = position
			playerstate = State.Walk
	else:
		if Input.is_action_just_pressed("Avançar"):
			if(TestCollision(collisions.action)):
				var collider = action_ray.get_collider()
				if collider and collider.has_method("action"):
					collider.action()
		playerstate = State.Idle
		
	updateAnimation()

func needtoturn():
	var oldfacingdirection
	if dir.x < 0:
		oldfacingdirection = Facing.left
	elif dir.x > 0:
		oldfacingdirection = Facing.right
	elif dir.y < 0:
		oldfacingdirection = Facing.up
	elif dir.y > 0:
		oldfacingdirection = Facing.down
		
	if facingstate != oldfacingdirection:
		facingstate = oldfacingdirection
		return true
	else:
		facingstate = oldfacingdirection
		return false

func finishedturning():
	playerstate = State.Idle

func move(delta):
	updateAnimation()
	
	if TestCollision(collisions.interect):
		var collider = Iray.get_collider()
		if collider is Area2D:
			if !entering_trigger:
				entering_trigger = true
				hasFadedtoBlack = false
				hasFadedtoNormal = false
	elif (TestCollision(collisions.ledge) and facingstate == Facing.down) or jumping:
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
			playerstate = State.Idle
			ray.position = Vector2(8,8)
			return
		collisionShape.global_position = Vector2(TileSize/2.0,TileSize/2.0) + posinicial + (2 * TileSize * dir)
		
		nextTile += jump_spd * delta
		
		if nextTile >= 2.0:
			position = posinicial + (2 * TileSize * dir)
			nextTile = 0.0
			playerstate = State.Idle
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
	elif !TestCollision(collisions.world) and (!TestCollision(collisions.water) or playerstate == State.Swim) or (playerstate == State.Walk and nextTile != 0):
		nextTile += run_spd * delta if playerstate == State.Run else spd * delta
		
		if nextTile >= 1.0:
			position = posinicial + (TileSize * dir)
			nextTile = 0.0
			playerstate = State.Idle
			return
		else:
			position = posinicial + (TileSize * dir * nextTile)
	else:
		playerstate = State.Idle
		nextTile = 0.0
		posinicial = position

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
		Facing.left:
			return Vector2(-1, 0)
		Facing.right:
			return Vector2(1, 0)
		Facing.up:
			return Vector2(0, -1)
		Facing.down:
			return Vector2(0, 1)

func transition(delta):
	nextTile += spd * delta
	if nextTile >= 1:
		fadeBlack()
		
		await ControlTimer(1.0)
		
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
	if !hasFadedtoNormal:
		hasFadedtoNormal = true
		facingstate = Facing.down
		playerstate = State.Idle
		updateAnimation()
		emit_signal("Player_entered_trigger")
		sprite.visible = true
		await ControlTimer(1.0)
		fadeAni.play("FadetoNormal")
		await ControlTimer(0.5)
		Global.inCut = false

func ControlTimer(time: float):
	if !timer.is_stopped():
		await timer.timeout
		return
	timer.stop()
	timer.wait_time = time
	timer.start()
	await timer.timeout

func callDialog(text):
	texto.process_mode = Node.PROCESS_MODE_INHERIT
	texto.visible = true
	texto.Texto(text)
