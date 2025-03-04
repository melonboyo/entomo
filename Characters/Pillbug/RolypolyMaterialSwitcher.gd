class_name RolypolyMaterialSwitcher extends Node3D

@export var paint_material : StandardMaterial3D
@export var meshes : Array[MeshInstance3D]

func set_painted() -> void:
	
	for i in meshes.size():
		meshes[i].material_override = paint_material
