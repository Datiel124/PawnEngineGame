extends Component
class_name HealthComponent
signal onDamaged(dealer)
signal healthChanged
signal healthDepleted
@export_category("Component")
var lastDealer
@export var health = 100:
	set(value):
		health = value
		emit_signal("healthChanged")
	get:
		return health
@export var isDead = false
var componentOwner
var killerSignalEmitted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	componentOwner = get_owner()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !isDead:
		if health <= 0:
			health = 0
			emit_signal("healthDepleted")
			isDead = true
			if lastDealer != null:
				if !killerSignalEmitted:
					lastDealer.emit_signal("killedPawn")
					killerSignalEmitted = true

func damage(amount, dealer:Node3D = null):
	emit_signal("onDamaged",dealer)
	health = health - amount
	lastDealer = dealer


