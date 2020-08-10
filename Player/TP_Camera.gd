extends Spatial

# Declaration of member variables here
export var mouse_control = false		# Use the mouse to control the camera
export var mouse_sensitivity = 0.005	# Sensitivity of the mouse movement

export var rotate_speed = PI / 2		# How fast the camera can rotate (stick)
export var max_height = 0.5				# Max rotation upwards
export var min_height = -1.0			# Min rotation downwards

export var invert_x = false				# Invert horizontal camera movement
export var invert_y = false				# Invert vertical camera movement

export(NodePath) var follow_target		# Path to the target node to follow
var _follow_target : Position3D			# Node that is being followed


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the follow target as a node
	if follow_target == "":
		print("No target to follow set!")
	else:
		_follow_target = get_node(follow_target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input(delta)
	$InnerPivot.rotation.x = clamp($InnerPivot.rotation.x, min_height, max_height)
	if not _follow_target == null:
		global_transform.origin = _follow_target.global_transform.origin
	pass


func _unhandled_input(event):
	if mouse_control and event is InputEventMouseMotion:
		if event.relative.x != 0:
			var dir = 1 if invert_x else -1
			rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
		if event.relative.y != 0:
			var dir = 1 if invert_y else -1
			var y_rotation = clamp(event.relative.y, -30, 30)
			$InnerPivot.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)


func check_input(delta):
	# Rotate outer gimbal around y axis
	var y_dir = -1 if invert_y else 1
	var y_rotation = 0
	if Input.is_action_pressed("camera_right"):
		y_rotation += 1
	if Input.is_action_pressed("camera_left"):
		y_rotation -= 1
	global_rotate(Vector3.UP, y_dir * y_rotation * rotate_speed * delta)
	
	# Rotate inner gimbal around x axis
	var x_dir = -1 if invert_x else 1
	var x_rotation = 0
	if Input.is_action_pressed("camera_up"):
		x_rotation -= 1
	if Input.is_action_pressed("camera_down"):
		x_rotation += 1
	$InnerPivot.rotate_object_local(Vector3.RIGHT, x_dir * x_rotation * rotate_speed * delta)

