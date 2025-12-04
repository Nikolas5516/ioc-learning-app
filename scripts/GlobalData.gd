# scripts/GlobalData.gd
extends Node # FOARTE IMPORTANT: Extinde Node, nu Control sau Node2D!

# ======================================================================
# 1. VARIABILE DE STARE
# ======================================================================

# Starea curentă a jocului
var current_score: int = 0
# Dicționarul articolelor deblocate (true = deblocat/cumpărat)
var unlocked_items: Dictionary = {
	"default_hat": true # Accesoriul de bază este mereu deblocat
}
# Articolele echipate în prezent
var equipped_items: Dictionary = {
	"hat": "default_hat" # Slotul 'hat' include pălării și fulare
}

# ======================================================================
# 2. BAZA DE DATE (Catalogul Magazinului)
# ======================================================================

# Dicționarul cu detaliile complete pentru fiecare articol
const ITEMS_DATA = {
	# Articol implicit pentru slotul 'hat' (fularul sau pălăria standard)
	"default_hat": {"slot": "hat", "name": "Fără Accesoriu", "cost": 0, "texture": ""}, 
	
	# Articolele Cumpărabile
	"red_scarf": {"slot": "hat", "name": "Fular Roșu", "cost": 200, "texture": "res://assets/clothes/scarf_red.png"},
	"cowboy_hat": {"slot": "hat", "name": "Pălărie Cowboy", "cost": 300, "texture": "res://assets/clothes/hat_cowboy.png"},
	# Adaugă mai multe articole aici!
}

# ======================================================================
# 3. SEMNALE ȘI FUNCȚII ECONOMICE
# ======================================================================

# Semnal la care se conectează HUD-ul (și orice altceva care trebuie să știe că scorul s-a schimbat)
signal score_updated(new_score)

# Funcție apelată de Butonul de Test sau de joc pentru a adăuga/scădea puncte
func add_score(amount: int):
	current_score += amount
	score_updated.emit(current_score) # Emite semnalul pentru a actualiza HUD-ul

# Funcție pentru a verifica dacă un articol este deja deblocat
func is_unlocked(item_id: String) -> bool:
	return unlocked_items.get(item_id, false) # Returnează true dacă item_id există și e true

# Funcție pentru a debloca un articol (după ce este cumpărat)
func unlock_item(item_id: String):
	unlocked_items[item_id] = true
	save_game() # Salvează imediat după o achiziție

# ======================================================================
# 4. SALVARE ȘI ÎNCĂRCARE
# ======================================================================

const SAVE_PATH = "user://game_save.dat"

func _ready():
	# Încearcă să încarci datele la pornire
	load_game() 

func _notification(what):
	# Salvează când jocul se închide (funcționează doar pe platforme desktop/mobile)
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game() 

func save_game():
	var save_dict = {
		"score": current_score,
		"unlocked": unlocked_items,
		"equipped": equipped_items
	}
	
	# Folosim FileAccess pentru a scrie datele în format JSON
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_dict)
		file.store_line(json_string)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		var parsed_data = JSON.parse_string(json_string)
		file.close()

		if parsed_data is Dictionary:
			current_score = parsed_data.get("score", 0)
			unlocked_items = parsed_data.get("unlocked", unlocked_items)
			equipped_items = parsed_data.get("equipped", equipped_items)
			# Daca incarci date salvate, trebuie sa anunti HUD-ul cu scorul incarcat
			score_updated.emit(current_score)
