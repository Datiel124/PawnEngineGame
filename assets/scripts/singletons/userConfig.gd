extends Node

#game configs
var game_lowHP_ambience = false
var game_show_fps = false
var game_camera_screentilt_always = false
var game_aim_screentilt = true
var game_crosshair_tilt = true
var game_crosshair_dynamic_position = true
var game_simple_crosshairs = false

#audio configs
var audio_MasterVolume : float = -15.0
var audio_GameVolume : float = 1.0
var audio_MusicVolume : float = 0.6
var audio_ambience_volume : float = 0.6
var audio_UiVolume : float = 0.6
var audio_custom_music_enabled : bool = false

#graphics settings
var graphics_resolution : int = 0
var graphics_fullscreen : bool = false
var graphics_screenspace_aa : int = 0:
	set(value):
		graphics_screenspace_aa = value
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa",graphics_screenspace_aa)
var graphics_msaa : int = 0:
	set(value):
		graphics_msaa = value
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d
",graphics_msaa)
var graphics_Ssr : bool = false
var graphics_Sdfgi : bool = false
var graphics_Ssil : bool = false
enum PARTICLE_COUNT{VERY_FEW, LESS, NORMAL}
enum WORLD_DETAILS{VERY_FEW, LESS, NORMAL}
var graphics_particle_amount : PARTICLE_COUNT = PARTICLE_COUNT.NORMAL
var graphics_world_details : WORLD_DETAILS = WORLD_DETAILS.NORMAL


var configs_loaded : bool = false
signal finish_loading_configs
signal configs_updated
func _ready() -> void:
	print(getSettingsDict())
	loadConfigs()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveConfigs()


func loadConfigs() -> void:
	var configs = ConfigFile.new()
	var err = configs.load("user://user_settings.cfg")

	if err != OK:
		return

	for section in configs.get_sections():
		for key in configs.get_section_keys(section):
			set(section.to_lower()+"_"+key, configs.get_value(section, key))
#	print("Loaded configs.")
	configs_loaded = true
	applyConfigs()


func saveConfigs() -> void:
	var configs = ConfigFile.new()

	for property in get_script().get_script_property_list():
		if property["usage"] == 128:
			continue
		var section = (property["name"] as String).split("_", 0)
		if section[0] == "configs":
			continue
		var key = (property["name"] as String).replace(section[0]+"_", "")
		configs.set_value(section[0].to_upper(), key, get(property["name"]))
#		print("Set section %s key %s with value %s" % [section, key, get(property["name"])])
	configs.save("user://user_settings.cfg")
#	print("Finished saving configs.")
	applyConfigs()


func applyConfigs() -> void:
	AudioServer.set_bus_volume_db(0, audio_MasterVolume)
	AudioServer.set_bus_volume_db(1, audio_UiVolume)
	AudioServer.set_bus_volume_db(2, audio_GameVolume)
	AudioServer.set_bus_volume_db(3, audio_MusicVolume)
	AudioServer.set_bus_volume_db(4, audio_ambience_volume)
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if graphics_fullscreen else Window.MODE_WINDOWED
	configs_updated.emit()


func getSettingsDict() -> Dictionary:
	var output : Dictionary = {}
	for property in get_script().get_script_property_list():
		if property["usage"] == 128:
			continue
		var section = (property["name"] as String).split("_", 0)
		if section[0] == "configs":
			continue
		output[property["name"]] = get(property["name"])
	return output


func getOption(optionString:String):
	return optionString
