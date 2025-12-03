extends Control

# Referințe la nodurile din scenă (ASIGURĂ-TE CĂ NUMELE CORESPUND)
@onready var lbl_minciuna = $SpeechBubble/LabelMinciuna
@onready var btn_option1 = $OptionsContainer/Button  # Trebuie să folosească Button (fără număr)
@onready var btn_option2 = $OptionsContainer/Button1 # Trebuie să folosească Button2
@onready var btn_option3 = $OptionsContainer/Button2 # Trebuie să folosească Button3
@onready var feedback_lbl = $FeedbackLabel

# Variabilă pentru a ține minte provocarea curentă
var current_challenge = {}

func _ready():
	# Ascundem feedback-ul la început
	feedback_lbl.hide()
	
	# Conectăm butoanele la funcția de verificare
	btn_option1.pressed.connect(func(): _check_answer(btn_option1.text))
	btn_option2.pressed.connect(func(): _check_answer(btn_option2.text))
	btn_option3.pressed.connect(func(): _check_answer(btn_option3.text))
	
	# Încărcăm prima întrebare (Folosim ID-ul nivelului 7 sau 8, conform JSON-ului tău)
	load_new_challenge(7) # JSON-ul tău are flashcard-uri la level_id 7 și 8

func load_new_challenge(level_id: int):
	# Resetăm UI-ul
	feedback_lbl.hide()
	
	# Cerem datele din DataManager
	current_challenge = DataManager.get_dino_correction_challenge(level_id)
	
	# Dacă nu primim date (poate eroare), ieșim
	if current_challenge.is_empty():
		print("Eroare la încărcarea provocării")
		return

	# Afișăm minciuna
	lbl_minciuna.text = '"' + current_challenge["false_text"] + '"'
	
	# Punem textele pe butoane
	# Opțiunile sunt deja amestecate din DataManager
	btn_option1.text = current_challenge["options"][0]
	btn_option2.text = current_challenge["options"][1]
	btn_option3.text = current_challenge["options"][2]

func _check_answer(selected_text: String):
	if selected_text == current_challenge["correct_text"]:
		# RĂSPUNS CORECT
		feedback_lbl.text = "Corect! Ai restabilit adevărul!"
		feedback_lbl.modulate = Color.GREEN
		feedback_lbl.show()
		
		# Adăugăm puncte
		DataManager.add_score(current_challenge["points"])
		
		# Așteptăm puțin și dăm următoarea întrebare
		await get_tree().create_timer(2.0).timeout
		load_new_challenge(7) # Reîncarcă pentru nivelul 7
	else:
		# RĂSPUNS GREȘIT
		feedback_lbl.text = "Nu acesta este adevărul relevant. Mai încearcă!"
		feedback_lbl.modulate = Color.RED
		feedback_lbl.show()
