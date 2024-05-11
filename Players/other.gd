extends Area3D

@onready var positions: Array[Vector3] = []
@onready var durations: Array[float] = []
@onready var tween = Tween.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	tween.tween_callback(update)

func update():
	if len(positions) > 0 and not tween.is_running():
		play_tween(positions.pop_front(), durations.pop_front())
		
func play_tween(end: Vector3, duration: float):
	tween.property(self, "position", end, duration)
	tween.play()

func add_data(pos: Vector3, dur: float):
	positions.push_back(pos)
	durations.push_back(dur)
