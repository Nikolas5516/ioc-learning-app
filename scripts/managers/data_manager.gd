extends Node

var levels: Array = []
var questions: Array = []

func _ready():
	load_levels()
	load_questions()
	print("Levels loaded: ", levels.size())
	print("Questions loaded: ", questions.size())

func load_levels():
	var file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		levels = JSON.parse_string(file.get_as_text())

func load_questions():
	var file := FileAccess.open("res://data/questions.json", FileAccess.READ)
	if file:
		questions = JSON.parse_string(file.get_as_text())

func get_questions_for_level(level_id: int) -> Array:
	return questions.filter(func(q): return q["level_id"] == level_id)
