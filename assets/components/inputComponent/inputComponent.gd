extends Component
class_name InputComponent
#Signals
signal movementKeyPressed(key:String)
signal actionPressed(button:InputEventKey)
signal actionHeldDown(action:InputEventKey)
signal mouseButtonPressed(button:InputEventMouseButton)
signal mouseButtonHeld(button:InputEventMouseButton)
signal onMouseMotion(motion:InputEventMouseMotion)

#Variables
##Enables the movement keys to be emitted
var movementEnabled = true
##Enables the mouse action buttons to be emitted
var mouseActionsEnabled = true
var mouseButtonInput = InputEventMouseButton.new()
var inputDir = Vector3(Input.get_action_strength("gMoveRight") - Input.get_action_strength("gMoveLeft"), 0, Input.get_action_strength("gMoveBackward") - Input.get_action_strength("gMoveForward"))
var controllingPawn

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mouseActionsEnabled:
		if Input.is_action_pressed("gRightClick"):
			if controllingPawn:
				if !controllingPawn.isPawnDead:
						controllingPawn.turnAmount = -controllingPawn.attachedCam.vertical.rotation.x
						controllingPawn.freeAim = false
						controllingPawn.freeAimTimer.stop()
						if !controllingPawn.meshLookAt:
							controllingPawn.meshLookAt = true
							controllingPawn.meshRotation = controllingPawn.attachedCam.camRot
							controllingPawn.isRunning = false
							controllingPawn.canRun = false
		else:
			if controllingPawn:
				controllingPawn.meshLookAt = false
				if !controllingPawn.freeAim:
					controllingPawn.canRun = true
					controllingPawn.freeAim = false
		if Input.is_action_pressed("gLeftClick"):
			if controllingPawn:
				if !controllingPawn.isRunning:
					if !controllingPawn.currentItem == null:
						if !Input.is_action_pressed("gRightClick"):
							if !controllingPawn.freeAim:
								controllingPawn.canRun = false
								controllingPawn.freeAim = true
								controllingPawn.meshRotation = controllingPawn.attachedCam.camRot
						controllingPawn.currentItem.fire()
						controllingPawn.freeAimTimer.start()
		else:
			if controllingPawn:
				if !Input.is_action_pressed("gRightClick"):
					controllingPawn.canRun = true

	if controllingPawn:
		if controllingPawn.freeAim:
			controllingPawn.turnAmount = -controllingPawn.attachedCam.vertical.rotation.x

func getInputDir():
	inputDir = Vector3(Input.get_action_strength("gMoveRight") - Input.get_action_strength("gMoveLeft"), 0, Input.get_action_strength("gMoveBackward") - Input.get_action_strength("gMoveForward"))
	return inputDir

func _unhandled_input(event):
	if mouseActionsEnabled:
		if event is InputEventMouseMotion:
			emit_signal("onMouseMotion", event)

		if event is InputEventMouseButton:
			if event.pressed:
				emit_signal("mouseButtonPressed",event.button_index)

			if event.is_action_pressed("gMwheelUp"):
				emit_signal("mouseButtonPressed", event.button_index)
				if controllingPawn:
					controllingPawn.currentItemIndex = controllingPawn.currentItemIndex+1

			if event.is_action_pressed("gMwheelDown"):
				emit_signal("actionPressed", str(event.button_index))
				if controllingPawn:
					controllingPawn.currentItemIndex = controllingPawn.currentItemIndex-1

	if event is InputEventKey:
		if event.is_action_pressed("gJump"):
			emit_signal("actionPressed", str(event.keycode))
			if controllingPawn:
				if controllingPawn.canJump:
					controllingPawn.jump()

		if event.is_action_pressed("gUse"):
			emit_signal("actionPressed", str(event.keycode))

		if event.is_action_pressed("dKill"):
			emit_signal("actionPressed", str(event.keycode))
			if controllingPawn:
				controllingPawn.healthComponent.health = 0


##Movement Code
	if movementEnabled:
		if Input.get_action_strength("gSprint") >= 1:
			emit_signal("movementKeyPressed","Sprint")
			if controllingPawn:
				if controllingPawn.canRun:
					controllingPawn.isRunning = true
					controllingPawn.freeAim = false

		else:
			if controllingPawn:
				controllingPawn.isRunning = false

		if Input.get_action_strength("gMoveRight") >= 1:
			emit_signal("movementKeyPressed","Right")

		if Input.get_action_strength("gMoveLeft") >= 1:
			emit_signal("movementKeyPressed","Left")

		if Input.get_action_strength("gMoveForward") >= 1:
			emit_signal("movementKeyPressed","Forward")

		if Input.get_action_strength("gMoveBackward") >= 1:
			emit_signal("movementKeyPressed","Backward")






