extends Area3D
const DRAG: float = 0.9825

const ROLL_SPEED: float = 0.045
const PITCH_SPEED: float = 0.0275
const YAW_SPEED: float = 0.0035

@export var IDLE_SPEED: float = 10
@export var FWD_SPEED: float = 120
@export var BCK_SPEED: float = -25
var SPEED: Array[float] = [BCK_SPEED, IDLE_SPEED, FWD_SPEED]

@onready var velocity: Vector3 = Vector3.ZERO
@onready var acceleration: Vector3 = Vector3.ZERO

func _physics_process(delta):
	update_velocity(delta)
	update_position(delta)
	
func update_position(delta):
	position += velocity * delta
	
func update_velocity(delta):
	velocity += acceleration * delta
	velocity *= DRAG

func update_accel(acceleration_speed: float):
	acceleration = get_global_transform().basis.z * acceleration_speed

func restart():
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	acceleration = Vector3.ZERO
		
		
