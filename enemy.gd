extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var nav_agent = $NavigationAgent3D
@export var move_speed = 2.0
@export var atk_range = 7.0
@export var atk_cooldown = 4
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
var dead = false
var activated = false
var last_atk_time = -1000
var player_pos

func _ready():
	nav_agent.target_desired_distance = atk_range

func _physics_process(delta):
	if dead or player == null or !activated: return
	
	#var dir = player.global_position - global_position
	#dir.y = 0.0
	#dir = dir.normalized()
	#velocity = dir*move_speed
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * move_speed
	
	nav_agent.set_velocity(new_velocity)
	
	
	#attempt_to_kill_player()
	
func attempt_to_kill_player():
	var dist_to_player = global_position.distance_to(player.global_position)
	#if(dist_to_player > atk_range): return
	
	if((Time.get_ticks_msec() - last_atk_time) < atk_cooldown): return
	
	
	var eye_line = Vector3.UP * 10
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player_pos = player.global_position	
		self.activated = false
		nav_agent.set_velocity(Vector3(0,0,0))
		animated_sprite_3d.play("attack")	
		last_atk_time = Time.get_ticks_msec()	

func anim_done():
	var anim_name = animated_sprite_3d.animation
	if anim_name != "attack": return
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if(player_pos == player.global_position): player.kill()
	

	draw_line(self.global_position+(Vector3.UP * 10), player_pos, Color.CRIMSON, 2)
	await get_tree().create_timer(2.5).timeout
	if !dead: animated_sprite_3d.play("walk")
	self.activated = true

func draw_line(pos1, pos2, color, time):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, time)
	
func kill():
	nav_agent.set_velocity(Vector3.ZERO)
	nav_agent.avoidance_enabled = false
	dead = true
	$DeathSound.play()
	animated_sprite_3d.play("death")	
	$CollisionShape3D.disabled = true
	get_parent().get_parent().get_parent().enemy_killed()
	
func update_target_location(target_location):
	nav_agent.target_position = (target_location)	
	
func _on_navigation_agent_3d_target_reached():
	if dead: return
	attempt_to_kill_player()	
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
	
func activate():
	activated = true	

## 1 -> Lasts ONLY for current physics frame
## >1 -> Lasts X time duration.
## <1 -> Stays indefinitely	
func final_cleanup(mesh_instance, time):
	mesh_instance.add_to_group("laser")
	get_tree().get_root().add_child(mesh_instance)
	if time == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif time > 0:
		await get_tree().create_timer(time).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance	
