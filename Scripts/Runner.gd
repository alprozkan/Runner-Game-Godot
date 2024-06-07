extends CharacterBody3D

# Define class-level variables and constants
@onready var camera_mount = $CameraRoot
@onready var animation_player = $Visuals/YBot_LocomotionPack/AnimationPlayer
@onready var visuals = $Visuals

var SPEED = 2.8
const JUMP_VELOCITY = 4.5

var walkSpeed = 2.8
var runSpeed = 5
var running = false

enum RunnerState {running, transition, hurt, gameOver}
var state = RunnerState.running

@export var mouseSensYaw = .1
@export var mouseSensPitch = .1
@export var invertMouseY = false

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
			if Input.is_action_pressed("left"):
				velocity.x = JUMP_VELOCITY/2
				velocity.y = JUMP_VELOCITY
				state = RunnerState.transition
			if Input.is_action_pressed("right"):
				velocity.x = -JUMP_VELOCITY/2
				velocity.y = JUMP_VELOCITY
				state = RunnerState.transition
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				state = RunnerState.transition

	if state == RunnerState.transition:
		if animation_player.current_animation != "Jump":
			animation_player.play("Jump")
		if animation_player.current_animation_position >= 2:
			velocity.x = 0
			state = RunnerState.running

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Quit the game when escape is pressed
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		
	move_and_slide()
