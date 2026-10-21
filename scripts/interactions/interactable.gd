class_name Interactable3D
extends Area3D

# Interaction Information
signal activated(interactable: Interactable3D)

@export var display_name: String = "Object"
@export var action_verb: String = "Examine"

@export var dialogue_pages: Array[String] = ["There is nothing unusual here."]

@export var one_time: bool = false

# Internal State
var used: bool = false

func is_available() -> bool:
	return not (one_time and used)
	
func activate() -> Array[String]:
	if not is_available(): return []
	
	if one_time: used = true
	
	activated.emit(self)
	
	return dialogue_pages.duplicate()
