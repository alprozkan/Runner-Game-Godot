using Godot;

public partial class Runner : CharacterBody3D
{
    private AnimationPlayer _animationPlayer = null!;
    private Node3D _visuals = null!;

    private const float JumpVelocity = 6.0f;
    private const float RunSpeed = 5.0f;
    private int _currentLane;

    private enum RunnerState
    {
        Running,
        Transition,
        Hurt,
        GameOver
    }

    private RunnerState _state = RunnerState.Running;
    private readonly float _gravity = (float)ProjectSettings.GetSetting("physics/3d/default_gravity");

    public override void _Ready()
    {
        _animationPlayer = GetNode<AnimationPlayer>("Visuals/YBot_LocomotionPack/AnimationPlayer");
        _visuals = GetNode<Node3D>("Visuals");
        Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (_state == RunnerState.Running)
        {
            Velocity = new Vector3(Velocity.X, Velocity.Y, RunSpeed);
            _animationPlayer.Play("Run Forward");

            if (IsOnFloor())
            {
                if (Input.IsActionPressed("left") && _currentLane != -1)
                {
                    Velocity = new Vector3(JumpVelocity, JumpVelocity, Velocity.Z);
                    _visuals.LookAt(Position - Vector3.Forward + Vector3.Right);
                    _currentLane -= 1;
                    _state = RunnerState.Transition;
                }

                if (Input.IsActionPressed("right") && _currentLane != 1)
                {
                    _visuals.LookAt(Position - Vector3.Forward + Vector3.Left);
                    Velocity = new Vector3(-JumpVelocity, JumpVelocity, Velocity.Z);
                    _currentLane += 1;
                    _state = RunnerState.Transition;
                }

                if (Input.IsActionJustPressed("ui_accept"))
                {
                    Velocity = new Vector3(Velocity.X, JumpVelocity, Velocity.Z);
                    _state = RunnerState.Transition;
                }
            }
        }

        if (_state == RunnerState.Transition)
        {
            if (_animationPlayer.CurrentAnimation != "Jump")
            {
                _animationPlayer.Play("Jump");
                _animationPlayer.Seek(0.8, true, false);
            }

            if (_animationPlayer.CurrentAnimationPosition > 1 && IsOnFloor())
            {
                Velocity = new Vector3(0, Velocity.Y, Velocity.Z);
                _visuals.LookAt(Position - Vector3.Forward);
                _state = RunnerState.Running;
            }
        }

        if (!IsOnFloor())
        {
            Velocity = new Vector3(Velocity.X, Velocity.Y - _gravity * (float)delta, Velocity.Z);
        }

        if (Input.IsActionJustPressed("escape"))
        {
            GetTree().Quit();
        }

        MoveAndSlide();
    }
}
