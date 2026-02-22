using Godot;

public partial class Player : CharacterBody3D
{
    private Node3D _cameraMount = null!;
    private AnimationPlayer _animationPlayer = null!;
    private Node3D _visuals = null!;

    private float _speed = 2.8f;
    private const float JumpVelocity = 4.5f;

    private const float WalkSpeed = 2.8f;
    private const float RunSpeed = 5.0f;
    private bool _running;

    [Export] public float MouseSensYaw = 0.1f;
    [Export] public float MouseSensPitch = 0.1f;
    [Export] public bool InvertMouseY;

    private readonly float _gravity = (float)ProjectSettings.GetSetting("physics/3d/default_gravity");

    public override void _Ready()
    {
        _cameraMount = GetNode<Node3D>("CameraRoot");
        _animationPlayer = GetNode<AnimationPlayer>("Visuals/YBot_LocomotionPack/AnimationPlayer");
        _visuals = GetNode<Node3D>("Visuals");

        Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is not InputEventMouseMotion mouseMotion)
        {
            return;
        }

        RotateY(Mathf.DegToRad(mouseMotion.Relative.X * -MouseSensYaw));
        _visuals.RotateY(Mathf.DegToRad(mouseMotion.Relative.X * MouseSensYaw));

        var pitchMultiplier = InvertMouseY ? MouseSensPitch : -MouseSensPitch;
        _cameraMount.RotateX(Mathf.DegToRad(mouseMotion.Relative.Y * pitchMultiplier));

        RotateY(Mathf.DegToRad(-mouseMotion.Relative.X * MouseSensYaw));
        _cameraMount.RotateX(Mathf.DegToRad(-mouseMotion.Relative.Y * MouseSensYaw));

        var rotationDegrees = _cameraMount.RotationDegrees;
        rotationDegrees.X = Mathf.Clamp(rotationDegrees.X, -90.0f, 45.0f);
        _cameraMount.RotationDegrees = rotationDegrees;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (Input.IsActionPressed("run"))
        {
            _speed = RunSpeed;
            _running = true;
        }
        else
        {
            _speed = WalkSpeed;
            _running = false;
        }

        if (!IsOnFloor())
        {
            Velocity = new Vector3(Velocity.X, Velocity.Y - _gravity * (float)delta, Velocity.Z);
        }

        if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
        {
            Velocity = new Vector3(Velocity.X, JumpVelocity, Velocity.Z);
        }

        if (Input.IsActionJustPressed("escape"))
        {
            GetTree().Quit();
        }

        var inputDir = Input.GetVector("left", "right", "forward", "backward");
        var direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();

        if (direction != Vector3.Zero)
        {
            if (!_running)
            {
                if (_animationPlayer.CurrentAnimation != "Walk Forward")
                {
                    _animationPlayer.Play("Walk Forward");
                }
            }
            else if (_animationPlayer.CurrentAnimation != "Run Forward")
            {
                _animationPlayer.Play("Run Forward");
            }

            _visuals.LookAt(Position + direction);
            Velocity = new Vector3(direction.X * _speed, Velocity.Y, direction.Z * _speed);
        }
        else
        {
            if (_animationPlayer.CurrentAnimation != "Idle")
            {
                _animationPlayer.Play("Idle");
            }

            Velocity = new Vector3(
                Mathf.MoveToward(Velocity.X, 0, _speed),
                Velocity.Y,
                Mathf.MoveToward(Velocity.Z, 0, _speed)
            );
        }

        MoveAndSlide();
    }
}
