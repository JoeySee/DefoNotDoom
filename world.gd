extends Node3D

@onready var player = $Player
@export var enemy_count = 0

func _ready():
	init_world()

func _physics_process(delta):	
	get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func init_world():
	for i in range(1, 5):						
		var currentRoom = get_node("Room" + str(i) + "/Room" + str(i) + "/Room")
		currentRoom.body_entered.connect(area_entered_func.bind(i))
	var num_enemies = get_tree().get_nodes_in_group("enemy").size()	
	enemy_count = num_enemies

		
func area_entered_func(body, room):
	if body.name == "Player": get_tree().call_group("room" + str(room) + "enemy", "activate")	
	
func enemy_killed():
	enemy_count -= 1
	if(enemy_count == 0):
		player.end_game(1)	
	
	
