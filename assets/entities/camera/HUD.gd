extends Control
@export_category("Hud")
@export var cam : Camera3D
@onready var interactHud = $Interact
@onready var interactText = $Interact/richTextLabel
@onready var camVert = $"../camPivot/horizonal/vertholder/vertical"
@onready var camHoriz = $"../camPivot/horizonal"
@onready var camCast : RayCast3D = $"../camPivot/horizonal/vertholder/vertical/springArm3d/Camera/RayCast3D"
@export var crosshair : TextureRect
@export var fpsCounterEnabled = false
@onready var healthBG = $hpBG
@onready var healthTexture = $healthTexture
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
var interactVisible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hudEnabled = true
	Dialogic.timeline_started.connect(globalGameManager.showMouse)
	Dialogic.timeline_ended.connect(globalGameManager.hideMouse)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If in Dialogue
	if interactVisible:
		interactHud.modulate = lerp(interactHud.modulate, Color.WHITE, 8*delta)
		interactHud.position.y = lerpf(interactHud.position.y, crosshair.position.y + 15, 8*delta)
		interactHud.position.x = lerpf(interactHud.position.x, crosshair.position.x + 35, 8*delta)
	else:
		interactHud.modulate = lerp(interactHud.modulate, Color.TRANSPARENT, 8*delta)

	if Dialogic.current_timeline != null:
		hudEnabled = true
	else:
		hudEnabled = false
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
		healthBar.self_modulate = lerp(healthBar.self_modulate,Color.WHITE,12*delta)
		healthBG.self_modulate = lerp(healthBG.self_modulate,Color.WHITE,12*delta)
		healthTexture.self_modulate = lerp(healthTexture.self_modulate,Color.WHITE,12*delta)
	else:
		crosshair.tintCrosshair(Color.TRANSPARENT)
		healthBar.self_modulate = lerp(healthBar.self_modulate,Color.TRANSPARENT,12*delta)
		healthBG.self_modulate = lerp(healthBG.self_modulate,Color.TRANSPARENT,12*delta)
		healthTexture.self_modulate = lerp(healthTexture.self_modulate,Color.TRANSPARENT,12*delta)

	if fpsCounterEnabled:
		fpsControl.show()
		fpsLabel.text = "FPS: %s" %Engine.get_frames_per_second()
	else:
		fpsControl.hide()

func getCrosshair():
	if crosshair:
		return crosshair

func setInteractionText(text : String):
	interactText.text = text
