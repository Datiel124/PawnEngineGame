extends InteractiveObject
@onready var mesh = $meshInstance3d
# Called when the node enters the scene tree for the first time.
func _ready():
	objectUsed.connect(healPawn)
	useSound.finished.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if beenUsed:
		mesh.transparency = lerpf(mesh.transparency, 1.0, 15*delta)
		if mesh.transparency >= 0.98:
			pass
			#queue_free()

func healPawn(pawn:BasePawn):
	if !beenUsed:
		if pawn:
			if pawn.healthComponent.health < 100:
				pawn.healthComponent.health = 100
				if pawn.attachedCam:
					pawn.attachedCam.fireVignette(0.9,Color.DARK_OLIVE_GREEN)
					pawn.attachedCam.fireRecoil(0,randf_range(0.15,0.8),0)
					globalGameManager.notifyFade("You've been healed.",2,1.5)
					globalGameManager.playSound(globalGameManager.getGlobalSound("healSound"))
					useSound.play()
				remove_from_group("Interactable")
				beenUsed = true
