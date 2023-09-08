extends Control
@export_category("Hud")
@export var hudEnabled = true:
	set(value):
		if value == true:
			self.hide()
		else:
			self.show()

@onready var healthBar = $hpBar

# Called when the node enters the scene tree for the first time.
func _ready():
	hudEnabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hudEnabled:
		self.show()
	else:
		self.hide()
