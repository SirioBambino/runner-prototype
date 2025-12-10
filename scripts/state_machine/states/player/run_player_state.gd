class_name RunPlayerState
extends PlayerState

@export var fall_state: State
@export var charge_state: State


func update(_delta: float) -> void:
	player.request.desired_velocity = Vector2(player.move_speed, 0)

	if not player.is_on_floor:
		request_transition.emit(fall_state)
		return

	if Input.is_action_just_pressed("Jump"):
		request_transition.emit(charge_state)
		return
