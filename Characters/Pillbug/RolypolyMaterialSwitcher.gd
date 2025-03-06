class_name RolypolyMaterialSwitcher extends Node3D

@export var paint_material : StandardMaterial3D
@export var meshes : Array[MeshInstance3D]
@export var normal_material : StandardMaterial3D

func set_painted() -> void:
	
	for i in meshes.size():
		meshes[i].material_override = paint_material
		
func set_unpainted() -> void:
	for i in meshes.size():
		meshes[i].material_override = normal_material
