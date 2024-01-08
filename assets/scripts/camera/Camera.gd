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
@onready var verticalHolder = $camPivot/horizonal/vertholder
@onready var vertical = $camPivot/horizonal/vertholder/vertical
@onready var camera = $camPivot/horizonal/vertholder/vertical/Camera
@onready var camPivot = $camPivot
@onready var camCast = $camPivot/horizonal/vertholder/vertical/Camera/RayCast3D
@onready var camCastEnd = $camPivot/horizonal/vertholder/vertical/Camera/RayCast3D/camRayEnd
@onready var debugCast = $camPivot/horizonal/vertholder/vertical/Camera/debugCast

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
var aimFOV
@export var isZoomed = false
@export var currentFOV = 90.0
@export var zoomAmount = 25.0:
	set(value):
		zoomAmount = value
		aimFOV = currentFOV - value
		if cameraData:
			zoomAmount = cameraData.zoomAmount

var defaultZoomAmount = 25.0
var defaultZoomSpeed = 16.0
@export var zoomSpeed = 16.0:
	set(value):
		zoomSpeed = value
		if cameraData:
			zoomSpeed = cameraData.zoomSpeed

#Component Set
@export_subgroup("Components")
@export var velocityComponent : Node
@export var inputComponent : Node

var direction = Vector3.ZERO
var camRot

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
				$HUD/Crosshair.modulate = lerp(weaponHud.modulate,Color(1,1,1,1),12*delta)
				weaponHud.modulate = lerp(weaponHud.modulate,Color(1,1,1,0.8),12*delta)
			else:
				$HUD/Crosshair.modulate = lerp(weaponHud.modulate,Color(1,1,1,0.2),48*delta)
				weaponHud.modulate = lerp(weaponHud.modulate,Color(1,1,1,0.0),12*delta)

	##Recoil - Currently broken.. Needs fixing..
	camTargetRot.x = lerp(camTargetRot.x, 0.0, camReturnSpeed * delta)
	camTargetRot.y = lerp(camTargetRot.y, 0.0, camReturnSpeed * delta)
	camTargetRot.z = lerp(camTargetRot.z, 0.0, camReturnSpeed * delta)
	camCurrRot = lerp(camCurrRot,camTargetRot,camRecoilStrength * delta)
	verticalHolder.rotation_degrees.x = camCurrRot.x
	horizontal.rotation_degrees.y = camCurrRot.y
	camera.rotation_degrees.z = camCurrRot.z

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
		camPivot.global_position.x = lerp(camPivot.global_position.x, followNode.global_position.x, cameraData.camLerpSpeed*delta)
		camPivot.global_position.y = lerp(camPivot.global_position.y, followNode.global_position.y, cameraData.camLerpSpeed*delta)
		camPivot.global_position.z = lerp(camPivot.global_position.z, followNode.global_position.z, cameraData.camLerpSpeed*delta)

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
		#followingEntity.inputComponent = null
		camPivot.global_position.x = lerp(camPivot.global_position.x, self.global_position.x, 8*delta)
		camPivot.global_position.y = lerp(camPivot.global_position.y, self.global_position.y, 8*delta)
		camPivot.global_position.z = lerp(camPivot.global_position.z, self.global_position.z, 8*delta)
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
	if object.is_in_group("Posessable") and !object == null:
		if globalGameManager.world:
			globalGameManager.activeCamera = self
		followingEntity = object
		isFreecam = false
		followNode = posessPart
		object.attachedCam = self
		cameraData = object.pawnCameraData
		if object is BasePawn:
			vertical.add_excluded_object(object.get_rid())

		if "inputComponent" in followingEntity:
			if followingEntity.inputComponent != null:
				if followingEntity.inputComponent is InputComponent:
					followingEntity.inputComponent.movementEnabled = true
					followingEntity.inputComponent.mouseActionsEnabled = true
					followingEntity.inputComponent.controllingPawn = object

func unposessObject(freecam:bool = false):
	if freecam:
		isFreecam = true
		if followingEntity.inputComponent is InputComponent:
			followingEntity.inputComponent.movementEnabled = false
			followingEntity.inputComponent.mouseActionsEnabled = false
			followingEntity.inputComponent.controllingPawn = null
	followingEntity.attachedCam = null
	cameraData = null
	followNode = null


func getAttachedOwner():
	if !followNode == null:
		return followNode.get_parent().get_owner()
	else:
		return false

func fireRecoil(setRecoilX:float = 0.0,setRecoilY:float = 0.0,setRecoilZ:float = 0.0,):
	if setRecoilX:
		camRecoil.x += setRecoilX
	if setRecoilY:
		camRecoil.y += setRecoilY
	if setRecoilZ:
		camRecoil.z += setRecoilZ
	camTargetRot = Vector3(camRecoil.x, randf_range(-camRecoil.y,camRecoil.y), randf_range(-camRecoil.z,camRecoil.z) )

func applyWeaponSpread(spread):
	if followingEntity.isFirstperson:
		camCast.position = Vector3.ZERO
	else:
		camCast.position = Vector3(randf_range(-spread, spread),randf_range(-spread, spread),0)

func resetCamCast():
	camCast.position = Vector3.ZERO
