extends Camera3D

const X_ROT_SPEED: float = 0.01
const Y_ROT_SPEED: float = 0.02
const Z_ROT_SPEED: float = 0.03

func _process(delta):
	rotate_object_local(Vector3(1,0,0), X_ROT_SPEED * delta)
	rotate_object_local(Vector3(0,1,0), Y_ROT_SPEED * delta)
	rotate_object_local(Vector3(0,0,1), Z_ROT_SPEED * delta)
	
