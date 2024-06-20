@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("ProceduralSceneGenerator2D" as String, "Node2D" as String, load("res://addons/ProceduralSceneGenerator2D/procedural_scene_generator.gd") as Script, load("res://addons/ProceduralSceneGenerator2D/procedural_scene_generator_2d.png") as Texture2D)


func _exit_tree() -> void:
	remove_custom_type("ProceduralGenerator2D")
