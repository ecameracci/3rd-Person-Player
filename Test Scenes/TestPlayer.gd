extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	# $CameraHub.rotate_y(0.01)
	if to_global($TP_Player.transform.origin).y <= -5.0:
		print("Respawning player!")
		$TP_Player.transform.origin = Vector3(0.0, 0.0, 4.0)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("fire"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()
