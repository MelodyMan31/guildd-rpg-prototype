extends Area3D

# References
@onready var player: Node = get_parent()

var interaction_ui: InteractionUI = null
var current_target: Interactable3D = null

# Detect nearby objects
func _physics_process(_delta: float) -> void:
	# Find the scene's interaction interface
	if interaction_ui == null:
		interaction_ui = (
			get_tree().get_first_node_in_group(
				"interaction_ui"
			) as InteractionUI
		)
		
		if interaction_ui != null:
			interaction_ui.dialogue_closed.connect(
				_on_dialogue_closed
			)
	
	if interaction_ui == null:
		return
		
	# Do not change targets while talking
	if interaction_ui.dialogue_open:
		return
		
	current_target = _find_nearest_interactable()
	
	if current_target == null:
		interaction_ui.set_prompt("")
		return
		
	interaction_ui.set_prompt(
		"E / Cross: %s %s"
		% [
			current_target.action_verb,
			current_target.display_name
		]
	)
	
# Choose closest interactable
func _find_nearest_interactable() -> Interactable3D:
	var nearest: Interactable3D = null
	var nearest_distance: float = INF
	
	for area in get_overlapping_areas():
		var target := area as Interactable3D
		
		if target == null:
			continue
			
		if not target.is_available():
			continue
			
		var distance_squared: float = (
			global_position.distance_squared_to(
				target.global_position
			)
		)
		
		if distance_squared < nearest_distance:
			nearest = target
			nearest_distance = distance_squared
			
	return nearest
	
# Activate Interactions
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
		
	if interaction_ui == null:
		return
		
	# Advance existing dialogue first
	if interaction_ui.dialogue_open:
		interaction_ui.advance_dialogue()
		
		get_viewport().set_input_as_handled()
		return
		
	# Otherwise, activate a nearby object
	if current_target == null:
		return
		
	if not is_instance_valid(current_target):
		return
		
	if not current_target.is_available():
		return
		
	var new_pages: Array[String] = (current_target.activate())
	
	if new_pages.is_empty():
		return
		
	interaction_ui.open_dialogue(
		current_target.display_name,
		new_pages
	)
	
	# Temporarily disable player movement
	player.set("controls_locked", true)
	
	get_viewport().set_input_as_handled()
	
# Restore Movement
func _on_dialogue_closed() -> void:
	player.set("controls_locked", false)
