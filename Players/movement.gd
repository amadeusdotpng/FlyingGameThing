extends Area3D
const DRAG: float = 0.9825

const ROLL_SPEED: float = 0.045
const PITCH_SPEED: float = 0.0275
const YAW_SPEED: float = 0.0035

@export var IDLE_SPEED: float = 10
@export var FWD_SPEED: float = 120
@export var BCK_SPEED: float = -25

@onready var velocity: Vector3 = Vector3.ZERO
@onready var acceleration: Vector3 = Vector3.ZERO

func _physics_process(delta):
	rotate_roll(ROLL_SPEED)
	rotate_pitch(PITCH_SPEED)
	rotate_yaw(YAW_SPEED)
	
	update_accel()
	update_velocity(delta)
	update_position(delta)
	
	if Input.is_action_just_pressed("restart"):
		restart()
	
	
func update_position(delta):
	#print("velocity: ", velocity, " ", velocity.length())
	position += velocity * delta
	
func update_velocity(delta):
	velocity += acceleration * delta
	velocity *= DRAG

func update_accel():
	var accel_mag = [BCK_SPEED, IDLE_SPEED, FWD_SPEED][Input.get_axis("thrust_backward", "thrust_forward") + 1]
		
	acceleration = get_global_transform().basis.z * accel_mag

func rotate_roll(rad: float):
	const axis: Vector3 = Vector3(0, 0, 1)
	rad *= Input.get_axis("roll_left", "roll_right")
	rotate_object_local(axis, rad)
	
func rotate_pitch(rad: float):
	const axis: Vector3 = Vector3(1, 0, 0)
	rad *= Input.get_axis("pitch_down", "pitch_up")
	rotate_object_local(axis, rad)
	if rad != 0:
		$Fighter.rotation.x = move_toward($Fighter.rotation.x, 10*rad, 0.1)
	else:
		$Fighter.rotation.x = move_toward($Fighter.rotation.x, 0, 0.1)
		

func rotate_yaw(rad: float):
	const axis: Vector3 = Vector3(0, 1, 0)
	rad *= Input.get_axis("yaw_right", "yaw_left")
	rotate_object_local(axis, rad)
	if rad != 0:
		$Fighter.rotation.y = move_toward($Fighter.rotation.y, 45*rad, 0.1)
	else:
		$Fighter.rotation.y = move_toward($Fighter.rotation.y, 0, 0.1)

func restart():
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	acceleration = Vector3.ZERO
		
func _on_area_entered(area):
	if area.is_in_group("Target"):
		#print("here ", area.transform.basis.z/2 * 50)
		velocity += get_global_transform().basis.z/2 * 200
		
		
