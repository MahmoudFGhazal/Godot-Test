extends Control

@onready var box = $NinePatchRect/RichTextLabel

func _ready() -> void:
	pass # Replace with function body.


func Texto(text: String):
	box.text = text
