extends CharacterBody3D

# Enemy Settings
@export var move_speed: float = 2.2
@export var attack_range: float = 1.55
@export var attack_damage: int = 10
@export var attack_interval: float = 1.5

# References
@onready var health: HealthComponent = $Health
@onready var visual: Node3D = $Visual
@onready var hp_label: Label3D = $HPLabel

var player: CharacterBody3D = null

# Internal Variables
var attack_timer: float = 0.0

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
	add_to_group("enemies")
	
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	
	health.health_changed.connect(_update_hp_label)
	health.died.connect(_on_died)
	
	_update_hp_label(health.current_hp, health.max_hp)
	
# Enemy Movement and Attacks
func _physics_process(delta: float) -> void:
	if health.current_hp <= 0:
		return
		
	if not is_instance_valid(player):
		return
		
	attack_timer = maxf(attack_timer - delta, 0.0)
	
	var direction: Vector3 = (player.global_position - global_position)
	
	direction.y = 0.0
	
	var distance: float = direction.length()
	
	# Always Face the Player
	if distance > 0.01:
		var target_angle: float = atan2(-direction.x, -direction.z)
		
		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			target_angle,
			minf(8.0 * delta, 1.0)
		)
		
	# Approach the Player
	if distance > attack_range:
		var move_direction: Vector3 = direction.normalized()
		
		velocity.x = move_direction.x * move_speed
		velocity.z = move_direction.z * move_speed
		
	else:
		# Stop and Attack
		velocity.x = 0.0
		velocity.z = 0.0
		
		if attack_timer <= 0.0:
			var player_combat: Node = player.get_node_or_null("Combat")
			
			if player_combat != null:
				player_combat.call("receive_damage", attack_damage)
				
			attack_timer = attack_interval
			
	# Apply Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
		
	move_and_slide()
	
# Damage and Death
func take_damage(amount: int) -> void:
	health.take_damage(amount)
	
func _update_hp_label(current: int, maximum: int) -> void:
	hp_label.text = (
		"Training Enemy\nHP: %d / %d"
		% [current, maximum]
	)
	
func _on_died() -> void:
	print("Training Enemy defeated!")
	queue_free()
