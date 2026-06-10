
extends CharacterBody2D

@export var rhythm_system: NodePath

var _rhythm_attack_system: RhythmAttackSystem

func _ready() -> void:
	if rhythm_system:
		_rhythm_attack_system = get_node(rhythm_system) as RhythmAttackSystem
		if _rhythm_attack_system:
			_rhythm_attack_system.attack_successful.connect(_on_attack_successful)
			_rhythm_attack_system.attack_failed.connect(_on_attack_failed)
			print("RhythmAttackSystem connected.")
		else:
			printerr("RhythmAttackSystem node not found at path: %s" % rhythm_system)
	else:
		printerr("Rhythm system NodePath not set for PlayerCharacter.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and _rhythm_attack_system:
		_rhythm_attack_system.start_rhythm_sequence()
		print("Player initiated attack rhythm.")
	elif event.is_action_released("attack") and _rhythm_attack_system:
		# In a real game, you might want to capture the exact time of the press
		# For simplicity, we'll use the time when the action is released as the input_time
		# However, a better approach would be to capture time on is_action_pressed
		# and pass that exact timestamp.
		# For this example, we'll pass the current beat time from the rhythm system
		# assuming the rhythm system is constantly updating its internal beat time.
		_rhythm_attack_system.process_input(_rhythm_attack_system._current_beat_time)
		# A more accurate way would be to pass OS.get_ticks_msec() or similar at the press event

func _on_attack_successful(strength: float) -> void:
	print("Player attack successful with strength: %s!" % strength)
	# TODO: Trigger player attack animation, deal damage, etc.

func _on_attack_failed() -> void:
	print("Player attack failed.")
	# TODO: Play miss animation, feedback, etc.
