extends Control

@onready var box = $NinePatchRect/RichTextLabel
@onready var timer = $Timer
var waitinput = false
var allText: Array
var already = false

func _process(_unusual_delta):
	if !already:
		await Global.player.ControlTimer(0.3)
		already = true

	if Input.is_action_just_pressed("Avançar") and already: 
		already = false
		if waitinput:
			waitinput = false
			box.text = ""
			if index >= allText.size():
				visible = false
				index = 0
				Global.player.emitSignalText()
				process_mode = Node.PROCESS_MODE_DISABLED
			else:
				timer.start()
		elif !timer.is_stopped():
			box.text = Global.convertType(allText[index], Global.Types.string)
			letter = 0
			index += 1
			waitinput = true
			timer.stop()

func Texto(text):
	var istext = true
	var currentBox: Array
	var boxName = []
	var nameColor = []
	var naming = false
	var iscolor = false
	allText.clear()
	
	for i in text:
		if !istext:
			match i:
				"b":
					allText.append(currentBox.duplicate())
					currentBox.clear()
			istext = true
		elif i == "\\":
			istext = false
		elif i == '>':
			allText.append(currentBox.duplicate())
			currentBox.clear()
			istext = false
		elif i == ")":
			boxName.append(": ")
			naming = false
			for p in boxName:
				currentBox.append(p)
		elif i == "(":
			boxName.clear()
			naming = true
		elif naming:
			boxName.append(i)
		elif i == "]":
			nameColor.append(i)
			nameColor = Global.convertType(nameColor, Global.Types.string)
			iscolor = false
			currentBox.append(nameColor)
			nameColor = []
		elif i == "[":
			nameColor.append(i)
			iscolor = true
		elif iscolor:
			nameColor.append(i)
		else:
			currentBox.append(i)
	currentBox.clear()
	timer.start()

var index = 0
var letter = 0

func _on_timer_timeout() -> void:
	var currentbox:Array = allText[index]
	waitinput = false
	if letter < currentbox.size():
		waitinput = false
		box.text += currentbox[letter]
		letter += 1
	elif index < allText.size():
		index+=1
		letter = 0
		timer.stop()
		waitinput = true
