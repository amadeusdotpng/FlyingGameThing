extends Node3D

var prev_state = null
var start_time = null
var time = null
var curr_state = null
var my_uuid = ""
var others = {}
var other = preload("res://Players/other.tscn")

const URL: String = "https://orlinab.pythonanywhere.com/"
#const URL: String = "http://localhost:80/"

const SPEED_BOOST: float = 90

const ROLL_SPEED: float = 0.045
const PITCH_SPEED: float = 0.0275
const YAW_SPEED: float = 0.0035

@export var IDLE_SPEED: float = 0
@export var FWD_SPEED: float = 120
@export var BCK_SPEED: float = -25
var SPEED: Array[float] = [BCK_SPEED, IDLE_SPEED, FWD_SPEED]

var accel_input: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$player_connect.request(URL+"connect")

func _input(event):
	if Input.is_action_just_pressed("toggle_instructions"):
		$CanvasLayer/Controls.visible = not $CanvasLayer/Controls.visible
		
	if Input.is_action_just_pressed("toggle_gui"):
		$CanvasLayer/Speed.visible = not $CanvasLayer/Speed.visible
		$CanvasLayer/PlayerList.visible = not $CanvasLayer/PlayerList.visible
		$CanvasLayer/State.visible = not $CanvasLayer/State.visible
	
	if Input.is_action_just_pressed("disable_mouse_capture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _physics_process(delta):
	handle_movement()
	update_gui()
	
func update_gui():
	$CanvasLayer/Speed.text = str(round($Player.velocity.length()*100)/100) + " m/s"
	if time != null and curr_state != null:
		$CanvasLayer/State.text = curr_state + "\n"
		$CanvasLayer/State.text += str(round(time - Time.get_unix_time_from_system()))
	
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
		print("_player_connect no data")
		return
	my_uuid = data["uuid"]
	$Player.get_node("username").text = data["username"]
	time = data["gamestate_time"]
	$update_timer.start()
	$set_timer.start()

func request_data():
	$player_updater.request(URL+"get_data")
	
func update_playerlist(players):
	$CanvasLayer/PlayerList.text = players[my_uuid]["username"]
	$CanvasLayer/PlayerList.text = "\n".join(players.values().map(
		func(a): return a["username"]
	))

func _update_state(result, response_code, headers, body):
	var lobby_data = JSON.parse_string(body.get_string_from_utf8())
	
	if not lobby_data:
		print("NOT DATA")
		return
		
	var players = lobby_data["players"]
	#print(lobby_data)
	for uuid in players:
		var instance
		var instance_data = players[uuid]
		if my_uuid == uuid:
			update_playerlist(players)
			continue
		elif others.has(uuid):
			instance = others[uuid]
		else:
			instance = other.instantiate()
			instance.get_node("username").text = instance_data["username"]
			others[uuid] = instance
			update_playerlist(players)
			add_child(instance)
			
		update_instance(instance_data, instance)
		
	curr_state = lobby_data["game_state"]
	#print(prev_state, curr_state, time, " ", Time.get_unix_time_from_system())
	if prev_state == null:
		prev_state = curr_state
		
	if prev_state == "WARMUP" and curr_state == "STARTED":
		time = lobby_data["until_next"]
		prev_state = lobby_data["game_state"]
		start_time = lobby_data["start_time"]
		
		$Player.restart()
		for uuid in others:
			others[uuid].restart()
		return
		
	elif prev_state == "STARTED" and curr_state == "ENDED":
		time = lobby_data["until_next"]
		prev_state = lobby_data["game_state"]
		
		var sorted = players.values()
		sorted.sort_custom(
			func(a, b): return (
				true  if b["finish_time"] == -1 else 
				false if a["finish_time"] == -1 else 
				a["finish_time"] < b["finish_time"]
			)
		)
		sorted = sorted.map(
			func(a): return a["username"] + "             " + (str(round((a["finish_time"] - start_time)*100)/100)+" s" if a["finish_time"] != -1 else "DID NOT FINISH")
		)
		$CanvasLayer/Leaderboard.text = "FINISHING TIMES\n"
		$CanvasLayer/Leaderboard.text += "\n".join(sorted)
		$CanvasLayer/Leaderboard.visible = true
		
	elif (prev_state == "ENDED") and curr_state == "WARMUP":
		time = lobby_data["until_next"]
		prev_state = lobby_data["game_state"]
		start_time = lobby_data["start_time"]
		
		$CanvasLayer/Leaderboard.visible = false
		$Player.restart()
		for uuid in others:
			others[uuid].restart()
		
	var disconnected_players = []
	for uuid in others:
		if uuid not in players:
			disconnected_players.push_back(uuid)
			
	for uuid in disconnected_players:
		remove_child(others[uuid])
		others.erase(uuid)
		$CanvasLayer/PlayerList.text = "\n".join(players.values().map(
				func(a): return a["username"]
		))
		
	
		
func update_instance(instance_data, instance):
	var rot = _dict_to_vector(instance_data["rot"])
	var pos = _dict_to_vector(instance_data["pos"])
	var vel = _dict_to_vector(instance_data["vel"])
	var acc = _dict_to_vector(instance_data["acc"])
	var last_updated = instance_data["last_updated"]
	
	instance.rotation_degrees = rot
	instance.position = pos
	instance.velocity = vel
	instance.acceleration = acc
	
	if instance.last_updated == last_updated:
		instance.disconnected += 1
	else:
		instance.disconnected = 0
		instance.last_updated = last_updated
		
func set_self_default():
	set_self(false)
func set_self(finished: bool):
	#print("updating smyself")
	var last_updated = Time.get_unix_time_from_system()
	
	var json = JSON.stringify({
		'last_updated': last_updated,
		'uuid': my_uuid,
		'finished': finished,
		'rot': _vector_to_dict($Player.rotation_degrees),
		'pos': _vector_to_dict($Player.position),
		'vel': _vector_to_dict($Player.velocity),
		'acc': _vector_to_dict($Player.acceleration),
	})
	
	var headers = ["Content-Type: application/json", "Access-Control-Allow-Origin: *"]
	$player_set.request(URL+"set_data", headers, HTTPClient.METHOD_POST, json)

func _vector_to_dict(v: Vector3):
	return {"x": v.x, "y": v.y, "z": v.z}

func _dict_to_vector(v: Dictionary):
	return Vector3(v['x'], v['y'], v['z'])

func _on_player_area_entered(area):
	if area.is_in_group("Target"):
		$Player.velocity += $Player.get_global_transform().basis.z * SPEED_BOOST
		
	if area.is_in_group("Finish"):
		var headers = ["Content-Type: application/json", "Access-Control-Allow-Origin: *"]
		var json = JSON.stringify({'finished': true, 'uuid': my_uuid})
		$win.request(URL+"win", headers, HTTPClient.METHOD_POST, json)
