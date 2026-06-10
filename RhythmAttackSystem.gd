
extends Node

signal attack_successful(attack_strength: float)
signal attack_failed()

@export var rhythm_window_size: float = 0.1  # The "perfect" timing window around the ideal beat
@export var forgiveness_window_size: float = 0.2 # Additional forgiving window on top of the rhythm_window_size
@export var attack_timing: float = 0.5 # The ideal time (0.0 to 1.0) within a beat cycle for an attack

var _current_beat_time: float = 0.0
var _is_rhythm_active: bool = false
var _expected_attack_time: float = 0.0

func _ready() -> void:
	pass

func start_rhythm_sequence() -> void:
	_is_rhythm_active = true
	# For simplicity, let's assume a beat duration for calculation.
	# In a real game, this would be synchronized with music or a timer.
	var beat_duration: float = 1.0 # Example: 1 second per beat
	_current_beat_time = 0.0
	_expected_attack_time = beat_duration * attack_timing
	print("Rhythm sequence started. Expected attack time: %s" % _expected_attack_time)

func process_input(input_time: float) -> void:
	if not _is_rhythm_active:
		return

	var time_difference: float = abs(input_time - _expected_attack_time)
	var perfect_window_start: float = _expected_attack_time - rhythm_window_size / 2.0
	var perfect_window_end: float = _expected_attack_time + rhythm_window_size / 2.0

	var forgiving_window_start: float = _expected_attack_time - (rhythm_window_size / 2.0 + forgiveness_window_size)
	var forgiving_window_end: float = _expected_attack_time + (rhythm_window_size / 2.0 + forgiveness_window_size)

	if input_time >= perfect_window_start and input_time <= perfect_window_end:
		attack_successful.emit(1.0) # Full strength for perfect timing
		_is_rhythm_active = false
		print("Perfect attack!")
	elif input_time >= forgiving_window_start and input_time <= forgiving_window_end:
		# Could implement a weaker attack or different feedback for forgiving timing
		attack_successful.emit(0.7) # Reduced strength for forgiving timing
		_is_rhythm_active = false
		print("Good attack (forgiving timing)!")
	else:
		attack_failed.emit()
		_is_rhythm_active = false
		print("Attack failed!")

# Example usage (can be called from another script or a test scene)
func _process(delta: float) -> void:
	if _is_rhythm_active:
		_current_beat_time += delta
		# In a real scenario, you'd likely have a separate timer/audio manager
		# that signals when a beat is expected, rather than continuous processing here.
		# For demonstration, we're just advancing _current_beat_time
		# and relying on process_input for the actual timing check.
		pass
