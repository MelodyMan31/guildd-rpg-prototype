extends CharacterBody3D

# Movement Settings
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var rotation_speed: float = 12.0

# Dodge Settings
@export var dodge_speed: float = 11.0
@export var dodge_duration: float = 0.25
@export var dodge_cooldown: float = 0.6

# Camera Settings
@export var mouse_sensitivity: float = 0.002
@export var controller_sensitivity: float = 2.5

@export var minimum_pitch: float = -65.0
@export var maximum_pitch: float = 35.0

# Node References
@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var player_camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

# Internal Variables
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

var dodge_time_left: float = 0.0
var dodge_cooldown_left: float = 0.0

var controls_locked: bool = false
var sprint_requires_release: bool = false

var dodge_direction: Vector3 = Vector3.FORWARD

# Stop player movement during interactions
func set_controls_locked(locked: bool) -> void:
	controls_locked = locked
	
	if locked:
		# Stop horizontal movement immediately
		velocity.x = 0.0
		velocity.z = 0.0
		
		# Cancel any active dodge
		dodge_time_left = 0.0
		
		# Require sprint to be released before using it again
		sprint_requires_release = true

func _ready() -> void:
	add_to_group("player")
	
	# Prevent the camera from colliding with our player
	spring_arm.add_excluded_object(get_rid())
	
	# Capture mouse omvement for camera rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Mouse Camera Controls
func _unhandled_input(event: InputEvent) -> void:
	if controls_locked:
		return
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
			
			spring_arm.rotation.x -= (event.relative.y * mouse_sensitivity)
			
			_clamp_camera_pitch()
			
# Controller Camera Controls
func _update_controller_camera(delta: float) -> void:
	var look_input: Vector2 = Input.get_vector(
		"camera_left",
		"camera_right",
		"camera_up",
		"camera_down",
		0.2
	)
			
	camera_pivot.rotate_y(-look_input.x * controller_sensitivity * delta)
			
	spring_arm.rotation.x -= (look_input.y * controller_sensitivity * delta)
			
	_clamp_camera_pitch()

func _clamp_camera_pitch() -> void:
	spring_arm.rotation.x = clampf(
		spring_arm.rotation.x,
		deg_to_rad(minimum_pitch),
		deg_to_rad(maximum_pitch)
	)

# Player Movement
func _physics_process(delta: float) -> void:
	# Allow sprinting again after releasing the button
	if not Input.is_action_pressed("sprint"):
		sprint_requires_release = false
	
	# Disable movement during conversations
	if controls_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = -0.1
			
		move_and_slide()
		return
	
	_update_controller_camera(delta)
	
	# Count down the dodge cooldown every frame
	dodge_cooldown_left = maxf(dodge_cooldown_left - delta, 0.0)
	
	# Read left stick or WASD
	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back",
		0.2
	)
	
	# Calculate movement relative to the camera
	var forward: Vector3 = -player_camera.global_transform.basis.z
	var right: Vector3 = player_camera.global_transform.basis.x
	
	forward.y = 0.0
	right.y = 0.0
	
	forward = forward.normalized()
	right = right.normalized()
	
	var move_direction: Vector3 = (right * input_direction.x - forward * input_direction.y)
	
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
		
	# Begin a dodge if available
	if Input.is_action_just_pressed("dodge"):
		if dodge_time_left <= 0.0 and dodge_cooldown_left <= 0.0:
			if move_direction.length_squared() > 0.01:
				dodge_direction = move_direction.normalized()
			else:
				dodge_direction = forward
				
			dodge_time_left = dodge_duration
			dodge_cooldown_left = dodge_cooldown
			
	var facing_direction: Vector3 = move_direction
	
	# Apply dodge or regular movement
	if dodge_time_left > 0.0:
		velocity.x = dodge_direction.x * dodge_speed
		velocity.z = dodge_direction.z * dodge_speed
		
		facing_direction = dodge_direction
		dodge_time_left -= delta
		
	else:
		var current_speed: float = walk_speed
		
		if Input.is_action_pressed("sprint") and not sprint_requires_release:
			current_speed = sprint_speed
			
		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed
		
	# Rotate the visible character toward movement
	if facing_direction.length_squared() > 0.01:
		var target_angle: float = atan2(
			-facing_direction.x,
			-facing_direction.z
		)
		
		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			target_angle,
			minf(rotation_speed * delta, 1.0)
		)
		
	# Perform collision-aware movement
	move_and_slide()
