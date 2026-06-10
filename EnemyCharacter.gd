
extends CharacterBody2D

@export var rhythm_system: NodePath
@export var attack_interval: float = 2.0 # How often the enemy tries to attack

var _rhythm_attack_system: RhythmAttackSystem
var _attack_timer: float = 0.0

func _ready() -> void:
	if rhythm_system:
		_rhythm_attack_system = get_node(rhythm_system) as RhythmAttackSystem
		if _rhythm_attack_system:
			_rhythm_attack_system.attack_successful.connect(_on_attack_successful)
			_rhythm_attack_system.attack_failed.connect(_on_attack_failed)
			print("Enemy RhythmAttackSystem connected.")
		else:
			printerr("RhythmAttackSystem node not found at path: %s" % rhythm_system)
	else:
		printerr("Rhythm system NodePath not set for EnemyCharacter.")

func _process(delta: float) -> void:
	_attack_timer += delta
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		attempt_attack()

func attempt_attack() -> void:
	if _rhythm_attack_system:
		_rhythm_attack_system.start_rhythm_sequence()
		# Simulate enemy input. For demonstration, let's make it sometimes perfect, sometimes slightly off.
		# In a real game, this might be based on enemy AI difficulty or a pattern.
		var simulated_input_time: float = _rhythm_attack_system._expected_attack_time
		# Introduce some randomness for enemy timing
		var random_offset: float = randf_range(-0.1, 0.1) # Within a small window
		_rhythm_attack_system.process_input(simulated_input_time + random_offset)
		print("Enemy attempting attack.")

func _on_attack_successful(strength: float) -> void:
	print("Enemy attack successful with strength: %s!" % strength)
	# TODO: Trigger enemy attack animation, deal damage, etc.

func _on_attack_failed() -> void:
	print("Enemy attack failed.")
	# TODO: Play enemy miss animation, feedback, etc.
