extends Node2D

@onready var ani = $AnimationPlayer
@onready var particulas = $AnimatedSprite2D
@onready var grassOver = $Overlay
@onready var grass = $Sprite2D

var inGrass = false

func _ready():
	grassOver.visible = false

func _on_area_2d_body_entered(body):
	inGrass = true
	grassOver.visible = true
	particulas.visible = true
	ani.play("Stepped")
	particulas.play()

func _on_area_2d_body_exited(body):
	inGrass = false
	grassOver.visible = false
	ani.play("Parado")
