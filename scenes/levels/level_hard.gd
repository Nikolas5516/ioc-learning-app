# level_hard.gd
extends Node2D

var current_score: int = 0
const MAP_UNLOCK_THRESHOLD: int = 50  # Example score to unlock the map

# Add points to the score
func add_points(amount: int):
	current_score += amount
	print("Score updated: ", current_score)
	# Check if the map should be unlocked
	if current_score >= MAP_UNLOCK_THRESHOLD:
		# You could emit a signal here or just print a message
		print("Map Quiz Unlocked!")

# Function to switch scenes
func goto_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Failed to load scene: " + path)
		
