class_name ManagerScene extends Node

var player: Player
var ScenePath = "res://Scenes/Scenes/"

func changeScene(from, toSceneName: String):
	player = from.get_node("Player")
	player.get_parent().remove_child(player)
	
	var fullPath = ScenePath + toSceneName + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", fullPath)
