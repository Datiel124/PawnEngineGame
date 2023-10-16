@icon("res://assets/scripts/AnimationControl/animation_control_icon.png")
@tool
extends Control
class_name AnimatedControl


@export var target_controls : Array[Control]:
	set(value):
		for i in value.size():
			var meta_name = "blend_"+str(i)
			set_meta(meta_name, get_meta(meta_name, 0.0))
			print("Added meta %s" % meta_name)
		for over_meta in get_meta_list():
			if over_meta.begins_with("blend_"):
				var num = over_meta.split("_", false)[1]
				if int(num) > value.size()-1:
					print("Removed meta %s" % over_meta)
					remove_meta(over_meta)
		notify_property_list_changed.call_deferred()
		target_controls = value
@export var interpolate_size : bool = false


func _get_configuration_warnings() -> PackedStringArray:
	if target_controls.size() == 0:
		return ["No target controls set."]
	if target_controls[0] == null:
		return ["0th index must be set."]
	return []


func _process(delta: float) -> void:
	if Engine.get_process_frames() % 20 == 0:
		update_configuration_warnings()
	if target_controls.size() > 0:
		if target_controls[0] == null:
			return
		global_position = target_controls[0].global_position
		if interpolate_size:
			size = target_controls[0].size
		for i in target_controls.size():
			if target_controls[i] == null:
				continue
			var blend_amount = get_meta("blend_"+str(i),0.0)
			global_position = lerp(global_position, target_controls[i].global_position, blend_amount)
			if interpolate_size:
				size = lerp(size, target_controls[i].size, blend_amount)
