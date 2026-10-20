extends Node3D

@onready var status_label: Label = $CanvasLayer/PanelContainer/Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var controllers := Input.get_connected_joypads()
	
	if controllers.is_empty():
		status_label.text = "No controller detected.\nConnect your PS5 DualSense."
		return
	
	var device: int = controllers[0]
	
	var left_x := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
	var left_y := Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
	
	var right_x := Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
	var right_y := Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
	
	var l2 := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT)
	var r2 := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT)
	
	var pressed: PackedStringArray = []
	
	if Input.is_joy_button_pressed(device, JOY_BUTTON_A):
		pressed.append("Cross")
		
	if Input.is_joy_button_pressed(device, JOY_BUTTON_B):
		pressed.append("Circle")
		
	if Input.is_joy_button_pressed(device, JOY_BUTTON_X):
		pressed.append("Square")
		
	if Input.is_joy_button_pressed(device, JOY_BUTTON_Y):
		pressed.append("Triangle")
		
	if Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_SHOULDER):
		pressed.append("L1")
		
	if Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER):
		pressed.append("R1")
		
	var button_text := "None"
	
	if not pressed.is_empty():
		button_text = ", ".join(pressed)
		
	status_label.text = (
		"Controller: %s\n"
		+ "Left Stick: (%.2f, %.2f)\n"
		+ "Right Stick: (%.2f, %.2f)\n"
		+ "L2: %.2f | R2: %.2f\n"
		+ "Pressed: %s"
	) % [
		Input.get_joy_name(device),
		left_x, left_y,
		right_x, right_y,
		l2, r2,
		button_text
	]
