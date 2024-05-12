extends Area3D
const DRAG: float = 0.9825
const SPEED_BOOST: float = 90
const DISCONNECT_THRESH: int = 7

@onready var velocity: Vector3 = Vector3.ZERO
@onready var acceleration: Vector3 = Vector3.ZERO
@onready var last_updated: float = 0
@onready var disconnected: int = 0

func _physics_process(delta):
	if disconnected <= DISCONNECT_THRESH:
		update_velocity(delta)
		update_position(delta)
	
func update_position(delta):
	position += velocity * delta
	
func update_velocity(delta):
	velocity += acceleration * delta
	velocity *= DRAG

func update_accel(acceleration_speed: float):
	acceleration = get_global_transform().basis.z * acceleration_speed

func rotate_roll(rad: float):
	const axis: Vector3 = Vector3(0, 0, 1)
	rotate_object_local(axis, rad)
	
func rotate_pitch(rad: float):
	const axis: Vector3 = Vector3(1, 0, 0)
	rotate_object_local(axis, rad)
	if rad != 0:
		$Fighter.rotation.x = move_toward($Fighter.rotation.x, 10*rad, 0.1)
	else:
		$Fighter.rotation.x = move_toward($Fighter.rotation.x, 0, 0.1)
		
func rotate_yaw(rad: float):
	const axis: Vector3 = Vector3(0, 1, 0)
	rotate_object_local(axis, rad)
	if rad != 0:
		$Fighter.rotation.y = move_toward($Fighter.rotation.y, 45*rad, 0.1)
	else:
		$Fighter.rotation.y = move_toward($Fighter.rotation.y, 0, 0.1)
		
func _on_area_entered(area):
	if area.is_in_group("Target"):
		velocity += get_global_transform().basis.z * SPEED_BOOST
	
func restart():
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	acceleration = Vector3.ZERO
	
		

