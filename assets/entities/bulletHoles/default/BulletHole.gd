extends Node3D
class_name BulletHole

# Called when the node enters the scene tree for the first time.
func _ready():
	$impactParticle.emitting = true
	$dirtParticles.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
