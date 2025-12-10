extends Label

@onready var state_machine: StateMachine = $"../StateMachine"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var state = state_machine.current_state.name
	text = state
