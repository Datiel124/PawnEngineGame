extends Control
@export_category("Hud")
@export var cam : Camera3D
@onready var camVert = $"../camPivot/horizonal/vertholder/vertical"
@onready var camHoriz = $"../camPivot/horizonal"
@onready var camCast : RayCast3D = $"../camPivot/horizonal/vertholder/vertical/springArm3d/Camera/RayCast3D"
@export var crosshair : TextureRect
@export var fpsCounterEnabled = false
var slidingCrosshairPos : Vector2 = Vector2.ZERO
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
	Dialogic.timeline_started.connect(showMouse)
	Dialogic.timeline_ended.connect(hideMouse)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):


	#Crosshair Follow
	if UserConfig.game_crosshair_dynamic_position:
		var pos
		if camCast.is_colliding():
			pos = camCast.get_collision_point()
			slidingCrosshairPos = cam.unproject_position(pos)
				#crosshair.tint = Color.WHITE
		else:
			pos = get_owner().camCastEnd.global_position
			slidingCrosshairPos = cam.unproject_position(pos)


		crosshair.scale = clamp(crosshair.scale,Vector2(0.5,0.5),Vector2(1.5,1.5))
		crosshair.positionOverride = lerp(crosshair.positionOverride, slidingCrosshairPos, get_owner().recoilReturnSpeed*delta)

	if hudEnabled:
		self.show()
	else:
		self.hide()

	if fpsCounterEnabled:
		fpsControl.show()
		fpsLabel.text = "FPS: %s" %Engine.get_frames_per_second()
	else:
		fpsControl.hide()

func getCrosshair():
	if crosshair:
		return crosshair

func showMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hideMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
