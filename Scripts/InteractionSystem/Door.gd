extends InteractableObj
class_name InteractableDoor
var door_state : bool = false
@export var anim:AnimatedSprite2D
func _ready() -> void:
	priority = 2
	interact()

func interact() -> void:
	door_state = !door_state
	match door_state:
		true:
			global.pathfinder.set_point_solid(global.map.local_to_map(position), true)
			anim.play_backwards("open")
			priority = 2
		false:
			global.pathfinder.set_point_solid(global.map.local_to_map(position), false)
			anim.play("open")
			priority = 1
