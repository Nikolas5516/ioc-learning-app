# scripts/TestScene.gd
extends Node2D

# Functia care se declanseaza cand apesi pe Buton.
# Numele TREBUIE să fie _on_button_pressed sau _on_[NumeNodButton]_pressed
func _on_button_pressed(): 
	# Linia care afiseaza mesajul in consola
	DataManager.add_score(50)
	print("Test: Au fost adaugate 50 de puncte. Scorul curent: ", DataManager.current_score)
