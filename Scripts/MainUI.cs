using Godot;

public partial class MainUI : Control
{
    [Export] public PackedScene ControllerLevelScene = null!;
    [Export] public PackedScene ProceduralCityScene = null!;

    public override void _Ready()
    {
        GetNode<Button>("VBoxContainer/ControllerLevelButton").Pressed += OnControllerLevelButtonPressed;
        GetNode<Button>("VBoxContainer/ProceduralCityButton").Pressed += OnProceduralCityButtonPressed;
    }

    private void OnControllerLevelButtonPressed()
    {
        LoadScene(ControllerLevelScene);
    }

    private void OnProceduralCityButtonPressed()
    {
        LoadScene(ProceduralCityScene);
    }

    private void LoadScene(PackedScene scene)
    {
        var tree = GetTree();
        var currentScene = tree.CurrentScene;
        currentScene?.QueueFree();

        var sceneInstance = scene.Instantiate();
        tree.Root.AddChild(sceneInstance);
        tree.CurrentScene = sceneInstance;
    }
}
