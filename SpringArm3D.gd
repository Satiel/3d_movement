extends SpringArm3D


@export var mouse_sensitivity := 0.05
# Dictionary to store the current state of the joystick axes
var joystick_direction = Vector2.ZERO
var tilt_limit_min: float = -45.0
var tilt_limit_max: float = 45.0
@onready var player = $Player

var parent_node : CharacterBody3D
var enemies : Array


func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var parent_node = get_parent()
	
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
	
	enemies = get_tree().get_nodes_in_group("EnemiesInRange")
	if enemies.size() > 0:
		print(enemies[0].name)
		var player_position = get_parent().global_transform.origin
		var enemy_position = enemies[0].global_transform.origin
		print("Player position: ", player_position, ", Enemy position: ", enemy_position)
		#for enemy in enemies:
			#print(enemy.name)
	
	
	
	


	
