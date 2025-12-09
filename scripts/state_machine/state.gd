@icon("res://assets/icons/s.svg")
@abstract
## Virtual base class for all states.
## Extend this class and override its methods to implement a state.
class_name State
extends Node

## Emitted when the state finishes and wants to transition to another state.
signal request_transition(next_state: State, data: Dictionary)

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_previous_state: State, _data: Dictionary = {}) -> void:
	pass


## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass
