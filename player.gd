extends CharacterBody3D

@onready var gun_sprite = $CanvasLayer/SwordBase/AnimatedSprite2D
@onready var ray_cast = $Head/RayCast3D
@onready var shoot_sound = $ShootSound
@onready var head = $Head
@onready var camera = $Head/Camera3D
@export var gravity = 15
@export var speed = 20

const MOUSE_SENS = 0.009
const JUMP_VELOCITY = 4.5

var can_shoot = true
var dead = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _input(event):
	if dead:  return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		ray_cast.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		#rotation_degrees.x -= event.relative.y * MOUSE_SENS
		#rotation_degrees.x = clamp(rotation_degrees.x, -80, 60)
		#rotation_degrees.y -= event.relative.x * MOUSE_SENS
		
	
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		change_to_menu()	
		
	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()		

func _physics_process(delta):
	if dead: return
	
	if !is_on_floor():
		velocity.y -= delta * gravity
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func change_to_menu():
	get_tree().change_scene_to_file("res://menu.tscn")
	
func shoot():
	if !can_shoot: return
	can_shoot = false
	gun_sprite.play("shoot")
	shoot_sound.play()
	if ray_cast.is_colliding() and ray_cast.get_collider().has_method("kill"):
		ray_cast.get_collider().kill()
			
func shoot_anim_done():
	can_shoot = true		

func kill():
	#dead = true
	end_game(0)
	#$CanvasLayer/DeathScreen.show()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
# 0 = death, 1 = victory	
func end_game(code):
	dead = true
	var end_screen = $CanvasLayer/EndScreen
	var panel = $CanvasLayer/EndScreen/Panel
	end_screen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	panel.get_node("death").visible = code == 0
	panel.get_node("victory").visible = code == 1
