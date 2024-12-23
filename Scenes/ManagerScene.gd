class_name ManagerScene extends Node

var player: Player
var ScenePath = "res://Scenes/Scenes/"

var menuActive = false

func changeScene(from, toSceneName: String):
	player = from.get_node("Player")
	player.get_parent().remove_child(player)
	
	var fullPath = ScenePath + toSceneName + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", fullPath)

var is_paused = false

func timer(wait_time: float):
	is_paused = true
	var time = Timer.new()
	time.wait_time = wait_time
	time.one_shot = true
	add_child(time)
	time.start()
	await time.timeout
	is_paused = false
