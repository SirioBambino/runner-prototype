class_name FallPlayerState
extends PlayerState

@export var run_state: State

var jump_charge_ratio: float = 0.0


func enter(_previous_state_path: State, _data: Dictionary = { }) -> void:
	jump_charge_ratio = _data.get("jump_charge_ratio", 0.0)


func exit() -> void:
	player.current_gravity = player.default_gravity


func update(_delta: float) -> void:
	if player.is_on_floor:
		request_transition.emit(run_state)
