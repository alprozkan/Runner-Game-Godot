extends CharacterBody3D

@onready var camera_mount = $CameraRoot
@onready var animation_player = $Visuals/YBot_LocomotionPack/AnimationPlayer
@onready var visuals = $Visuals

var SPEED = 2.8
const JUMP_VELOCITY = 4.5

var walkSpeed = 2.8
var runSpeed = 5
var running = false

@export var mouseSensYaw = .1
@export var mouseSensPitch = .1
@export var invertMouseY = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event):
	if event is InputEventMouseMotion:
		if invertMouseY == true:
			rotate_y(deg_to_rad(event.relative.x * -mouseSensYaw))
			visuals.rotate_y(deg_to_rad(event.relative.x * mouseSensYaw))
			camera_mount.rotate_x(deg_to_rad(event.relative.y * mouseSensPitch))
		else:
			rotate_y(deg_to_rad(event.relative.x * -mouseSensYaw))
			visuals.rotate_y(deg_to_rad(event.relative.x * mouseSensYaw))
			camera_mount.rotate_x(deg_to_rad(event.relative.y * -mouseSensPitch))

func _physics_process(delta):
	if Input.is_action_pressed("run") == true:
		SPEED = runSpeed
		running = true
	else:
		SPEED = walkSpeed
		running = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if running == false:
			if animation_player.current_animation != "Walk Forward":
				animation_player.play("Walk Forward")
		else:
			if animation_player.current_animation != "Run Forward":
				animation_player.play("Run Forward")
			
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
