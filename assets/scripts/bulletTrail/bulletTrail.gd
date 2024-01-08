extends MeshInstance3D
class_name BulletTrail
@export_category("Bullet Trail")
var bulletSpeed = 40.0
var alpha = 1.0
var mat
var bulletStart : Vector3 = Vector3.ZERO
var bulletEnd
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	if !get_material_override() == null:
		mat = get_material_override().duplicate()
		self.set_material_override(mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mesh:
		bulletStart = lerp(bulletStart,bulletEnd,delta*bulletSpeed)
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		mesh.surface_add_vertex(bulletStart)
		mesh.surface_add_vertex(bulletEnd)
		mesh.surface_end()

	if !get_material_override() == null:

		transparency += 0.02

		if transparency >= 1:
			queue_free()

func initTrail(pos1, pos2):
	bulletStart = pos1
	bulletEnd = pos2
	var meshDraw = ImmediateMesh.new()
	self.mesh = meshDraw
	meshDraw.surface_begin(Mesh.PRIMITIVE_LINES, get_material_override())
	meshDraw.surface_add_vertex(bulletStart)
	meshDraw.surface_add_vertex(bulletEnd)
	meshDraw.surface_end()

func _on_timer_timeout():
	queue_free()
