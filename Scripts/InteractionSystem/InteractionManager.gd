extends Node2D
class_name InteractionManager


var current_interactable : InteractableObj
@export var mouse_interacter : MouseInteracter

func _ready() -> void:
	mouse_interacter.interaction_manager = self

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	
	if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if current_interactable != null:
			current_interactable.interact()

func set_interactable(_obj : InteractableObj) -> void:
	current_interactable = _obj

func remove_interactable() -> void:
	current_interactable = null
