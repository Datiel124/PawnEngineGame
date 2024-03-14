extends Node3D
class_name BulletHole
@onready var particles = $particles
var lookAtPoint
# Called when the node enters the scene tree for the first time.
func _ready():
	$particles/impactParticle.emitting = true
	$particles/dirtParticles.emitting = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
