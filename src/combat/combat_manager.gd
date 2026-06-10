
# combat_manager.gd
extends Node

class_name CombatManager

enum State {
	INIT,
	PLAYER_TURN,
	ENEMY_TURN,
	RESOLUTION
}

signal state_changed(new_state: State)

var current_state: State = State.INIT

func _ready() -> void:
	# Initial state setup, can be called by an external manager to start combat
	pass

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	emit_state_changed(new_state)
	_on_state_entered(new_state)

func emit_state_changed(new_state: State) -> void:
	state_changed.emit(new_state)

func _on_state_entered(state: State) -> void:
	match state:
		State.INIT:
			print("Combat State: Initializing")
			# Logic for initialization, e.g., loading participants, setting up UI
		State.PLAYER_TURN:
			print("Combat State: Player Turn")
			# Logic for player turn, e.g., enabling player input
		State.ENEMY_TURN:
			print("Combat State: Enemy Turn")
			# Logic for enemy turn, e.g., AI decision making
		State.RESOLUTION:
			print("Combat State: Resolution")
			# Logic for resolution, e.g., checking win/loss conditions, distributing rewards
