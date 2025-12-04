# scripts/HUD.gd
extends Control

@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel

func _ready():
	# 1. Ne conectăm la semnalul din noul AutoLoad (DataManager)
	DataManager.score_updated.connect(_update_score_display)
	
	# 2. Afișăm scorul inițial (luat de la DataManager)
	# Folosim get_score() in loc de current_score direct, pentru a respecta incapsularea
	_update_score_display(DataManager.get_score()) 

func _update_score_display(new_score: int):
	# 3. Actualizăm eticheta de scor
	score_label.text = "Puncte: %d" % new_score
