extends Node

##
# Global autoload script
#
# Handles basic information that is needed to pass between scenes
##

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	

