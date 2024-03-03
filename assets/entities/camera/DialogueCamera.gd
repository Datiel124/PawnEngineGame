extends Node3D
@export var camera : Camera3D
@onready var horizontal = $horiz
@onready var vertical = $horiz/vertical

var return_cam : Camera3D = null
var targetPosition : Vector3
var targetRotation : Vector3


func _ready() -> void:
	var cam_to_copy = globalGameManager.activeCamera
	position = cam_to_copy.followingEntity.position
	vertical.rotation.x = globalGameManager.activeCamera.verticalHolder.rotation.x
	horizontal.rotation.y = globalGameManager.activeCamera.horizontal.rotation.y
	camera.fov = cam_to_copy.camera.fov
	camera.frustum_offset = cam_to_copy.camera.frustum_offset
	camera.attributes = cam_to_copy.camera.attributes
	camera.cull_mask = cam_to_copy.camera.cull_mask
	camera.keep_aspect = cam_to_copy.camera.keep_aspect
	camera.environment = cam_to_copy.camera.environment
	camera.doppler_tracking = cam_to_copy.camera.doppler_tracking
	camera.near = cam_to_copy.camera.near
	camera.far = cam_to_copy.camera.far


func activate(_return_cam, targetPos : Vector3, targetRot : Vector3) -> void:
	return_cam = _return_cam
	setTargetPosition(targetPos, targetRot)
	camera.make_current()


func setTargetPosition(tPosition : Vector3, tRotation : Vector3) -> void:
	targetPosition = tPosition
	targetRotation = tRotation

func _process(delta: float) -> void:
	if targetPosition != null:
		global_position = lerp(global_position,targetPosition,globalGameManager.dialogueCamLerpSpeed*delta)
		vertical.rotation.x = lerpf(vertical.rotation.x,targetRotation.x,globalGameManager.dialogueCamLerpSpeed*delta)
		horizontal.rotation.y = lerpf(horizontal.rotation.y,targetRotation.y,globalGameManager.dialogueCamLerpSpeed*delta)

func remove() -> void:
	return_cam.make_current()
	queue_free()
