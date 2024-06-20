@tool
extends Node2D


class_name ProceduralSceneGenerator2D

@export var start_on_spawn: bool = true

@export_group("Grid")
##Grid size for the spawning objects
@export var grid_size: Vector2i = Vector2i(10, 10)

@export_group("Noise")
##The seed used for random generation, same seed will generate same results. A good idea is to generate a andom number for the seed.
@export var seed: int = 0
##Determens how much of a group the scenes spawn in, the less, the more random they are
## The frequency of the noise of the noise height texture (multiplied by 100 to have better values to work with).
## Set this value to '0'/standard to ignore the value
@export_range(0.0, 100.0, 0.001) var noise_frequency: float = 95.0
##This determens at what noise values you are spawning.
## Basic values are 0.5, 0.4, 0.3, ...
@export_range(-1.0, 1.0, 0.001) var break_points: Array[float] = [
	0.22,
	0.4,
	]
## The noise texture used for procedural generation
@export var noise_height_texture: NoiseTexture2D = preload("res://addons/ProceduralSceneGenerator2D/defaults/procedural_noise_default.tres") as NoiseTexture2D


@export_group("Tiles")
## Tilemap layer where is is allowed to be spawned on
@export var tile_map_layer_orientation: TileMapLayer
## Tilemap tiles size
@export var tile_size: Vector2i = Vector2i(16, 16)
## This scene will be placed in the level
@export var scenes: Array[PackedScene] = [
	preload("res://addons/ProceduralSceneGenerator2D/demo_assets/scene_to_place_default.tscn") as PackedScene,
	preload("res://addons/ProceduralSceneGenerator2D/demo_assets/scene_to_place_default2.tscn") as PackedScene
]
## Z index at layer id
@export var z_index_tile_set: int = 0


var noise: Noise

func _ready() -> void:
	if start_on_spawn:
		generate_world()


func generate_world() -> Array[Vector2i]:
	if !break_points.is_empty():
		break_points.sort()
	else:
		print("Warn: breakpoints array is empty")
	if noise_height_texture == null:
		print("Error: Noise height texture is null. This parameter needs to be set in order to work.")
		return []
	noise = noise_height_texture.noise
	noise_height_texture.noise.seed = seed
	if noise_frequency != 0.0:
		noise_frequency = noise_frequency / 100
		noise.frequency = noise_frequency
	var id = 0
	# generate tilemap layers
	var tile_map_layer: TileMapLayer = TileMapLayer.new()
	var tile_set: TileSet = TileSet.new()
	
	var scene_collection: TileSetScenesCollectionSource = TileSetScenesCollectionSource.new()
	
	if scenes.is_empty():
		print("Error: No scenes to spawn")
		return []
	
	for i in range(scenes.size()):
		scene_collection.create_scene_tile(scenes[i], i)
	
	tile_set.add_source(scene_collection)
	tile_set.tile_size = tile_size
	tile_map_layer.tile_set = tile_set
	tile_map_layer.z_index = z_index_tile_set
	tile_map_layer.enabled = true
	#tile_map_layer.set_cell(Vector2i(0, 0), 0, Vector2i(0, 0), 1)
	tile_map_layer.global_position = Vector2(0, 0)
	
	if scene_collection.get_scene_tiles_count() == 0:
		print("Error: Please enter valid scenes")
		return []
	
	if tile_map_layer_orientation == null:
		for x in range(-grid_size.x/2, grid_size.x/2):
			for y in range(-grid_size.y/2, grid_size.y/2):
				var noise_value = noise.get_noise_2d(x, y)
				for i in break_points.size():
					if noise_value >= break_points[i] and scene_collection.get_scene_tiles_count() >= i:
						tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), i)
	else:
		for x in range(-grid_size.x/2, grid_size.x/2):
			for y in range(-grid_size.y/2, grid_size.y/2):
				var noise_value = noise.get_noise_2d(x, y)
				for i in break_points.size():
					if noise_value >= break_points[i] and scene_collection.get_scene_tiles_count() >= i and tile_map_layer_orientation.get_used_cells().has(Vector2i(x, y)):
						tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), i)
	
	add_child(tile_map_layer)
	return tile_map_layer.get_used_cells()
