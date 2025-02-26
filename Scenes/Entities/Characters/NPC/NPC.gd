extends CharacterBody2D
class_name NPC

@export var ID: int
@export var sprite: Texture

@export var walk: bool
@export var dist: int
enum FaceStates {down, up, left, right}
@export var facing: FaceStates = FaceStates.down

@export var actions: String

enum States {idle, walking, turning}
var state = States.idle

@onready var anitree = $AnimationTree
@onready var anistate = anitree.get("parameters/playback")
@onready var ray = $RayCasts/RayCast2D
@onready var ray2 = $RayCasts/RayCast2D2

var spawn
var posinicial: Vector2
var dir: Vector2
var spd = 3.85
var nextTile: float
var TileSize = 80

var rand = RandomNumberGenerator.new()

var timer = 0
var time

var isBeUsing = false

func _ready():
	$Sprite2D.texture = sprite
	
	time = rand.randi_range(100, 140)
	
	dist *= TileSize
	spawn = position
	posinicial = position
	updateAnimation()

func _physics_process(delta):
	updateAnimation()
	if !walk or isBeUsing:
		if state == States.walking:
			move(delta)
		return
	
	if state == States.idle:
		timer += 1
		if timer >= time:
			if rand.randi_range(0, 1):
				state = States.walking
			else:
				turn()
			timer = 0
			time = rand.randi_range(100, 140)
			
	
	if state == States.walking:
		move(delta)

func statesControl(direc:Vector2):
	dir = direc
	
	posinicial = position
	if needtoturn():
		state = States.turning
		makeTurn()
	else:
		state = States.walking
	updateAnimation()

func makeTurn():
	match dir:
		Vector2(1,0):
			facing = FaceStates.right
		Vector2(-1,0):
			facing = FaceStates.left
		Vector2(0,1):
			facing = FaceStates.down
		Vector2(0,-1):
			facing = FaceStates.up

func turn():
	facing = FaceStates.values()[randi_range(0, 3)]
	if needtoturn():
		state = States.turning

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
		
	if facing != oldfacingdirection:
		return true
	else:
		return false

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


func finishedturning():
	state = States.idle

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

func action():
	if actions:
		Global.cutScene(actions)
