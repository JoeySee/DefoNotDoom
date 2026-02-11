extends Area3D
var creation_time
@export var speed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	creation_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() - creation_time == 3000: self.queue_free()

func _physics_process(delta):
	pass
