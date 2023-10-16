extends Node3D
class_name DayNightCycle

@export_category("Day and Night Cycle")
@export_subgroup("Behavior")
@export var freezeTime = false
@export_subgroup("Variables")
@export var worldTime : float
@export var dayLength : float = 10.0
@export var startTime : float = 4.0
@export var rateTime : float
@export var sun : DirectionalLight3D
@export var moon : DirectionalLight3D
@export_subgroup("Sun")
@export var sunColor : Gradient
@export var sunIntensity : Curve
@export_subgroup("Moon")
@export var moonColor : Gradient
@export var moonIntensity : Curve
@export_subgroup("Environment")
@export var environment : WorldEnvironment
@export var skyTopColor : Gradient
@export var skyHorizonColor : Gradient

# Called when the node enters the scene tree for the first time.
func _ready():
	rateTime = 1.0 / dayLength
	worldTime = startTime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !freezeTime:
		worldTime += rateTime*delta

	if worldTime >= 1.0:
		worldTime = 0.0


	#Sun Rotation
	sun.rotation_degrees.x = worldTime * 360 + 90
	sun.light_color = sunColor.sample(worldTime)
	sun.light_energy = sunIntensity.sample(worldTime)

	#Moon Rotation
	moon.rotation_degrees.x = worldTime * 360 + 270
	moon.light_color = moonColor.sample(worldTime)
	moon.light_energy = moonIntensity.sample(worldTime)


	#Sun/Moon Enable
	sun.visible = sun.light_energy > 0
	moon.visible = moon.light_energy > 0

	#Environment Color Set
	environment.environment.sky.sky_material.set("ground_horizon_color", skyHorizonColor.sample(worldTime))
	environment.environment.sky.sky_material.set("ground_bottom_color", skyTopColor.sample(worldTime))
	environment.environment.sky.sky_material.set("sky_horizon_color", skyHorizonColor.sample(worldTime))
	environment.environment.sky.sky_material.set("sky_top_color", skyTopColor.sample(worldTime))
