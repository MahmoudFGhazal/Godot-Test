extends CharacterBody2D

@export var sprite: Texture
@export var walk: bool
@export var dist: int

enum FaceStates {down, up, left, right}
@export var facing: FaceStates = FaceStates.down

enum States {idle, walking, turning}
var state = States.idle

@onready var anitree = $AnimationTree
@onready var anistate = anitree.get("parameters/playback")
@onready var ray = $RayCasts/RayCast2D
@onready var ray2 = $RayCasts/RayCast2D2

var spawn
var posinicial: Vector2
var dir: Vector2
var spd = 4
var nextTile: float
var TileSize = 80

var rand = RandomNumberGenerator.new()

var timer = 0
var time

func _ready():
	$Sprite2D.texture = sprite
	
	time = rand.randi_range(100, 140)
	
	dist *= TileSize
	spawn = position
	posinicial = position
	updateAnimation()


func _physics_process(delta):
	if !walk:
		return
	
	updateAnimation()

	if state == States.idle:
		timer += 1
		if timer >= time:
			if rand.randi_range(0, 1):
				state = States.walking
			else:
				state = States.turning
			timer = 0
			time = rand.randi_range(100, 140)
			
	
	if state == States.walking:
		move(delta)
	elif state == States.turning:
		turn()
		state = States.idle

func updateAnimation():
	match facing:
		FaceStates.left:
			dir = Vector2(-1, 0)
		FaceStates.right:
			dir = Vector2(1, 0)
		FaceStates.up:
			dir = Vector2(0, -1)
		FaceStates.down:
			dir = Vector2(0, 1)
			
	match state:
		States.idle:
			anitree.set("parameters/Parado/blend_position", dir)
			anistate.travel("Parado")
		States.walking:
			if !collision():
				anitree.set("parameters/Walk/blend_position", dir)
				anistate.travel("Walk")
		States.turning:
			anitree.set("parameters/Turn/blend_position", dir)
			anistate.travel("Turn")
		_:
			anistate.travel("Parado")

func move(delta):
	if !collision():
		var distSpawn = position.distance_to(spawn)
		
		if distSpawn >= dist:
			nextTile = 0.0
			state = States.idle
			return
			
			
		nextTile += spd * delta 
		
		if nextTile >= 1.0:
			position = posinicial + (TileSize * dir)
			nextTile = 0.0
			state = States.idle
			posinicial = position 
			return
		else:
			position = posinicial + (TileSize * dir * nextTile)
	else:
		position = posinicial
		nextTile = 0.0
		state = States.idle

func turn():
	facing = FaceStates.values()[randi_range(0, 3)]

func collision():
	var nextstep:Vector2 = dir * 16 * (1 - nextTile)
	ray.position = Vector2(1,1) * 8 - Vector2(dir.y, dir.x) * Vector2(7,7)
	ray2.position = Vector2(1,1) * 8 - Vector2(dir.y, dir.x) * Vector2(-7,-7)
	
	ray.target_position = nextstep
	ray.force_raycast_update()
	ray2.target_position = nextstep
	ray2.force_raycast_update()
	
	if ray.is_colliding() or ray2.is_colliding():
		return true
	
	return false
