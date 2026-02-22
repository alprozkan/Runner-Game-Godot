using Godot;
using Godot.Collections;

public partial class ProceduralCity : Node3D
{
    private const int LaneCount = 3;
    private const float LaneWidth = 4.0f;
    private const float TileLength = 4.0f;
    private const int SegmentLength = 2000;
    private const float LaneSpacing = 4.0f;
    private const int NoObstacleSegments = 20;

    [Export] public PackedScene RoadTileScene = GD.Load<PackedScene>("res://Scene/Level/Road.tscn");
    [Export] public PackedScene Building3TileScene = GD.Load<PackedScene>("res://Scene/Level/Building3.tscn");
    [Export] public PackedScene GrassTileScene = GD.Load<PackedScene>("res://Scene/Level/Grass.tscn");
    [Export] public PackedScene ObstacleScene = GD.Load<PackedScene>("res://Scene/Level/Obstacle.tscn");

    private readonly Array<Node> _segments = new();

    public override void _Ready()
    {
        GenerateInitialSegments();
    }

    private void GenerateInitialSegments()
    {
        for (var i = 0; i < SegmentLength; i++)
        {
            AddSegment(i);
        }
    }

    private void AddSegment(int index)
    {
        for (var lane = 0; lane < LaneCount; lane++)
        {
            var tile = RoadTileScene.Instantiate<Node3D>();
            var roadMesh = tile.GetNodeOrNull<MeshInstance3D>("StaticBody3D/MeshInstance3D");
            if (roadMesh != null)
            {
                roadMesh.Scale = new Vector3(1, 1, TileLength);
            }

            tile.Transform = new Transform3D(
                tile.Transform.Basis,
                new Vector3((lane * (LaneWidth + LaneSpacing)) - (LaneWidth + LaneSpacing), 0, index * TileLength)
            );
            AddChild(tile);
            _segments.Add(tile);

            if (lane < LaneCount - 1)
            {
                var grassPosition = new Vector3(((lane + 0.5f) * (LaneWidth + LaneSpacing)) - (LaneWidth + LaneSpacing), 0, index * TileLength);
                AddGrass(grassPosition);
            }

            if (index > NoObstacleSegments && GD.Randi() % 10 == 0)
            {
                var obstaclePosition = new Vector3((lane * (LaneWidth + LaneSpacing)) - (LaneWidth + LaneSpacing), 0, index * TileLength);
                AddObstacle(obstaclePosition);
            }
        }

        AddBuildings(index);
    }

    private void AddBuildings(int index)
    {
        var previousBuildingPositions = new Array<Vector3>();

        foreach (var side in new[] { -1, 1 })
        {
            var buildingTile = Building3TileScene.Instantiate<Node3D>();
            var randomScale = RandfRange(5.0f, 10.0f);

            foreach (var child in buildingTile.GetChildren())
            {
                if (child is StaticBody3D staticBody)
                {
                    foreach (var grandchild in staticBody.GetChildren())
                    {
                        if (grandchild is MeshInstance3D meshInstance)
                        {
                            meshInstance.Scale = new Vector3(randomScale, randomScale, randomScale);
                        }
                    }
                }
            }

            var positionOffset = new Vector3(
                side * ((LaneCount * (LaneWidth + LaneSpacing)) / 2 + LaneWidth + LaneSpacing),
                0,
                index * TileLength
            );

            var overlapping = true;
            while (overlapping)
            {
                overlapping = false;
                foreach (var previousPosition in previousBuildingPositions)
                {
                    if (positionOffset.DistanceTo(previousPosition) < randomScale * LaneWidth)
                    {
                        positionOffset += new Vector3(0, 0, TileLength);
                        overlapping = true;
                        break;
                    }
                }
            }

            buildingTile.Transform = new Transform3D(buildingTile.Transform.Basis, positionOffset);
            previousBuildingPositions.Add(positionOffset);
            AddChild(buildingTile);
            _segments.Add(buildingTile);
        }
    }

    private void AddGrass(Vector3 position)
    {
        var grassTile = GrassTileScene.Instantiate<Node3D>();
        grassTile.Transform = new Transform3D(
            new Basis(Vector3.Up, Mathf.DegToRad(90)),
            position + new Vector3(0, 0, -TileLength / 2)
        );
        grassTile.Scale = new Vector3(1, 1, TileLength);
        AddChild(grassTile);
        _segments.Add(grassTile);
    }

    private void AddObstacle(Vector3 position)
    {
        var obstacleTile = ObstacleScene.Instantiate<Node3D>();
        AddChild(obstacleTile);
        obstacleTile.GlobalTransform = new Transform3D(obstacleTile.GlobalTransform.Basis, position + new Vector3(0, 0.5f, 0));
        _segments.Add(obstacleTile);
    }

    private static float RandfRange(float min, float max)
    {
        return (GD.Randf() * (max - min)) + min;
    }
}
