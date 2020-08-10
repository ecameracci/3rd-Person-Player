extends KinematicBody

# Declaration of member variables here
const GRAVITY : float = -9.81				# Rate per second for falling
const MAX_TERMINAL_VELOCITY : float = 54.0	# Max fall speed

export var speed : float = 6.0				# How fast the player moves horizontally
export var jump_force : float = 6.0			# How fast the player jumps
export var hurt_force : float = 4.0			# Knockback force when hurt
export var rotation_speed : float = 0.2		# Rotation speed, angle in radians
export var acceleration : float = 15.0		# How fast the player changes speed on the ground
export var air_acceleration : float = 5.0	# How fast the player changes speed in the air

var _fall_multiplier : float = 2.5			# Used when falling from max height
var _low_jump_multiplier : float = 2.0		# Used when falling before reaching max height
var _is_damaged : bool = false				# Keep track of if the player is damaged
var _is_jumping : bool = false				# Keep track of if the player is jumping
var _can_move : bool = true					# Used to set if the player can move

var _cam									# Reference to the camera to get direction
var _input_direction						# Input movement direction
var _direction : Vector3 = Vector3.ZERO 	# Player's direction in world space
var _velocity : Vector3 = Vector3.ZERO		# Player's velocity at any given point
var _y_velocity : float = 0.0				# Player's vertical velocity


# Called when the node enters the scene tree for the first time.
func _ready():
	_cam = get_node("../TP_Camera")
	if _cam == null:
		print("No camera called TP_Camera found!")


func _physics_process(delta):
	apply_gravity(delta)	# Apply a downward force
	apply_direction(delta)	# Get the direction the player should move
	apply_rotation(delta)	# Rotate the player in the direction of movement
	apply_jumping()			# Apply a jumping force
	apply_movement()		# Move the character and handle animation events


func apply_gravity(delta):
	if is_on_floor() and not _is_damaged:
		_y_velocity = -0.01
	else:
		if _y_velocity < 0.0:
			_y_velocity = _y_velocity + (GRAVITY * _fall_multiplier * delta)
		elif _y_velocity > 0.0 and not _is_jumping:
			_y_velocity = _y_velocity + (GRAVITY * _low_jump_multiplier * delta)
		else:
			_y_velocity = _y_velocity + (GRAVITY * delta)
	_y_velocity = clamp(_y_velocity, -MAX_TERMINAL_VELOCITY, MAX_TERMINAL_VELOCITY)
	
	_velocity.y = _y_velocity


func apply_direction(delta):
	if not _can_move:
		return

	var move_z = Input.get_action_strength("move_back") - \
		Input.get_action_strength("move_forward")
	var move_x = Input.get_action_strength("move_right") - \
		Input.get_action_strength("move_left")
	_input_direction = Vector3(move_x, 0.0, move_z).normalized()
	_direction = (transform.basis.z * move_z) + (transform.basis.x * move_x)
	_direction = _direction.normalized()	
	
	var accel = acceleration if is_on_floor() else air_acceleration
	_velocity = _velocity.linear_interpolate(_direction * speed, accel * delta)


func apply_rotation(delta):
	if _direction.length() >= 0.1:
		rotation.y = _cam.rotation.y
		var move_angle = transform.basis.z.angle_to(-_direction)
		if _input_direction.x > 0.0:
			move_angle *= -1
		$PlayerBody.rotation.y = lerp_angle($PlayerBody.rotation.y, move_angle, rotation_speed)
	pass


func apply_jumping():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_is_jumping = true
		_y_velocity = jump_force
		
	if Input.is_action_just_released("jump"):
		_is_jumping = false
		
	_velocity.y = _y_velocity


func apply_movement():
	_velocity = move_and_slide(_velocity, Vector3.UP)


func apply_wall_jump():
	# TODO Implementation
	pass


# Called to damage the player
func take_damage():
	_is_damaged = true
	_velocity *= -1
	_y_velocity = hurt_force
	_velocity.y = _y_velocity

	_can_move = false
	yield(get_tree().create_timer(0.5), "timeout")
	_can_move = true
	_is_damaged = false

