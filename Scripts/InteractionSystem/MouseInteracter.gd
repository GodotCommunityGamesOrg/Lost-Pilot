extends Area2D
class_name MouseInteracter

# This class is used for detecting other areas without 
# the need to connect the mouse entered function

var interaction_manager : InteractionManager

func _unhandled_input(event: InputEvent) -> void:
	# Only update the position when we move the mouse.
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position()


func _on_area_exited(obj: InteractableObj) -> void:
	interaction_manager.remove_interactable()

func _on_area_entered(obj: InteractableObj) -> void:
	interaction_manager.set_interactable(obj)
