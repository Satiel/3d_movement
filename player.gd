extends CharacterBody3D

@onready var mesh_instance_3d_2 = $"../MeshInstance3D2"
@onready var mesh_instance_3d_3 = $"../MeshInstance3D3"
@onready var mesh_instance_3d_4 = $"../MeshInstance3D4"



@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0

#var velocity := Vector3.ZERO
var _snap_vector:= Vector3.DOWN

#@onready var spring_arm_3d = $SpringArm3D
#@onready var spring_arm_3d = $Player/SpringArm3D
#@onready var spring_arm_3d = $"/root/World/SpringArm3D2"
@onready var spring_arm_3d = $SpringArm3D


@onready var mesh_instance_3d = $CollisionShape3D/MeshInstance3D

#@onready var enemies_container = $"../Enemies"
@onready var enemies_container = $"/root/World".get_node("Enemies")
@onready var enemies : Array
@onready var enemy_names: Array

#@onready var allies_container = $"../Allies"
@onready var allies_container = $"/root/World".get_node("Allies")
@onready var allies: Array 
@onready var ally_names: Array

@onready var enemies_in_range : Array
@onready var allies_in_range: Array

#@onready var enemies_in_range_label = $"../Enemies_in_range_label"
@onready var enemies_in_range_label = $"/root/World/Enemies_in_range_label"






func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO

	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_3d.rotation.y).normalized()
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	#velocity.y -= gravity * delta

	
	#add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength	

	var look_direction = Vector2(velocity.z, velocity.x)
	if look_direction.length() > 0.2:
		rotation.y = look_direction.angle()
		
	move_and_slide()
	
	var EIR_names: String = "Enemies in range: \n"
	for name in enemies_in_range: 
		EIR_names += str(name)
		EIR_names += "\n"
	
	enemies_in_range_label.text = EIR_names
	
	
	
	# collision checks
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider_name = collision.get_collider().get_parent().name
		#if collider_name in enemy_names or collider_name in ally_names:
			#print("Player collided with ", collider_name)
	

	
func _process(delta: float) -> void:
	spring_arm_3d.position = position
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("fullscreen"):
		var fs = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
func _ready():
	enemies = enemies_container.get_children()
	for enemy in enemies:
		enemy_names.append(enemy.name)
		
	allies = allies_container.get_children()
	for ally in allies:
		ally_names.append(ally.name)

func _on_area_3d_body_entered(body):

	var body_name = body.get_parent().name
	if body_name in enemy_names:
		print("Enemy detected: ", body_name)
		enemies_in_range.append(body_name)
		body.get_parent().add_to_group("EnemiesInRange")
		print(body_name, " is now in range.")
	if body_name in ally_names:
		print("Ally detected: ", body_name)
		allies_in_range.append(body_name)
		add_to_group("AlliesInRange")
		body.get_parent().add_to_group("AlliesInRange")
		print(body_name, " is now in range.")
	




func _on_area_3d_body_exited(body):
	var body_name_exited = body.get_parent().name
	if body_name_exited in enemy_names:
		print("Enemy no longer detected: ", body_name_exited)
		enemies_in_range.erase(body_name_exited)
		body.get_parent().remove_from_group("EnemiesInRange")
		print(body_name_exited, " is no longer in range.")
	if body_name_exited in ally_names:
		print("Ally no longer detected: ", body_name_exited)
		allies_in_range.erase(body_name_exited)
		remove_from_group("AlliesInRange")
		body.get_parent().remove_from_group("AlliesInRange")
		print(body_name_exited, " is no longer in range.")
		
