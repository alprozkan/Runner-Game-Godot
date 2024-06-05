extends Control

@export var controller_level_scene: PackedScene
@export var procedural_city_scene: PackedScene

func _ready():
	$VBoxContainer/ControllerLevelButton.connect("pressed", self._on_controller_level_button_pressed)
	$VBoxContainer/ProceduralCityButton.connect("pressed", self._on_procedural_city_button_pressed)

func _on_controller_level_button_pressed():
	load_scene(controller_level_scene)

func _on_procedural_city_button_pressed():
	load_scene(procedural_city_scene)

func load_scene(scene: PackedScene):
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # Remove the current scene instance
	var scene_instance = scene.instantiate()
	get_tree().root.add_child(scene_instance)
	get_tree().current_scene = scene_instance
