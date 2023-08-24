@tool

extends Node3D
class_name SoundQueue
@export_category("Sound Queue")
@export var soundCount : int
var nextAudio : int
var audioList : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() == 0:
		print("No children found")
		return
	
	var audioChild = get_child(0)
	
	if audioChild is AudioStreamPlayer3D:
		audioList.append(audioChild.duplicate())
		
		for audios in soundCount:
			var audioDup = audioChild.duplicate()
			add_child(audioDup)
			audioList.append(audioDup)



func _get_configuration_warnings():
	if get_child_count() == 0:
		return String ("No children found")
		
	if !get_child(0) is AudioStreamPlayer3D:
		return String ("Expecting an AudioStreamPlayer3D")
	
	return _get_configuration_warnings()


func playSound():
	if !audioList[nextAudio].playing:
		audioList[nextAudio+1].play()
		nextAudio %= audioList.size() - 1
