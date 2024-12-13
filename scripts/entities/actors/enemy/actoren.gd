extends Actor
var path: Array = []
var _actions: int = actions

func _ready() -> void:
	super()
	WorldTurnBase.state.next_state.connect(func(world_state):
		if world_state == turn_state:
			path = WorldPathfinder.calculate_path(position, WorldTurnBase.players[0].position)
			path.pop_front()
			_actions = actions
			$Timer2.start()
	)

func _on_timer_timeout() -> void:
	if _actions > 0 and path.size() != 0:
		position = WorldPathfinder.map.map_to_local(path.pop_front())
		_actions -= 1
		$Timer2.start()
	else:
		WorldTurnBase.state.remove_player(self)
