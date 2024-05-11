extends Area3D

@onready var positions: Array[Vector3] = []
@onready var durations: Array[float] = []
@onready var is_tween_done: bool = true
# Called when the node enters the scene tree for the first time.

func update():
	if is_tween_done and len(positions) > 0 and len(durations) > 0:
		is_tween_done = false
		play_tween(positions.pop_front(), durations.pop_front())

func play_tween(end: Vector3, duration: float):
	var tween = create_tween()
	tween.tween_property(self, "position", end, duration+0.05)
	tween.finished.connect(tween_done)
	
func tween_done():
	is_tween_done = true
	update()

func add_data(pos: Vector3, dur: float):
	positions.push_back(pos)
	durations.push_back(dur)
