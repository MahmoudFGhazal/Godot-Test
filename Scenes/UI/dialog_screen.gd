extends Control

@onready var box = $NinePatchRect/RichTextLabel
@onready var timer = $Timer
var waitinput = false
var allText: Array
var already = false

func _process(_unusual_delta):
	if !already:
		await Global.player.ControlTimer(0.7)
		already = true
	if Input.is_action_just_pressed("Avançar") and already: 
		already = false
		if waitinput:
			waitinput = false
			box.text = ""
			if index >= allText.size():
				Global.inCut = false
				visible = false
				index = 0
				process_mode = Node.PROCESS_MODE_PAUSABLE
			else:
				timer.start()
		elif !timer.is_stopped():
			box.text = allText[index]
			letter = 0
			index += 1
			waitinput = true
			timer.stop()

func Texto(text):
	var istext = true
	var currentBox: Array
	var boxName = []
	var naming = false
	allText.clear()
	
	for i in text:
		if !istext:
			match i:
				"b":
					var boxText:String = Global.arrayToString(currentBox)
					allText.append(boxText)
					currentBox.clear()
			istext = true
		elif i == "\\":
			istext = false
		elif i == '>':
			var boxText:String = Global.arrayToString(currentBox)
			allText.append(boxText)
			currentBox.clear()
			istext = false
		elif i == ")":
			boxName.append(": ")
			boxName = Global.arrayToString(boxName)
			naming = false
			currentBox.append(boxName)
		elif i == "(":
			naming = true
		elif naming:
			boxName.append(i)
		else:
			currentBox.append(i)
	currentBox.clear()
	timer.start()

var index = 0
var letter = 0

func _on_timer_timeout() -> void:
	var currentletters:String = allText[index]
	waitinput = false
	if letter < currentletters.length():
		waitinput = false
		box.text += currentletters[letter]
		letter += 1
	elif index < allText.size():
		index+=1
		letter = 0
		timer.stop()
		waitinput = true
