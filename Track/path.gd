extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_exited(area):
	if area.is_in_group("Player") and !area.has_overlapping_areas():
		area.restart()
		
