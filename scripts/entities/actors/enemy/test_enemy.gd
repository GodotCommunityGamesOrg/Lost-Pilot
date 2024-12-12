extends Actor
@export var timer: Timer
var path: Array = []

func _ready() -> void:
	super()
	WorldTurnBase.state.next_state.connect(
		func(world_state):
			if world_state == turn_state:
				path = WorldPathfinder.calculate_path(position, WorldTurnBase.players[0].position)
				path.pop_front()
				timer.start()
	)
	
	timer.timeout.connect(
		func():
			if _actions > 0 and path.size() != 0:
				position = WorldPathfinder.map.map_to_local(path.pop_front())
				_actions -= 1
				timer.start()
			else:
				WorldTurnBase.state.remove_actor(self)
	)
