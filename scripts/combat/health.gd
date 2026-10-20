class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_hp: int = 100

var current_hp: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
	
func take_damage(amount: int) -> void:
	if current_hp <= 0 or amount <= 0:
		return
		
	current_hp = maxi(current_hp - amount, 0)
	
	health_changed.emit(current_hp, max_hp)
	
	if current_hp == 0:
		died.emit()
		
func heal(amount: int) -> void:
	if current_hp <= 0 or amount <= 0:
		return
		
	current_hp = mini(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)
