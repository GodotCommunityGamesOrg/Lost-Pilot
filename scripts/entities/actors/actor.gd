extends Entity
class_name Actor
## Base class for all actors within the game, inheriting from [Entity].

## Setting to determine when the [Actor] will take its turn.
@export var turn_state: WorldTurnBase.StateMachine.STATES = WorldTurnBase.StateMachine.STATES.player 

## Number of actions available per turn for the [Actor].
@export var actions: int = 2

## Tracks the current remaining actions during the [Actor]'s turn.
var _actions: int = 2

func _ready() -> void:
	# Checks if the game state matches the actor's turn state and adds the actor to the turn system.
	if WorldTurnBase.state.state == turn_state:
		WorldTurnBase.players.append(self)
	
	# Connects the turn state change signal to a function that manages the actor's actions and state.
	WorldTurnBase.state.next_state.connect(
		func(world_state):
			# Resets actions and adds the actor to the active list if the turn state matches.
			if world_state == turn_state:
				_actions = actions
				WorldTurnBase.state.actors.append(self)
	)


func _unhandled_input(_event: InputEvent) -> void:
	if WorldTurnBase.state.state != turn_state:
		return


func _process(_delta: float) -> void:
	if WorldTurnBase.state.state != turn_state:
		return
