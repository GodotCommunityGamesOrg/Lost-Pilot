class_name WorldTurnBase
## A class representing the core logic for a turn-based game system. It maintains the game state, manages player interactions, and controls transitions between different phases (player, enemy, NPC). The class also includes a nested StateMachine class for state-specific functionality.

## Reference to the current players for interaction.
static var players: Array[UserActor] = []
## State machine instance managing game states.
static var state: StateMachine = StateMachine.new()
## Tracks whether the game state is active.
static var on: bool = false

# StateMachine class to handle turn-based states.
class StateMachine:

	## Signal emitted when transitioning to a new state.
	signal next_state(state: STATES) ## Emitted when the game transitions to a new state.

	## List of actors (players, enemies, NPCs) in the current state.
	var actors: Array[Actor]:
		set(val):
			actors = val
			if !WorldTurnBase.on:
				return
				
			if val == []:
				state = (state + 1) % (STATES.size()) as STATES 

	## Current state of the game (default: player turn).
	var state: STATES = STATES.player:
		set(val):
			state = val
			next_state.emit(state)

			if actors == []:
				actors = []

	# Enumeration defining possible game states.
	enum STATES {
		## Player's turn.
		player,
		## Enemy's turn.
		enemy,
		## NPC's turn.
		npc
	}
	
	## Removes a player from the list of actors.
	func remove_actor(player: Actor):
		actors.erase(player)

		if actors == []:
			state = (state + 1) % (STATES.size()) as STATES
