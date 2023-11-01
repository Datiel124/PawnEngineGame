extends Control
@export_category("Hud")
@export var fpsCounterEnabled = false
@export var hudEnabled = true:
	set(value):
		if value == true:
			self.hide()
		else:
			self.show()

@onready var healthBar = $hpBar
@onready var fpsControl = $FPSCounter
@onready var fpsLabel = $FPSCounter/label

# Called when the node enters the scene tree for the first time.
func _ready():
	hudEnabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hudEnabled:
		self.show()
	else:
		self.hide()

	if fpsCounterEnabled:
		fpsControl.show()
		fpsLabel.text = "FPS: %s" %Engine.get_frames_per_second()
	else:
		fpsControl.hide()
