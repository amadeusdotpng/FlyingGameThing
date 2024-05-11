extends Node3D

var my_uuid = ""
var others = {}
var other = preload("res://Players/other.tscn")

const URL: String = "https://orlinab.pythonanywhere.com/"

const ROLL_SPEED: float = 0.045
const PITCH_SPEED: float = 0.0275
const YAW_SPEED: float = 0.0035

@export var IDLE_SPEED: float = 10
@export var FWD_SPEED: float = 120
@export var BCK_SPEED: float = -25
var SPEED: Array[float] = [BCK_SPEED, IDLE_SPEED, FWD_SPEED]

var accel_input: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$player_connect.request(URL+"connect")
	
	
func _physics_process(delta):
	handle_movement()

func handle_movement():
	$Player.rotate_pitch(PITCH_SPEED * Input.get_axis("pitch_down", "pitch_up"))
	$Player.rotate_yaw(YAW_SPEED * Input.get_axis("yaw_right", "yaw_left"))
	$Player.rotate_roll(ROLL_SPEED * Input.get_axis("roll_left", "roll_right"))
	accel_input = Input.get_axis("thrust_backward", "thrust_forward") + 1
	var acceleration_speed = SPEED[accel_input]
	$Player.update_accel(acceleration_speed)
	
	if Input.is_action_just_pressed("restart"):
		$Player.restart()

func _player_connect(result, response_code, headers, body):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if not data:
		print("not data")
		return
	my_uuid = data["uuid"]
	$update_timer.start()
	$set_timer.start()

func request_data():
	$player_updater.request(URL+"get_data")

func _update_players(result, response_code, headers, body):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if not data:
		print("NOT DATA")
		return
	
	for uuid in data:
		var instance
		if my_uuid == uuid:
			print($Player.position, " : ", data[uuid]["pos"])
			continue
		elif others.has(uuid):
			instance = others[uuid]
		else:
			instance = other.instantiate()
			others[uuid] = instance
			add_child(instance)
			
		update_instance(data[uuid], instance)

func update_instance(instance_data, instance):
	var pos = _dict_to_vector(instance_data["pos"])
	var vel = _dict_to_vector(instance_data["vel"])
	var acc = _dict_to_vector(instance_data["acc"])
	
	instance.position = pos
	instance.velocity = vel
	instance.acceleration = acc

func set_self():
	var timestamp = Time.get_unix_time_from_system()
	
	var json = JSON.stringify({
		'timestamp': timestamp,
		'uuid': my_uuid,
		'pos': _vector_to_dict($Player.position),
		'vel': _vector_to_dict($Player.velocity),
		'acc': _vector_to_dict($Player.acceleration),
	})
	var headers = ["Content-Type: application/json"]
	$player_set.request(URL+"set_data", headers, HTTPClient.METHOD_POST, json)

func _vector_to_dict(v: Vector3):
	return {"x": v.x, "y": v.y, "z": v.z}

func _dict_to_vector(v: Dictionary):
	return Vector3(v['x'], v['y'], v['z'])
