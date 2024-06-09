extends CharacterBody3D

# Define class-level variables and constants
@onready var camera_mount = $CameraRoot
@onready var animation_player = $Visuals/YBot_LocomotionPack/AnimationPlayer
@onready var visuals = $Visuals

const JUMP_VELOCITY = 4.5
var runSpeed = 5
var currentLane = 0

enum RunnerState {running, transition, hurt, gameOver}
var state = RunnerState.running

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Function called when the node is added to the scene
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Function called every physics frame (fixed timestep)
func _physics_process(delta):
	if state == RunnerState.running:
		velocity.z = runSpeed
		animation_player.play("Run Forward")

		# Handle jump.
		if is_on_floor():
			if Input.is_action_pressed("left") and currentLane != -1:
				velocity.x = JUMP_VELOCITY
				velocity.y = JUMP_VELOCITY
				visuals.look_at(position - Vector3.FORWARD + Vector3.RIGHT)
				currentLane -= 1
				state = RunnerState.transition
			if Input.is_action_pressed("right") and currentLane != 1:
				visuals.look_at(position - Vector3.FORWARD + Vector3.LEFT)
				velocity.x = -JUMP_VELOCITY
				velocity.y = JUMP_VELOCITY
				currentLane += 1
				state = RunnerState.transition
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				state = RunnerState.transition

	if state == RunnerState.transition:
		if animation_player.current_animation != "Jump":
			animation_player.play("Jump")
			animation_player.seek(.8,true,false)
		if animation_player.current_animation_position > 1 and is_on_floor():
			velocity.x = 0
			visuals.look_at(position - Vector3.FORWARD)
			state = RunnerState.running

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Quit the game when escape is pressed
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		
	move_and_slide()
