extends MeshInstance3D
class_name BulletTrail
@export_category("Bullet Trail")
var alpha = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var mat
	if !get_material_override() == null:
		mat = get_material_override().duplicate()
		self.set_material_override(mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_material_override() == null:
		alpha -= delta * 25.5
		get_material_override().albedo_color.a = alpha

func initTrail(pos1, pos2):
	var meshDraw = ImmediateMesh.new()
	self.mesh = meshDraw
	meshDraw.surface_begin(Mesh.PRIMITIVE_LINES, get_material_override())
	meshDraw.surface_add_vertex(pos1)
	meshDraw.surface_add_vertex(pos2)
	meshDraw.surface_end()

func _on_timer_timeout():
	queue_free()
