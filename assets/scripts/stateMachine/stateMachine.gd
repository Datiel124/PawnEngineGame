extends Node
class_name StateMachine
@export_category("State Machine")
@export var componentOwner : Node3D
@export var currentState: State
@export var stateDict : Dictionary = {}
@export var initialState : State

# Called when the node enters the scene tree for the first time.
func _ready():
	initializeStateMachine()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currentState:
		currentState.updateState(delta)

func _physics_process(delta):
	if currentState:
		currentState.physicsUpdateState(delta)

func onStateTransition(state, newStateName):
	if state != currentState:
		return

	var newState = stateDict.get(newStateName.to_lower())
	if !newState:
		return

	if currentState:
		currentState.exitState()

	newState.enterState()

	currentState = newState

func initializeStateMachine():
	for state in get_children():
		if state is State:
			stateDict[state.name.to_lower()] = state
			state.transitionState.connect(onStateTransition)
			state.componentOwner = self

	if initialState:
		initialState.enterState()
		currentState = initialState
