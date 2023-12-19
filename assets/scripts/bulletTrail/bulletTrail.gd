extends MeshInstance3D
class_name BulletTrail
@export_category("Bullet Trail")
var alpha = 1.0
var mat
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	if !get_material_override() == null:
		mat = get_material_override().duplicate()
		self.set_material_override(mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_material_override() == null:
		transparency += 0.08

		if transparency >= 1:
			queue_free()

func initTrail(pos1, pos2):
	var meshDraw = ImmediateMesh.new()
	self.mesh = meshDraw
	meshDraw.surface_begin(Mesh.PRIMITIVE_LINES, get_material_override())
	meshDraw.surface_add_vertex(pos1)
	meshDraw.surface_add_vertex(pos2)
	meshDraw.surface_end()

func _on_timer_timeout():
	queue_free()
