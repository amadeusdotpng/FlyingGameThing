extends Node3D


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().change_scene_to_file("res://Main/world.tscn")
