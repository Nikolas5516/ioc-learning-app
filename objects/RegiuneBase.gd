extends Area2D

# --------------------
# EXPORTURI ȘI CONSTANTE
# --------------------

# ID-ul unic al regiunii, setat în LevelEasy.tscn
@export var id_regiune: String = "regiune_necunoscuta" 

# Referință la Sprite-ul pe care îl colorăm.
@onready var sprite_regiune: Sprite2D = $SpriteRegiune 

var este_rezolvata: bool = false
var este_mouse_over: bool = false

# Culoarea de bază (Alb-Negru, setată prin shader)
const COLOR_ALB_NEGRU = Color(0.3, 0.3, 0.3, 1.0) 
# Efect de hover (o mică nuanță de galben-alb sau chenar)
const COLOR_HOVER = Color(0.9, 0.9, 0.9, 1.0) 
# Culoarea finală (Alb-pur), care revine la textura originală
const COLOR_FINAL = Color.WHITE 

# Semnalul trimis Logicii Globale când se dă click pe regiune.
signal regiune_activata(regiune_id: String) 


# --------------------
# 1. SETUP INIȚIAL
# --------------------

func _ready():
	# Asigură-te că nodul este capabil să detecteze evenimentele de input.
	input_pickable = true
	# Activează detecția intrării/ieșirii mouse-ului
	monitorable = true 
	
	# Aplică starea inițială alb-negru
	if sprite_regiune:
		sprite_regiune.modulate = COLOR_ALB_NEGRU
		# (Opțional: S-ar putea să ai nevoie de un Shader pentru a converti imaginea în grayscale 
		# dacă doar 'modulate' nu oferă un efect suficient de bun)


# --------------------
# 2. INTERACȚIUNE MOUSE (HOVER)
# --------------------

func _on_mouse_entered():
	if not este_rezolvata:
		este_mouse_over = true
		# Aplică efectul de hover
		# Pentru chenar: poți folosi un 'AnimationPlayer' sau un 'CanvasModulate'
		# Cea mai simplă metodă: modifici culoarea Sprite-ului (ca efect de strălucire)
		sprite_regiune.modulate = COLOR_HOVER

func _on_mouse_exited():
	if not este_rezolvata:
		este_mouse_over = false
		# Revine la starea alb-negru
		sprite_regiune.modulate = COLOR_ALB_NEGRU
		

# --------------------
# 3. INTERACȚIUNE CLICK
# --------------------

# Această funcție se declanșează când un eveniment de input (click) are loc în interior.
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	# Verifică dacă evenimentul este un click stânga de mouse (apăsat).
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not este_rezolvata:
			print("Click pe regiunea: " + id_regiune + ". Cer intrebarea...")
			# Emite ID-ul regiunii către Logica Globală
			regiune_activata.emit(id_regiune)
			
			# TODO: Aici se va adăuga codul pentru afișarea chenarului de selecție
			# (dacă ai un nod Frame/Box pe care vrei să-l activezi)


# --------------------
# 4. LOGICA RĂSPUNSULUI (Chemată din Logica Globală)
# --------------------

# Această funcție va fi apelată de Logica Globală după ce răspunsul este CORECT.
func marcheaza_rezolvata():
	if not este_rezolvata:
		este_rezolvata = true
		if sprite_regiune:
			# Setarea pe Color.WHITE (sau COLOR_FINAL) face ca textura să apară 
			# în culorile ei originale, scoțând-o din starea alb-negru.
			sprite_regiune.modulate = COLOR_FINAL 
			print("Regiunea " + id_regiune + " a fost colorată și rezolvată!")
		# Oprește detecția click-ului pe regiunea rezolvată.
		input_pickable = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
