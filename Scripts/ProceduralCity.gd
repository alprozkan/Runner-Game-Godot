extends Node3D

const LANE_COUNT = 3
const LANE_WIDTH = 4
const TILE_LENGTH = 4
const SEGMENT_LENGTH = 2000
const LANE_SPACING = 0.5  # Space between lanes
const BUILDING_SPACING = 4.0  # Increased space between buildings and lanes

@export var road_tile_scene = preload("res://Scene/Level/Road.tscn")
@export var building_tile_scene = preload("res://Scene/Level/Building1.tscn")

var segments = []

func _ready():
	generate_initial_segments()

func generate_initial_segments():
	for i in range(SEGMENT_LENGTH):
		add_segment(i)

func add_segment(index):
	for lane in range(LANE_COUNT):
		var tile = road_tile_scene.instantiate()
		# Scale the road tile to fit the lane width
		var road_mesh = tile.get_node("StaticBody3D/MeshInstance3D")
		if road_mesh:
			road_mesh.scale = Vector3(1, 1, TILE_LENGTH)
		# Positioning the road tile with spacing for three lanes
		tile.transform.origin = Vector3((lane * (LANE_WIDTH + LANE_SPACING)) - (LANE_WIDTH + LANE_SPACING), 0, index * TILE_LENGTH)
		add_child(tile)
		segments.append(tile)

	# Add buildings on the sides of the roads
	add_buildings(index)

func add_buildings(index):
	var previous_building_positions = []  # Store positions of previous buildings

	for side in [-1, 1]:
		var building_tile = building_tile_scene.instantiate()
		var building_mesh = building_tile.get_node("StaticBody3D/MeshInstance3D")
		if building_mesh:
			var random_scale = randf_range(2.0, 5.0)  # Random scale between 2.0 and 5.0
			building_mesh.scale = Vector3(random_scale, random_scale, random_scale)
			
			var position_offset = Vector3(
				side * ((LANE_COUNT * (LANE_WIDTH + LANE_SPACING)) / 2 + BUILDING_SPACING), 
				0, 
				index * TILE_LENGTH
			)
			
			# Ensure buildings do not overlap
			var overlapping = true
			while overlapping:
				overlapping = false
				for previous_position in previous_building_positions:
					if position_offset.distance_to(previous_position) < (random_scale * BUILDING_SPACING):
						position_offset += Vector3(0, 0, TILE_LENGTH)
						overlapping = true
						break

			building_tile.transform.origin = position_offset
			previous_building_positions.append(position_offset)
		add_child(building_tile)
		segments.append(building_tile)

# Helper function to get a random float between min and max
func randf_range(min, max):
	return randf() * (max - min) + min
