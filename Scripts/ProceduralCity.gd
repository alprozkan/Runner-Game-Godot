extends Node3D

const LANE_COUNT = 3
const LANE_WIDTH = 4
const TILE_LENGTH = 4
const SEGMENT_LENGTH = 2000
const LANE_SPACING = 4 # Space between lanes
const NO_OBSTACLE_SEGMENTS = 20  # Number of segments without obstacles at the start

@export var road_tile_scene = preload("res://Scene/Level/Road.tscn")
@export var building3_tile_scene = preload("res://Scene/Level/Building3.tscn")
@export var grass_tile_scene = preload("res://Scene/Level/Grass.tscn")
@export var obstacle_scene = preload("res://Scene/Level/Obstacle.tscn")

var segments = []

func _ready():
	generate_initial_segments()

func generate_initial_segments():
	for i in range(SEGMENT_LENGTH):
		add_segment(i)

func add_segment(index):
	for lane in range(LANE_COUNT):
		# Add road tiles
		var tile = road_tile_scene.instantiate()
		# Scale the road tile to fit the lane width
		var road_mesh = tile.get_node("StaticBody3D/MeshInstance3D")
		if road_mesh:
			road_mesh.scale = Vector3(1, 1, TILE_LENGTH)
		# Positioning the road tile with spacing for three lanes
		tile.transform.origin = Vector3((lane * (LANE_WIDTH + LANE_SPACING)) - (LANE_WIDTH + LANE_SPACING), 0, index * TILE_LENGTH)
		add_child(tile)
		segments.append(tile)

		# Add grass between lanes
		if lane < LANE_COUNT - 1:
			var grass_position = Vector3(((lane + 0.5) * (LANE_WIDTH + LANE_SPACING)) - (LANE_WIDTH + LANE_SPACING), 0, index * TILE_LENGTH)
			add_grass(grass_position, lane)

		# Randomly add obstacles on the lanes if the index is greater than the no-obstacle segments threshold
		if index > NO_OBSTACLE_SEGMENTS and randi() % 10 == 0:  # chance to place an obstacle
			var obstacle_position = Vector3((lane * (LANE_WIDTH + LANE_SPACING)) - (LANE_WIDTH + LANE_SPACING), 0, index * TILE_LENGTH)
			add_obstacle(obstacle_position)

	# Add buildings on the sides of the roads
	add_buildings(index)

func add_buildings(index):
	var previous_building_positions = []  # Store positions of previous buildings

	for side in [-1, 1]:
		# Instantiate Building3
		var building_tile = building3_tile_scene.instantiate()
		
		var random_scale = randf_range(5.0, 10.0)  # Adjusted scale for larger buildings
		
		# Scale and position all child meshes
		for child in building_tile.get_children():
			if child is StaticBody3D:
				for grandchild in child.get_children():
					if grandchild is MeshInstance3D:
						grandchild.scale = Vector3(random_scale, random_scale, random_scale)
		
		var position_offset = Vector3(
			side * ((LANE_COUNT * (LANE_WIDTH + LANE_SPACING)) / 2 + LANE_WIDTH + LANE_SPACING), 
			0, 
			index * TILE_LENGTH
		)
		
		# Ensure buildings do not overlap
		var overlapping = true
		while overlapping:
			overlapping = false
			for previous_position in previous_building_positions:
				if position_offset.distance_to(previous_position) < (random_scale * LANE_WIDTH):
					position_offset += Vector3(0, 0, TILE_LENGTH)
					overlapping = true
					break

		building_tile.transform.origin = position_offset
		previous_building_positions.append(position_offset)
		add_child(building_tile)
		segments.append(building_tile)

func add_grass(position, lane):
	var grass_tile = grass_tile_scene.instantiate()
	# Rotate grass to align with the road
	grass_tile.transform.basis = Basis(Vector3.UP, deg_to_rad(90))
	
	grass_tile.scale = Vector3(1, 1, TILE_LENGTH)
	# Positioning the grass
	grass_tile.transform.origin = position + Vector3(0, 0, -TILE_LENGTH / 2)
	add_child(grass_tile)
	segments.append(grass_tile)

func add_obstacle(position):
	var obstacle_tile = obstacle_scene.instantiate()
	add_child(obstacle_tile)  # Add the obstacle to the scene tree
	# Set the obstacle position after adding it to the scene tree
	obstacle_tile.global_transform.origin = position + Vector3(0, 0.5, 0)  # a bit above ground
	segments.append(obstacle_tile)

# Helper function to get a random float between min and max
func randf_range(min, max):
	return randf() * (max - min) + min
