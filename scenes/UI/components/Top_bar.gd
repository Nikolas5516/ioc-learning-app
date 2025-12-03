extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_btn_settings_pressed() -> void:
	# salvăm scena curentă ca să știm unde să ne întoarcem
	GlobalState.previous_scene_path = get_tree().current_scene.scene_file_path

	# mergem la scena de setări
	get_tree().change_scene_to_file("res://scenes/UI/settings/Settings.tscn")
