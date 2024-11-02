extends InteractableObj
class_name InteractableDoor

var door_state : bool = false

@export var animator : AnimatedSprite2D

func interact() -> void:
	# Switch bool
	door_state = !door_state
	
	handle_door()

func handle_door() -> void:
	match door_state:
		true:
			animator.play("Opening")
		false:
			animator.play("Closing")
