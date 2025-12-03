extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	if GlobalState.previous_scene_path != "":
		get_tree().change_scene_to_file(GlobalState.previous_scene_path)
	else:
		# fallback de siguranță, dacă intri direct în Settings cu F6
		get_tree().change_scene_to_file("res://scenes/UI/backgrounds/Bg_hub.tscn")
