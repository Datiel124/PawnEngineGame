extends Node


var current_player : AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	#Scale audio pitch with timescale.
	AudioServer.playback_speed_scale = Engine.time_scale


func isPlayerPlaying():
	if current_player.playing:
		return true
	else:
		return false

func change_song_to_file(file_path : String, fade_duration : float = 0.0, at_position : float = 0.0) -> void:
	if file_path == "" and current_player != null:
		fade_player_out(current_player, fade_duration)
		return
	var song = load(file_path)
	if not (song is AudioStream):
		push_warning(false, "The file at 'file_path' is not an AudioStream.")
		return
	change_song_to(song, fade_duration, at_position)


func change_song_to(song : AudioStream, fade_duration : float = 0.0, at_position : float = 0.0) -> void:
	fade_player_out(current_player, fade_duration)
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	current_player = new_player
	new_player.bus = &"Music"
	new_player.stream = song
	#new_player.volume_db = -80
	new_player.play(at_position)
	fade_player_in(new_player, fade_duration)


func fade_player_out(player : AudioStreamPlayer, duration : float) -> void:
	if player == null: return
	var vol : float = 1.0
	player.set_meta("_fading_in", false)
	while vol > 0:
		vol -= get_process_delta_time() / duration
		player.volume_db = linear_to_db(clamp(vol, 0, 1))
		await get_tree().process_frame
	player.queue_free()


func fade_player_in(player : AudioStreamPlayer, duration : float) -> void:
	if player == null: return
	player.set_meta("_fading_in", true)
	var vol : float = 0.0
	while vol < 1 and player.get_meta("_fading_in", false):
		vol += get_process_delta_time() / duration
		player.volume_db = linear_to_db(clamp(vol, 0, 1))
		await get_tree().process_frame
	player.volume_db = 0

func pauseMusic():
	if current_player != null:
		if isPlayerPlaying():
			current_player.stream_paused = true

func resumeMusic():
	if current_player != null:
		current_player.stream_paused = false
