extends CharacterBody2D
class_name Player

signal Player_entering_trigger
signal Player_entered_trigger
var entering_trigger = false

const spd = 4
const run_spd = 7.5
const jump_spd = 6
const TileSize = 80
var jumping_overledge = false

@onready var anitree = $AnimationTree
@onready var anistate = anitree.get("parameters/playback")
@onready var ray = $RayCasts/RayCast2D
@onready var ledge_ray = $RayCasts/LedgeRayCast2D
@onready var Iray = $RayCasts/InterectRayCast2D
@onready var water_ray = $RayCasts/WaterRayCast2D
@onready var shadow = $Shadow
@onready var menu = $Menu
@onready var camera = $Camera2D
@onready var sprite = $Sprite2D
@onready var fade = $Camera2D/CanvasLayer/ColorRect
@onready var collisionShape = $CollisionShape2D

var hasFadedtoBlack = false
var hasFadedtoNormal = false

enum collisions {world, ledge, interect, water}
enum State {Idle, Turn, Walk, Run, Swim}
enum Facing {left, right, up, down}
enum typesofmoviment {walking, jumping, none, swimming}
var playerstate = State.Idle
var facingstate = Facing.down 
var moving = typesofmoviment.none


var posinicial = Vector2(0,0)
var dir = Vector2(0,0)
var nextTile = 0.0

func _ready():
	sprite.visible = true
	posinicial = position
	shadow.visible = false
	anistate.travel("Parado")
	fade.set_position(Vector2(0,0))
	fade.color = Color(0,0,0,0)
	fade.size = get_viewport().size
	

func _physics_process(delta):
		
	if entering_trigger:
		transition(delta)
	elif playerstate == State.Turn:
		checkAndUpdateState()
		return
	elif playerstate == State.Idle:
		inputPlayer()
	elif playerstate == State.Walk or playerstate == State.Run:
		move(delta)
	else:
		playerstate = State.Idle

func checkAndUpdateState():
	if(State.keys()[playerstate] != anistate.get_current_node()):
		playerstate = State.Idle

func updateAnimation():
	var blendPosition = Vector2.ZERO
	
	match facingstate:
		Facing.left:
			blendPosition = Vector2(-1, 0)
		Facing.right:
			blendPosition = Vector2(1, 0)
		Facing.up:
			blendPosition = Vector2(0, -1)
		Facing.down:
			blendPosition = Vector2(0, 1)
	
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
	if dir.y == 0:
		dir.x = int(Input.is_action_pressed("Direita")) - int(Input.is_action_pressed("Esquerda"))
	if dir.x == 0:
		dir.y = int(Input.is_action_pressed("Baixo")) - int(Input.is_action_pressed("Cima"))
	if Input.is_action_just_pressed("Avançar") and TestCollision(collisions.water):
		print("oi3")
		playerstate = State.Swim
	if dir != Vector2.ZERO:
		if needtoturn():
			playerstate = State.Turn
		elif Input.is_action_pressed("Voltar"):
			posinicial = position
			playerstate = State.Run
		else:
			posinicial = position
			playerstate = State.Walk
			
	else:
		playerstate = State.Idle
		
	
	updateAnimation()

func needtoturn():
	var newfacingdirection
	if dir.x < 0:
		newfacingdirection = Facing.left
	elif dir.x > 0:
		newfacingdirection = Facing.right
	elif dir.y < 0:
		newfacingdirection = Facing.up
	elif dir.y > 0:
		newfacingdirection = Facing.down
		
	if facingstate != newfacingdirection:
		facingstate = newfacingdirection
		return true
	else:
		facingstate = newfacingdirection
		return false

func finishedturning():
	playerstate = State.Idle

func move(delta):
	updateAnimation()
	
	if TestCollision(collisions.interect):
		var collider = Iray.get_collider()
		if collider is Area2D:
			if !entering_trigger:
				emit_signal("Player_entering_trigger")
				entering_trigger = true
				hasFadedtoBlack = false
				hasFadedtoNormal = false
	elif (TestCollision(collisions.ledge) and facingstate == Facing.down and moving == typesofmoviment.none) or moving == typesofmoviment.jumping:
		ray.global_position = Vector2(TileSize/2,TileSize/2) +posinicial + (2 * TileSize * dir)
		if TestCollision(collisions.world):
			position = posinicial
			moving = typesofmoviment.none
			playerstate = State.Idle
			ray.position = Vector2(8,8)
			return
		collisionShape.global_position = Vector2(TileSize/2,TileSize/2) + posinicial + (2 * TileSize * dir)
		
		nextTile += jump_spd * delta
		
		if nextTile >= 2.0:
			position = posinicial + (2 * TileSize * dir)
			nextTile = 0.0
			playerstate = State.Idle
			shadow.visible = false
			sprite.position = Vector2(8, -1)
			ray.position = Vector2(8, 8)
			collisionShape.position = Vector2(8, 8)
			moving = typesofmoviment.none
			return
		else:
			moving = typesofmoviment.jumping
			shadow.visible = true
			position = posinicial + TileSize * dir * nextTile
			var input = dir.y * 8 * nextTile 
			sprite.position.y = (- 4 - 1.2 * input + 0.087 * pow(input, 2))
	elif !TestCollision(collisions.world) and (!TestCollision(collisions.water) or playerstate == State.Swim):
		nextTile += run_spd * delta if playerstate == State.Run else spd * delta
		
		if nextTile >= 1.0:
			position = posinicial + (TileSize * dir)
			nextTile = 0.0
			playerstate = State.Idle
			moving = typesofmoviment.none
			return
		else:
			moving = typesofmoviment.walking
			position = posinicial + (TileSize * dir * nextTile)
	else:
		playerstate = State.Idle
		nextTile = 0.0
		posinicial = position
		moving = typesofmoviment.none

func TestCollision(type:collisions):
	var nextstep:Vector2 = dir * 8
	
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
			ledge_ray.target_position = nextstep
			ledge_ray.force_raycast_update()
			if ledge_ray.is_colliding():
				return true
		collisions.water:
			water_ray.target_position = nextstep
			water_ray.force_raycast_update()
			if water_ray.is_colliding():
				return true
	
	return false

func transition(delta):
	nextTile += spd * delta
	if nextTile >= 1:
		if !hasFadedtoBlack:
			$Camera2D/CanvasLayer/AnimationPlayer.play("FadetoBlack")
			hasFadedtoBlack = true
			sprite.visible = false
		else: return
		await manager_scene.timer(2)
		if !hasFadedtoNormal:
			playerstate = State.Idle
			updateAnimation()
			emit_signal("Player_entered_trigger")
			sprite.visible = true
			$Camera2D/CanvasLayer/AnimationPlayer.play("FadetoNormal")
			hasFadedtoNormal = true
		else: return
		await manager_scene.timer(0.5)
		if entering_trigger:
			nextTile = 0.0
			entering_trigger = false
	else:
		position = posinicial + (TileSize * dir * nextTile)
		

func _on_animation_tree_animation_finished(anim_name):
	if anim_name.begins_with("turn_"):
		playerstate = State.Idle
