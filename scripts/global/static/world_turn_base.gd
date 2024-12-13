class_name WorldTurnBase

## A class representing the core logic for a turn-based game system. It maintains the game state, manages player interactions, and controls transitions between different phases (player, enemy, NPC). The class also includes a nested StateMachine class for state-specific functionality.

# Static variables shared across all instances of this class.
static var players: Array[UserActor] = []      ## Reference to the current players for interaction.
static var state: StateMachine = StateMachine.new() ## State machine instance managing game states.
static var on: bool = false                    ## Tracks whether the game state is active.

# StateMachine class to handle turn-based states.
class StateMachine:

	# Signal emitted when transitioning to a new state.
	signal next_state(state: STATES) ## Emitted when the game transitions to a new state.

	# List of actors (players, enemies, NPCs) in the current state.
	var players: Array[Actor]:
		set(val): ## Set function for updating the list of actors.
			players = val ## Update the players list with the provided value.
			if !WorldTurnBase.on: ## If the game is not active, exit early.
				return

			if val == []: ## If no players remain, move to the next state.
				state = (state + 1) % (STATES.size()) as STATES ## Cycle to the next state.

	# Current state of the game (default: player turn).
	var state: STATES = STATES.player:
		set(val): ## Set function for updating the current state.
			state = val ## Update the current state.
			next_state.emit(state) ## Emit the signal for state transition.

			if players == []: ## Reset players list if empty.
				players = [] ## Ensure the players list is initialized.

	# Enumeration defining possible game states.
	enum STATES {
		player, ## Player's turn.
		enemy,  ## Enemy's turn.
		npc     ## NPC's turn.
	}

	# Removes a player from the list of actors.
	func remove_player(player: Actor):
		players.erase(player) ## Remove the specified player from the list.

		if players == []: ## If the list becomes empty, transition to the next state.
			state = (state + 1) % (STATES.size()) as STATES ## Cycle to the next state.
