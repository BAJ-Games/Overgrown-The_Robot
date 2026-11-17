@tool
extends MeshInstance3D
class_name Arch3D


@export_category("Arch")

@export var width: float = 4.0:
	set(value):
		width = max(value, 0.1)
		_generate_arch()

@export var height: float = 4.0:
	set(value):
		height = max(value, 0.1)
		_generate_arch()

@export var depth: float = 0.5:
	set(value):
		depth = max(value, 0.05)
		_generate_arch()

@export var radius: float = 2.0:
	set(value):
		radius = max(value, 0.1)
		_generate_arch()


func _ready():
	_generate_arch()


func _generate_arch():
	var mesh_data = ArrayMesh.new()

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	var segments = 32

	var inner_radius = min(radius, width / 2.0)

	# Wandstärke
	var thickness = 0.5
	var outer_radius = inner_radius + thickness

	# Höhe, an der der Rundbogen beginnt
	var arch_start_height = height - inner_radius


	# -------------------------------------------------
	# Linker Pfeiler
	# -------------------------------------------------

	_add_box(
		vertices,
		indices,
		Vector3(-width / 2.0, 0, 0),
		Vector3(
			(width - inner_radius * 2.0) / 2.0,
			arch_start_height,
			depth
		)
	)


	# -------------------------------------------------
	# Rechter Pfeiler
	# -------------------------------------------------

	_add_box(
		vertices,
		indices,
		Vector3(
			inner_radius,
			0,
			0
		),
		Vector3(
			(width - inner_radius * 2.0) / 2.0,
			arch_start_height,
			depth
		)
	)


	# -------------------------------------------------
	# Rundbogen
	# -------------------------------------------------

	for i in range(segments):
		var angle1 = PI * float(i) / segments
		var angle2 = PI * float(i + 1) / segments

		var inner_x1 = cos(angle1) * inner_radius
		var inner_y1 = sin(angle1) * inner_radius

		var inner_x2 = cos(angle2) * inner_radius
		var inner_y2 = sin(angle2) * inner_radius

		var outer_x1 = cos(angle1) * outer_radius
		var outer_y1 = sin(angle1) * outer_radius

		var outer_x2 = cos(angle2) * outer_radius
		var outer_y2 = sin(angle2) * outer_radius

		_add_arch_segment(
			vertices,
			indices,
			Vector3(inner_x1, arch_start_height + inner_y1, 0),
			Vector3(inner_x2, arch_start_height + inner_y2, 0),
			Vector3(outer_x2, arch_start_height + outer_y2, 0),
			Vector3(outer_x1, arch_start_height + outer_y1, 0),
			depth
		)


	# -------------------------------------------------
	# Mesh erstellen
	# -------------------------------------------------

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh_data.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	mesh = mesh_data


# =================================================
# BOX
# =================================================

func _add_box(
	vertices: PackedVector3Array,
	indices: PackedInt32Array,
	position: Vector3,
	size: Vector3
):
	var start = vertices.size()

	vertices.append(position)
	vertices.append(position + Vector3(size.x, 0, 0))
	vertices.append(position + Vector3(size.x, size.y, 0))
	vertices.append(position + Vector3(0, size.y, 0))

	vertices.append(position + Vector3(0, 0, size.z))
	vertices.append(position + Vector3(size.x, 0, size.z))
	vertices.append(position + Vector3(size.x, size.y, size.z))
	vertices.append(position + Vector3(0, size.y, size.z))

	var faces = [
		[0, 1, 2], [0, 2, 3],
		[4, 6, 5], [4, 7, 6],
		[0, 4, 5], [0, 5, 1],
		[3, 2, 6], [3, 6, 7],
		[0, 3, 7], [0, 7, 4],
		[1, 5, 6], [1, 6, 2]
	]

	for face in faces:
		indices.append(start + face[0])
		indices.append(start + face[1])
		indices.append(start + face[2])


# =================================================
# BOGENSEGMENT
# =================================================

func _add_arch_segment(
	vertices: PackedVector3Array,
	indices: PackedInt32Array,
	inner1: Vector3,
	inner2: Vector3,
	outer2: Vector3,
	outer1: Vector3,
	segment_depth: float
):
	var start = vertices.size()

	# Vorderseite
	vertices.append(inner1)
	vertices.append(inner2)
	vertices.append(outer2)
	vertices.append(outer1)

	# Rückseite
	vertices.append(inner1 + Vector3(0, 0, segment_depth))
	vertices.append(inner2 + Vector3(0, 0, segment_depth))
	vertices.append(outer2 + Vector3(0, 0, segment_depth))
	vertices.append(outer1 + Vector3(0, 0, segment_depth))

	var faces = [
		[0, 1, 2], [0, 2, 3],
		[4, 6, 5], [4, 7, 6],

		[0, 4, 5], [0, 5, 1],
		[1, 5, 6], [1, 6, 2],
		[2, 6, 7], [2, 7, 3],
		[3, 7, 4], [3, 4, 0]
	]

	for face in faces:
		indices.append(start + face[0])
		indices.append(start + face[1])
		indices.append(start + face[2])
