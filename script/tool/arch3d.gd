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
	pass
