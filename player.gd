extends CharacterBody3D

@onready var mesh_instance_3d_2 = $"../MeshInstance3D2"
@onready var mesh_instance_3d_3 = $"../MeshInstance3D3"
@onready var mesh_instance_3d_4 = $"../MeshInstance3D4"


# variables that will control the character's speed, jump strength, and gravity
@export var speed := 3.5
@export var jump_strength := 20.0
@export var gravity := 50.0

#var velocity := Vector3.ZERO
var _snap_vector:= Vector3.DOWN

#@onready var spring_arm_3d = $SpringArm3D
#@onready var spring_arm_3d = $Player/SpringArm3D
#@onready var spring_arm_3d = $"/root/World/SpringArm3D2"

# grab the character's 3D SpringArm
@onready var spring_arm_3d = $SpringArm3D

# grab the character's collision shape mesh
@onready var mesh_instance_3d = $CollisionShape3D/MeshInstance3D

# grab the enemies that are in the "Enemies" node
#@onready var enemies_container = $"../Enemies"
@onready var enemies_container = $"/root/World".get_node("Enemies")
@onready var enemies : Array
@onready var enemy_names: Array

# grab the allies that are in the "Allies" node
#@onready var allies_container = $"../Allies"
@onready var allies_container = $"/root/World".get_node("Allies")
@onready var allies: Array 
@onready var ally_names: Array

@onready var enemies_in_range : Array
@onready var allies_in_range: Array

# grab the testing label for enemies in range
#@onready var enemies_in_range_label = $"../Enemies_in_range_label"
@onready var enemies_in_range_label = $"/root/World/Enemies_in_range_label"

var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO
var _is_jumping : bool = false

var is_sprinting : bool = false
var is_locked_on : bool


func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO
	
	#if Input.is_action_pressed("aim"):
		#$AnimationTree.set("parameters/aim_transition/transition_request", "aiming")
	#else:
		#$AnimationTree.set("parameters/aim_transition/transition_request", "not_aiming")
		
	
	# check if the character just pressed the "sprint" button, they are now sprinting
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = !is_sprinting
	
	# check if the player moved left, right, forward, or back
	if Input.is_action_pressed("right") || Input.is_action_pressed("left") || Input.is_action_pressed("forward") || Input.is_action_pressed("back"):
		
		# get the strength of the movement, pop them into x and z respectively
		move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
		#move_direction = move_direction.rotated(Vector3.UP, spring_arm_3d.rotation.y).normalized() #THIS IS OLD WAY, BEFORE ANIMATIONTREE
			
		# animationtree stuff
		strafe_dir = move_direction
		
		# update the move direction so that the player always moves /TOWARDS/ the direction of the springarm3d
		# we are rotating our move direction at all times to match the rotation of the springarm3d
		# wherever the springarm3d is rotated towards, thus too the player will be
		move_direction = move_direction.rotated(Vector3.UP, spring_arm_3d.rotation.y).normalized()
			
		#if is_sprinting == true && $AnimationTree.get("parameters/aim_transition/current_state") == "not_aiming":
			#$AnimationTree.set("parameters/Iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/Iwr_blend/blend_amount"), 1.0, delta * 0.8))
		#else: 
			#$AnimationTree.set("parameters/Iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/Iwr_blend/blend_amount"), 0.0, delta * 0.8))
		

	#velocity.y -= gravity * delta
	else:
		#$AnimationTree.set("parameters/Iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/Iwr_blend/blend_amount"), -1.0, delta * 0.8))
		strafe_dir = Vector3.ZERO
	
	# update the player's velocity, multiplied times their speed to adjust how quickly they can move
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed

	
	#add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		_is_jumping = false
		
	# WORKING JUMP CODE
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#_is_jumping = true
		#velocity.y = jump_strength	

	# check if the player is currently locked onto an enemy, by getting the springarm3d's "locked_on" boolean
	is_locked_on = spring_arm_3d.get("locked_on")

	# if player is not locked on, simply rotate the character to look the way the player is moving them
	if is_locked_on == false:
		var look_direction = Vector2(velocity.z, velocity.x)
		if look_direction.length() > 0.2:
			rotation.y = look_direction.angle()

	#if player is locked onto an enemy, 
	elif is_locked_on == true:
		var look_direction = spring_arm_3d.global_transform.basis.z
		look_direction.y = 0
		look_at(global_transform.origin + look_direction, Vector3.UP)
		

		
	move_and_slide()
	
	var EIR_names: String = "Enemies in range: \n"
	for name in enemies_in_range: 
		EIR_names += str(name)
		EIR_names += "\n"
	
	enemies_in_range_label.text = EIR_names

	if is_locked_on == false:
		if Input.is_action_just_pressed("jump"):
			$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			strafe = lerp(strafe, strafe_dir, 0.2)
			$AnimationTree.set("parameters/strafe/blend_position", Vector2(strafe.x, -strafe.z))
	elif is_locked_on == true:
		strafe = lerp(strafe, strafe_dir, 0.2)
		$AnimationTree.set("parameters/locked_on_strafe/blend_position", Vector2(strafe.x, -strafe.z))
	
	
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
		
	if spring_arm_3d:
		is_locked_on = spring_arm_3d.get("locked_on")

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
		
