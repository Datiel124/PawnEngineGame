extends InteractiveObject
@export var cashAmount = 0
@onready var meshHolder = $meshes
# Called when the node enters the scene tree for the first time.
func _ready():
	customInteractText = "Pick up $%s" %cashAmount
	objectUsed.connect(pickupCash)
	useSound.finished.connect(queue_free)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pickupCash(pawn:BasePawn):
	if pawn.attachedCam:
		globalGameManager.notifyFade("$%s has been added to your balance." %cashAmount)
		pawn.attachedCam.fireRecoil(randf_range(1.15,1.8),0.0,randf_range(1.15,1.8),true)
	pawn.pawnCash += cashAmount
	meshHolder.hide()
	useSound.play()
	canBeUsed = false
	$collisionShape3d.disabled = true
	#queue_free()
