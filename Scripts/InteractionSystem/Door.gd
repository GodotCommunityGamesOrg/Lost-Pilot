extends InteractableObj
class_name InteractableDoor
var door_state : bool = false
@export var anim:AnimatedSprite2D
@export var audio: AudioStreamPlayer2D
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	priority = 2
	interact()

func interact() -> void:
	door_state = !door_state
	match door_state:
		true:
			global.pathfinder.set_point_solid(global.map.local_to_map(position), true)
			anim.play_backwards("open")
			audio.pitch_scale = rng.randf_range(1, 1.5) # randomize pitch scale to avoid sounding to repetitive
			audio.play()
			priority = 2
		false:
			global.pathfinder.set_point_solid(global.map.local_to_map(position), false)
			anim.play("open")
			audio.pitch_scale = rng.randf_range(1, 1.5) # randomize pitch scale to avoid sounding to repetitive
			audio.play()
			priority = 1
