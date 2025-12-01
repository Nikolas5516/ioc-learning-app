extends Control


const SCENA_MENIU = "res://scenes/meniuprincipal.tscn"

func _play_button_pressed(): 
	get_tree().change_scene_to_file(SCENA_MENIU)

func _exit_button_pressed():
	get_tree().quit()
