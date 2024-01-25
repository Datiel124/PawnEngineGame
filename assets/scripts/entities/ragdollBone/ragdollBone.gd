extends PhysicalBone3D
class_name RagdollBone
signal onHit(impulse,vector)
@export_category("Ragdoll Bone")
@export_subgroup("Impact Hits")
@export var hardImpactEffectEnabled : bool = true
@export var impactEffectHard : PackedScene
@export var mediumImpactEffectEnabled : bool = true
@export var impactEffectMedium : PackedScene
@export var lightImpactEffectEnabled : bool = true
@export var impactEffectLight : PackedScene
@export_subgroup("Sounds")
@export var inAirSound : AudioStream
@export var lightImpactSounds : AudioStreamRandomizer
@export var mediumImpactSounds : AudioStreamRandomizer
@export var heavyImpactSounds : AudioStreamRandomizer
@export_subgroup("Thresholds")
@export var lightImpactThreshold : float = 4
@export var mediumImpactThreshold : float = 12
@export var heavyImpactThreshold : float = 32
@export_range(-1.0, 1.0) var impact_dot_min : float
@export_subgroup("Collision Information")
@export var collisionSound : AudioStream
@export_subgroup("Information")
@export var currentVelocity : Vector3
@export var contactCount : int

var audioStreamPlayer : AudioStreamPlayer3D
var inAirStreamPlayer : AudioStreamPlayer3D

var audioCooldown : float = 0.0
var exclusionArray : Array[RID]

# Called when the node enters the scene tree for the first time.
func _ready():
	PhysicsServer3D.body_set_max_contacts_reported(RID(self), 1)
	audioStreamPlayer = AudioStreamPlayer3D.new()
	add_child(audioStreamPlayer)
	audioStreamPlayer.max_polyphony = 2
	audioStreamPlayer.max_db = 0
	audioStreamPlayer.max_distance = 32
	audioStreamPlayer.unit_size = 0.5
	audioStreamPlayer.attenuation_filter_db = 0
	audioStreamPlayer.attenuation_filter_cutoff_hz = 3000
	if inAirSound != null:
		inAirStreamPlayer = AudioStreamPlayer3D.new()
		add_child(inAirStreamPlayer)
		inAirStreamPlayer.stream = inAirSound
		inAirStreamPlayer.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
		inAirStreamPlayer.panning_strength = 3.0
		inAirStreamPlayer.volume_db = -80.0
		inAirStreamPlayer.max_db = 0
		inAirStreamPlayer.max_distance = 32
		inAirStreamPlayer.unit_size = 0.25
		inAirStreamPlayer.attenuation_filter_db = -30
		inAirStreamPlayer.attenuation_filter_cutoff_hz = 6000
		inAirStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state:PhysicsDirectBodyState3D):
	currentVelocity = state.get_linear_velocity()
	contactCount = state.get_contact_count()

	if audioCooldown > 0:
			return

	if state.get_contact_count() > 0:
		if exclusionArray.has(state.get_contact_collider(0)):
			return
		var contactNormal = state.get_contact_local_normal(0)
		var contactDot = state.get_contact_local_velocity_at_position(0).normalized().dot(contactNormal)
		var contactForce = state.get_contact_local_velocity_at_position(0).length()

		audioStreamPlayer.attenuation_filter_db = lerp(-20, 0, clamp(abs(contactDot) * contactForce, 0, 1))
		if contactForce > heavyImpactThreshold:
			audioStreamPlayer.stream = heavyImpactSounds
			audioStreamPlayer.play()
			audioCooldown = 0.05
			if hardImpactEffectEnabled:
				if impactEffectHard == null:
					globalParticles.createParticle("BloodSpurt",self.position).look_at(self.position + contactNormal/2)
			return
		if contactForce > mediumImpactThreshold:
			audioStreamPlayer.stream = mediumImpactSounds
			audioStreamPlayer.play()
			audioCooldown = 0.25
			if mediumImpactEffectEnabled:
				if impactEffectMedium == null:
					globalParticles.createParticle("BloodSpurt",self.position).look_at(self.position + contactNormal/2)
			return
		if contactForce > lightImpactThreshold:
			audioStreamPlayer.stream = lightImpactSounds
			var fac = (contactForce - lightImpactThreshold) / (mediumImpactThreshold - lightImpactThreshold)
			audioStreamPlayer.volume_db = lerp(-5, 0, fac)
			audioStreamPlayer.play()
			audioCooldown = 0.25
			if lightImpactEffectEnabled:
				if impactEffectLight == null:
					globalParticles.createParticle("BloodSpurt",self.position).look_at(self.position + contactNormal/2)
			return

func _process(delta):
	audioCooldown -= delta
	if inAirStreamPlayer != null:
		var fac = clamp(linear_velocity.length() * angular_velocity.length_squared() / 1000.0, 0.0, 1.0)
		if linear_velocity.length() < 2.0:
			fac *= 0
		#Realistically it would only play the sound as its whipping towards the viewer
		inAirStreamPlayer.volume_db = lerp(inAirStreamPlayer.volume_db, -80 + (fac * 80), delta * 6)
		inAirStreamPlayer.pitch_scale = lerp(inAirStreamPlayer.pitch_scale, (angular_velocity.length() / 500.0) + 2.0, delta * 4)


func hit(dmg, dealer=null, hitImpulse:Vector3 = Vector3.ZERO, hitPoint:Vector3 = Vector3.ZERO):
	emit_signal("onHit",hitImpulse,hitPoint)
	apply_impulse(hitImpulse, hitPoint)
