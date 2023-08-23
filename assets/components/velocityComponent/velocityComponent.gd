extends Component
class_name VelocityComponent
##Velocity Component provides a velocity that can be manipulated by a node.

var vVelocity = Vector3.ZERO

##Velocity acceleration time
@export var vAcceleration = 0.5
##Maximum speed this velocity component can go to
@export var vMaxSpeed = 8.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func accelerateToVel(velocity:Vector3,delta, useX:bool=true,useY:bool=true,useZ:bool=true):
	if useX:
		vVelocity.x = lerp(vVelocity.x, velocity.x * vMaxSpeed, delta * vAcceleration )
	if useY:
		vVelocity.y = lerp(vVelocity.y, velocity.y * vMaxSpeed, delta * vAcceleration )
	if useZ:
		vVelocity.z = lerp(vVelocity.z, velocity.z * vMaxSpeed, delta * vAcceleration)
	
	return vVelocity
	
func getAcceleration():
	return vAcceleration
