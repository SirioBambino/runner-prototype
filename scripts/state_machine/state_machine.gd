@icon("res://assets/icons/sm.svg")
@tool
class_name StateMachine
extends Node
## A node used to structure parent behaviour using child [State]s.
##
## Attach [State] nodes as children of this node to set up a Finite State Machine (FSM).
## [br][br]
## [StateMachine] ensures that only one state is active at any time and delegates processing,
## physics processing, and input handling to it.
## It also handles entering and exiting states when transitions occur.
## [br][br]
## States can request transitions through signals, which the StateMachine handles by exiting the
## current state and entering the requested one.
## [br][br]
## The [member initial_state] property sets the state to enter when the node is ready, defaulting
## to the first child if not set.
## [br][br]
## [b]Adapted from: [url=https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/]
## GDQuest – Finite State Machine in Godot 4[/url][/b]

## The [State] entered when the [StateMachine] becomes ready.
## Defaults to the first child [State] if null.
@export var initial_state: State = null

## The currently active [State].
var current_state: State = null
var states: Array[State] = []


## Initialises the [StateMachine], entering the [member initial_state].
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var state_nodes: Array[State] = []
	for node: Node in find_children("*", "State"):
		var state_node: State = node as State
		state_nodes.append(state_node)
		states.append(state_node)
		state_node.request_transition.connect(_transition_to_next_state)

	assert(state_nodes.size() > 0, "StateMachine must have at least one child State node.")
	if initial_state != null:
		current_state = initial_state

	var first_child: Node = get_child(0)
	if first_child is State:
		current_state = first_child

	if current_state != null:
		current_state.enter(null)


## Changes the current state to the [State] at the given node path.
func _transition_to_next_state(target_state: State, data: Dictionary = {}) -> void:
	if not Engine.is_editor_hint():
		assert(
			states.has(target_state),
			owner.name + ": The state " + target_state.name + " is not part of this StateMachine.",
		)

		if target_state == current_state:
			return

		var previous_state: State = current_state
		current_state.exit()
		current_state = target_state
		current_state.enter(previous_state, data)


## Updates the current [State] each frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		current_state.update(delta)


## Updates the current [State] during the physics step.
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		current_state.physics_update(delta)


## Forwards unhandled input events to the current [State].
func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		current_state.handle_input(event)


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()


## Warns the user if the node configuration in the scene tree is not valid.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	var children: Array[Node] = get_children()

	if children.is_empty():
		warnings.append("This node has no child nodes. Add at least one State as a child.")

	for child: Node in children:
		if child is not State:
			warnings.append("This node contains non-State children. Only State nodes should be direct children.")
			break

	return warnings
