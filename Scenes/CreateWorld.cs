using Godot;
using System;

public partial class CreateWorld : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	private void onGenerateWorldPressed()
	{

	}

	private void onCancelPressed()
	{
		GetTree().ChangeSceneToFile("res://Scenes/main_menu.tscn");
	}

	private void onWorldNameChanged(string text)
	{
		var mapNameLabel = GetNode<Label>("%MapName") as Label;
		mapNameLabel.text = text;
		World.WorldMapName = text;
		GD.print("World map name set to " + text);
	}

	private void onWorldSeedChanged(string text)
	{
		World.WorldMapSeed = text;
		GD.print("World map seed set to " + text);
	}

	private void onWorldSizeOptionSelected(int index)
	{
		switch (index)
		{
			case 0: // Small
				World.WorldMapSize = "small";
				break;
			case 1: // Medium
				World.WorldMapSize = "medium";
				break;
			case 2: // Large
				World.WorldMapSize = "large";
				break;
			default:
				GD.print("Error: World map size option out of bounds!");
				break;
		}
		GD.print("World map size set to " + World.WorldMapSize);
	}

}

