extends Camera3D


var return_cam : Camera3D = null
var target_transform : Transform3D


func _ready() -> void:
	var cam_to_copy = get_viewport().get_camera_3d()
	global_transform = cam_to_copy.global_transform
	fov = cam_to_copy.fov
	frustum_offset = cam_to_copy.frustum_offset
	attributes = cam_to_copy.attributes
	cull_mask = cam_to_copy.cull_mask
	keep_aspect = cam_to_copy.keep_aspect
	environment = cam_to_copy.environment
	doppler_tracking = cam_to_copy.doppler_tracking
	near = cam_to_copy.near
	far = cam_to_copy.far


func activate(_return_cam, t_transform : Transform3D) -> void:
	return_cam = _return_cam
	set_target_transform(t_transform)
	make_current()


func set_target_transform(t_transform : Transform3D) -> void:
	target_transform = t_transform


func _process(delta: float) -> void:
	if target_transform != null:
		global_transform = global_transform.interpolate_with(target_transform, delta)


func remove() -> void:
	return_cam.make_current()
	queue_free()
