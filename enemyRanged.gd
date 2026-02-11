extends "res://enemy.gd"
@onready var projectile = preload("res://shot.tscn")
var last_shot_time : float = -1

func attempt_to_kill_player():
	if !check_cooldown(): return 
	var shot = projectile.instantiate()
	get_parent().add_child(shot)
	shot.transform = self.transform.translated(Vector3(0,1,0))
	shot.scale = Vector3(50, 50, 50)
	last_shot_time = Time.get_ticks_msec()

func check_cooldown():
	if last_shot_time == -1 or Time.get_ticks_msec() - last_shot_time > 3000: return true
	
