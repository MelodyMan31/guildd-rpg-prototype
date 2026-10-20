extends Label

@onready var player: Node = get_tree().get_first_node_in_group("player")

@onready var health: HealthComponent = player.get_node("Health") as HealthComponent

func _process(delta: float) -> void:
	var status: String = "Ready"
	
	if health.current_hp <= 0:
		status = "Defeated"
		
	elif Input.is_action_pressed("guard"):
		status = "Guarding"
		
	text = (
		"HP: %d / %d\n"
		+ "Status: %s\n\n"
		+ "Square / LMB: Light Attack\n"
		+ "Trianlge / RMB: Heavy Attack\n"
		+ "L1 / Q: Guard\n"
		+ "Circle / Space: Dodge"
	) % [
		health.current_hp,
		health.max_hp,
		status
	]
