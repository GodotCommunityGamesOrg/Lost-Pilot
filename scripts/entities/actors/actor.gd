extends Entity
class_name Actor

@export var turn_state: WorldTurnBase.StateMachine.STATES = WorldTurnBase.StateMachine.STATES.player
@export var actions: int = 2
func _ready() -> void:
	if WorldTurnBase.state.state == turn_state:
		WorldTurnBase.players.append(self)
	WorldTurnBase.state.next_state.connect(
		func(world_state):
			if world_state == turn_state:
				WorldTurnBase.state.players.append(self)
	)

func _unhandled_input(_event: InputEvent) -> void:
	if WorldTurnBase.state.state != turn_state:
		return

func _process(_delta: float) -> void:
	if WorldTurnBase.state.state != turn_state:
		return
