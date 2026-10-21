extends Node

# Attack Settings
@export var light_damage: int = 15
@export var heavy_damage: int = 30

@export var light_recovery: float = 0.45
@export var heavy_recovery: float = 0.9

# 0.35 means 35% damage gets through guard
@export var guard_damage_multiplier: float = 0.35

# Node References
@onready var health: HealthComponent = $"../Health"
@onready var attack_area: Area3D = $"../Visual/AttackArea"
@onready var sword_pivot: Node3D = $"../Visual/SwordPivot"

# Internal Variables
var recovery_left: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sword_pivot.rotation_degrees.z = -50.0
	health.died.connect(_on_player_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if health.current_hp <= 0:
		return
		
	# No attacks while a conversation is open
	if get_parent().get("controls_locked") == true:
		return
		
	recovery_left = maxf(recovery_left - delta, 0.0)
	
	if Input.is_action_just_pressed("light_attack"):
		_try_attack(light_damage, light_recovery, "Light")
		
	elif Input.is_action_just_pressed("heavy_attack"):
		_try_attack(heavy_damage, heavy_recovery, "Heavy")
		
# Attack Handling
func _try_attack(
	damage: int,
	recovery: float,
	attack_name: String
) -> void:
	
	# Cannot attack during recovery or while guarding
	if recovery_left > 0.0:
		return
		
	if Input.is_action_pressed("guard"):
		return
		
	recovery_left = recovery
	
	_swing_sword()
	
	var enemies_hit: int = 0
	
	for body in attack_area.get_overlapping_bodies():
		
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.call("take_damage", damage)
				enemies_hit += 1
				
	print(
		attack_name,
		" attack! Damage: ",
		damage,
		" | Enemies hit: ",
		enemies_hit
	)
	
# Placeholder sword swing
func _swing_sword() -> void:
	sword_pivot.rotation_degrees.z = -50.0
	
	var swing: Tween = create_tween()
	
	swing.tween_property(
		sword_pivot,
		"rotation_degrees:z",
		65.0,
		0.15
	)
	
	swing.tween_property(
		sword_pivot,
		"rotation_degrees:z",
		-50.0,
		0.2	
	)
	
# Receiving damage
func receive_damage(amount: int) -> void:
	if health.current_hp <= 0:
		return
		
	var final_damage: int = amount
		
	if Input.is_action_pressed("guard"):
		final_damage = maxi(
			1,
			int(round(amount * guard_damage_multiplier))
		)
		print("Attack guarded!")
		
	health.take_damage(final_damage)
	
	print(
		"Player took ",
		final_damage,
		" damage. HP: ",
		health.current_hp
	)
	
func _on_player_died() -> void:
	print("Player defeated! Restart the test scene.")
