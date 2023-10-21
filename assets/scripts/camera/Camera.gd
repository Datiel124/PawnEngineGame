extends CharacterBody3D
class_name PlayerCamera
##Variable Set
var lowHP = false
var freeCursor = false:
	set(value):
		if value == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if value == true:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get:
		return freeCursor
var isFreecam = true
var speed = 9.0
var acceleration = 3.0
var vertVeclocity = Vector3.ZERO
@export_subgroup("Camera")
@export var cameraData : CameraData
@export var followingEntity : Node3D
@export var followNode : Node3D:
	set(value):
		followNode = value
	get:
		return followNode
#onReady Set
@onready var vignette = $HUD/vignette
@onready var hpAudio = $HUD/vignette/lowHP
@onready var hud = $HUD
@onready var weaponHud = $HUD/weaponBar
@onready var horizontal = $camPivot/horizonal
@onready var vertical = $camPivot/horizonal/vertical
@onready var camera = $camPivot/horizonal/vertical/Camera
@onready var camPivot = $camPivot
@onready var camCast = $camPivot/horizonal/vertical/Camera/RayCast3D
@onready var camCastEnd = $camPivot/horizonal/vertical/Camera/RayCast3D/camRayEnd

@export_subgroup("Behavior")
var motionX = 0.0
var motionY = 0.0
@export var itemEquipOffsetToggle = false

@export_subgroup("Recoil")
var camEuler
@export var camRecoilStrength : float
@export var camReturnSpeed : float
@export var camRecoil : Vector3
@export var camCurrRot : Vector3
@export var camTargetRot : Vector3
var camReturnVect = Vector3(motionX, motionY, 0)
@export_subgroup("Zoom")
@export var isZoomed = false
@export var currentFOV = 90.0
@export var zoomAmount = 25.0
@export var zoomSpeed = 16.0
var aimFOV

#Component Set
@export_subgroup("Components")
@export var velocityComponent : Node
@export var inputComponent : Node

var direction = Vector3.ZERO
var camRot

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var recoilers : Array[CameraRecoiler] = []

func _ready():
	globalGameManager.activeCamera = self
	currentFOV = globalGameManager.defaultFOV
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	aimFOV = currentFOV - zoomAmount
	Fade.fade_in(0.3, Color(0,0,0,1),"GradientVertical",false,true)


func _input(_event):
	if Input.is_action_pressed("gEscape"):
		freeCursor = true

	if Input.is_action_pressed("gRightClick"):
		isZoomed = true
	else:
		isZoomed = false


func _physics_process(delta):
	#Weapon Hud
	if !followNode == null:
		if followingEntity is BasePawn:
			if followingEntity.currentItem:
				weaponHud.modulate = lerp(weaponHud.modulate,Color(1,1,1,0.8),12*delta)
			else:
				weaponHud.modulate = lerp(weaponHud.modulate,Color(1,1,1,0.0),12*delta)

	##Recoil
	var rotation_offset = accumulateRecoil(delta)
	rotation = rotation_offset

	#Zooming
	if isZoomed:
		camera.fov = lerpf(camera.fov, currentFOV, zoomSpeed * delta)
		currentFOV = aimFOV
	else:
		camera.fov = lerpf(camera.fov, currentFOV, zoomSpeed * delta)
		currentFOV = globalGameManager.defaultFOV

	##Set the camera rotation
	camRot = vertical.global_transform.basis.get_euler().y

	##Pass the rotation of the camera to the pawn
	if !followNode == null:
		if followingEntity is BasePawn:
			followingEntity.meshRotation = camRot
			hud.healthBar.value = lerpf(hud.healthBar.value,followingEntity.healthComponent.health, 20 * delta)

	##Lerp to FollowNode

	if !followNode == null:
		self.global_position.x = lerp(self.global_position.x, followingEntity.rootCameraNode.global_position.x, cameraData.camLerpSpeed*delta)
		self.global_position.y = lerp(self.global_position.y, followingEntity.rootCameraNode.global_position.y, cameraData.camLerpSpeed*delta)
		self.global_position.z = lerp(self.global_position.z, followingEntity.rootCameraNode.global_position.z, cameraData.camLerpSpeed*delta)

		#camPivot.position.x = lerp(camPivot.position.x , cameraData.cameraOffset.x, cameraData.camLerpSpeed*delta)
		#vertical.position.z = lerp(vertical.position.z , cameraData.cameraOffset.z, cameraData.camLerpSpeed*delta)
		vertical.position.y = lerp(vertical.position.y, cameraData.cameraOffset.y, cameraData.camLerpSpeed*delta)
		vertical.spring_length = lerp(vertical.spring_length, cameraData.cameraOffset.z, cameraData.camLerpSpeed*delta)
		if !itemEquipOffsetToggle:
			horizontal.position.x = lerp(horizontal.position.x, cameraData.cameraOffset.x, cameraData.camLerpSpeed*delta)
		else:
			horizontal.position.x = lerp(horizontal.position.x, cameraData.itemEquipOffset.x, cameraData.itemEquipLerpSpeed*delta)
	#Low HP
	if lowHP:
		vignette.show()
		vignette.get_material().set_shader_parameter("softness",lerpf(vignette.get_material().get_shader_parameter("softness"), 0.8,2*delta))
		if !hpAudio.playing:
			hpAudio.play()
	else:
		vignette.get_material().set_shader_parameter("softness",lerpf(vignette.get_material().get_shader_parameter("softness"), 10.0,4*delta))
		hpAudio.stop()

	if !followNode == null:
		if followingEntity is BasePawn:
			if followingEntity.healthComponent:
				if !followingEntity.healthComponent.isDead:
					if followingEntity.healthComponent.health <= 30:
						lowHP = true
					else:
						lowHP = false
	#Freecam Movement
	if isFreecam:
		followNode = null

		vertVeclocity = Vector3.ZERO

		if !inputComponent == null:
			direction = inputComponent.getInputDir().rotated(Vector3.UP, camRot)

		if direction != Vector3.ZERO:
			direction = direction.normalized()

		if Input.is_action_pressed("dCamUp"):
			vertVeclocity.y = 1
		if Input.is_action_pressed("dCamDown"):
			vertVeclocity.y = -1.0

		velocity.x = velocityComponent.accelerateToVel(direction, delta, true, false, false).x
		velocity.y = velocityComponent.accelerateToVel(vertVeclocity, delta, false, true, false).y
		velocity.z = velocityComponent.accelerateToVel(direction, delta, false, false, true).z

		move_and_slide()


func accumulateRecoil(delta : float) -> Vector3:
	var accumulatedRecoil : Vector3 = Vector3.ZERO
	#Iterate over the recoilers
	for r in recoilers:
		#If the length is 0, we erase it.
		if r.rotation_offset.length() == 0.0:
			recoilers.erase(r)
			continue
		#Otherwise, add the recoil.
		accumulatedRecoil += r.rotation_offset
		r.decay(delta * camReturnSpeed)
	return accumulatedRecoil


func applyRecoil(recoil_vector : Vector3) -> void:
	recoilers.append(CameraRecoiler.new(recoil_vector))


func _on_input_component_mouse_button_pressed(button):
	if isFreecam:
		if button == 1:
			freeCursor = false


func _on_input_component_mouse_button_held(button):
	if button == 1:
		print(button)


func _on_input_component_on_mouse_motion(motion):
	motionX = rad_to_deg(-motion.relative.x * globalGameManager.mouseSens)
	motionY = rad_to_deg(-motion.relative.y * globalGameManager.mouseSens)

	camPivot.rotation_degrees.y += motionX
	vertical.rotation_degrees.x += motionY
	#Lock Cam
	vertical.rotation.x = clamp(vertical.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func posessObject(object, posessPart:Node3D = object):
	if object.is_in_group("Posessable"):
		followingEntity = object
		isFreecam = false
		followNode = posessPart
		object.attachedCam = self
		cameraData = object.pawnCameraData
		if object is BasePawn:
			vertical.add_excluded_object(object.get_rid())


func unposessObject(freecam:bool = false):
	if freecam:
		isFreecam = true
	followingEntity.attachedCam = null
	cameraData = null
	followNode = null


func getAttachedOwner():
	if !followNode == null:
		return followNode.get_parent().get_owner()
	else:
		return false


func applyWeaponSpread(spread):
	camCast.position = Vector3(randf_range(-spread, spread),randf_range(-spread, spread),0)


#Camera Recoiler object- used to accumulate rotational offset with recoil.
#	Things to consider
#	💡 using a different decay formula
#	💡 using curves
#	💡 adding decay_rate
class CameraRecoiler extends RefCounted:
	var rotation_offset : Vector3

	func _init(recoil_vector : Vector3) -> void:
		rotation_offset = recoil_vector

	func decay(rate : float) -> Vector3:
		rotation_offset = rotation_offset.move_toward(Vector3.ZERO, rate)
		return rotation_offset
