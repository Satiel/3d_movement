extends SpringArm3D


@export var mouse_sensitivity := 0.05
# Dictionary to store the current state of the joystick axes
var joystick_direction = Vector2.ZERO
var tilt_limit_min: float = -45.0
var tilt_limit_max: float = 45.0
@onready var player = $Player

var parent_node : CharacterBody3D
var enemies : Array
var locked_on : bool 
var enemy_target_lock: Node3D




func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var parent_node = get_parent()
	locked_on = false
	
## this is how we can handle camera movement with the mouse
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotation_degrees.x -= event.relative.y * mouse_sensitivity
		#rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		#rotation_degrees.y -= event.relative.x * mouse_sensitivity
		#rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

		
func _physics_process(delta: float) -> void:
	# continously check the joystick axis values
	joystick_direction.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	joystick_direction.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	#print("x: ", joystick_direction.x, ", y: ", joystick_direction.y)
	
	if abs(joystick_direction.x) > 0.1: 
		rotation_degrees.y += joystick_direction.x * 180.0 * delta
	if abs(joystick_direction.y) > 0.1:
		rotation_degrees.x -= joystick_direction.y * 180.0 * delta
		
	# clamp the vertical movement
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_limit_min, tilt_limit_max)
		
	# clamp the horizontal movement
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	#rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 180.0)
	#rotation_degrees.y = clamp(rotation_degrees.y, 0.0, 180.0)
	
	
	
	var target_locked : Node3D
	
	
	if Input.is_action_just_pressed("lock_on"):
		locked_on = !locked_on
		print("Locked_on changed to ", locked_on)
	enemies = get_tree().get_nodes_in_group("EnemiesInRange")
	
	#if Input.is_action_pressed("aim"):
		#$AnimationTree.set("parameters/aim_transition/transition_request", "aiming")
	#else:
		#$AnimationTree.set("parameters/aim_transition/transition_request", "not_aiming")
		
	if locked_on == true:
		if get_parent().get_node("AnimationTree"):
			get_parent().get_node("AnimationTree").set("parameters/lock_on_transition/transition_request", "locked_on")

	elif locked_on == false:
		if get_parent().get_node("AnimationTree"):
			get_parent().get_node("AnimationTree").set("parameters/lock_on_transition/transition_request", "not_locked_on")

	
	if enemies.size() > 0:
		if locked_on == true:
			enemy_target_lock = enemies[0].get_child(1)
			enemy_target_lock.visible = true
			target_locked = enemies[0]
			#print("enemy children nodes: ", enemy_children_nodes)
			print(enemies[0].name)
			var player_position = get_parent().global_transform.origin
			var enemy_position = enemies[0].global_transform.origin

			
			# look at target 
			#look_at(Vector3(enemy_position.x, -2.0, enemy_position.y), Vector3.UP)
			
			# find the looking direction of the enemy
			var _looking_direction = -global_position.direction_to(enemy_position)
			var _target_look = atan2(_looking_direction.x, _looking_direction.z)
			print("Looking direction: ", _target_look)

			# turn the springarm3D slowly
			var desired_rotation_y = lerp_angle(rotation.y, _target_look, 0.05)
			print("desired_rotation_y: ", desired_rotation_y)
			
			# make the movement smooth, 20 max, 10 min for distance check - NEEDS WORK
			print("distance to enemy: ", position.distance_to(enemy_position))
			var normalized_distance = (position.distance_to(enemy_position) - 10.0 / (20 - 10) )
			normalized_distance = smoothstep(0.0, 1.0, normalized_distance)
			print("normalized distance: ", normalized_distance)
			
			# how much do we look up and down
			var angle = lerp(45.0, 15.0, normalized_distance)
			var desired_rotation_x = deg_to_rad(-angle)
			print("angle: ", angle, ", desired_rotation_x: ", desired_rotation_x)
			
		
			rotation.y = lerp(rotation.y, desired_rotation_y, 0.8)
			#rotation.x = lerp(rotation.x, desired_rotation_x, 0.05)

	if (locked_on == false) and (enemy_target_lock != null):
		enemy_target_lock.visible = false
		print("TARGET UNLOCKED")
	#print("SpringArm3D rotation: ", rotation_degrees )
	

	
	
	



	
