class_name JumpPlayerState
extends PlayerState

@export var fall_state: State

var charge_ratio: float = 0.0
var jump_speed_multiplier: float = 1.5


func enter(_previous_state: State, _data: Dictionary = { }) -> void:
	charge_ratio = _data.get("jump_charge_ratio", 0.0)
	player.current_gravity *= jump_speed_multiplier * jump_speed_multiplier
	var jump_impulse: Vector2 = (
		lerp(player.min_jump_impulse, player.max_jump_impulse, charge_ratio)
		* jump_speed_multiplier
	)
	player.request.impulse = jump_impulse


func update(_delta: float) -> void:
	if player.linear_velocity.y > 0:
		request_transition.emit(fall_state)
