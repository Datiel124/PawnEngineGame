extends Node
const particles = {"Blood" : preload("res://assets/particles/bloodSpurt/bloodSpurt.tscn")}
const bulletHoles = {"Flesh": preload("res://assets/entities/bulletHoles/flesh/flesh.tscn"),
"default":preload("res://assets/entities/bulletHoles/default/BulletHole.tscn") }


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func detectMaterial(object:Object):
	if object.is_in_group("Blood") or object.is_in_group("Flesh"):
		return "Blood"
	else:
		return "None"

func createParticle(particle:String, pos:Vector3 = Vector3.ZERO, rot:Vector3 = Vector3.ZERO):
	if globalGameManager.world:
		if !particle == "None":
			var particleToCreate = particles[str(particle)].instantiate()
			globalGameManager.world.worldParticles.add_child(particleToCreate)
			particleToCreate.global_position = pos
			particleToCreate.global_rotation = rot
			particleToCreate.emitting = true
			return particleToCreate

func spawnBulletHole(hole:String,parent,pos:Vector3 = Vector3.ZERO, rot:Vector3 = Vector3.ZERO, ):
	if globalGameManager.world:
		var bHole = bulletHoles[str(hole)].instantiate()
		parent.add_child(bHole)
		bHole.global_position = pos
		bHole.global_rotation = rot
		return bHole
