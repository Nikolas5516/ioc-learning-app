extends Control

# --- CONSTANTE DE JOC ȘI DEBLOCARE ---

# Numarul de nivele de joc care deblocheaza urmatorul nivel (fara cufar)
const TOTAL_GAME_LEVELS: int = 5 
# Numarul total de noduri pe traseu (5 Nivele + 1 Cufar)
const TOTAL_PATH_NODES: int = 6 
# Nivelul corespunzator nodului 'Cufar' (ultimul nod)
const FINAL_CHEST_INDEX: int = 6 

# Variabila care stocheaza nivelul maxim deblocat de jucator (pentru test, incepem cu 1)
# ATENTIE: In jocul final, aceasta variabila trebuie incarcata dintr-un sistem de salvare!
var unlocked_level: int = 1 


# --- REFERINȚE NODURI ȘI SCROLLING ---

# ATENTIE: Ajusteaza path-urile nodurilor de mai jos daca sunt diferite!
# Poti obtine calea (path) dand click dreapta pe nod in panoul Scena -> Copy Node Path.


@onready var settings_button = get_node("TopBar_HUD/SettingsButton")  # Presupunând că ai un buton SettingsButton
var settings_popup_scene = preload("res://scenes/SettingsPopup.tscn")

# Nodul care contine Path2D si butoanele (LevelMap)
@onready var level_map_node = get_node("LevelMap") 

# Nodul care contine fundalul rulabil (ParallaxBackground)
@onready var parallax_bg = get_node("ParallaxBackground") 

# Nodul Path2D (care contine toate nodurile PathFollow2D)
@onready var path_node = get_node("LevelMap/Path2D") 

@onready var customize_button = get_node("TopBar_HUD/CustomizeButton")

var customization_scene = preload("res://scenes/Customization.tscn")  # A
# --- FUNCȚII DE BAZĂ ---

func _ready():
	# Asigura-te ca butoanele sunt blocate/deblocate corect la inceput
	update_level_locks()
	if customize_button:
		print("✅ Customize button found, connecting...")
		customize_button.pressed.connect(_on_customize_button_pressed)
	else:
		print("⚠️ Customize button not found at specified path")
	
	if settings_button:
		print("✅ Settings button found, connecting...")
		settings_button.pressed.connect(_on_settings_button_pressed)
	else:
		print("⚠️ Settings button not found - check the path!")


#FUNCTII PENTRU BUTONUL DE SETTINGS

func _on_settings_button_pressed():
	print("⚙️ Settings button pressed!")
	_open_settings_popup()

func _open_settings_popup():
	print("📖 Opening settings popup...")
	
	# Creează instanța popup-ului
	var settings_popup = settings_popup_scene.instantiate()
	
	# Configurează popup-ul
	#settings_popup.popup_exclusive = true
	settings_popup.size = Vector2(400, 400)
	
	# Adaugă popup-ul la scenă
	add_child(settings_popup)
	
	# Afișează centrat pe ecran
	settings_popup.popup_centered()
	
	print("✅ Settings popup opened successfully!")
# --- FUNCTII DE INPUT ȘI PANNING (SCROLLING) ---

# Variabile pentru Panning
var dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _on_customize_button_pressed():
	print("🎨 Customize button pressed!")
	
	# Varianta 1: Încarcă scena ca modal (popup peste)
	_open_customization_scene()
	
	
func _open_customization_scene():
	print("🎨 Opening customization scene...")
	
	# Varianta A: Încarcă ca scenă separată
	#get_tree().change_scene_to_file("res://scenes/CustomizationScene.tscn")
	
	# Varianta B: Încarcă ca child (dacă vrei suprapus)
	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()
	
	# # Asigură-te că instance-ul este adăugat corect
	get_tree().current_scene.add_child(instance)
	
	# # FORȚEAZĂ procesarea
	await get_tree().process_frame
	await get_tree().process_frame
	
	# # Apelează manual setup-ul dacă e nevoie
	# if instance.has_method("force_setup"):
	#     instance.force_setup()

func _input(event):
	# Detecteaza inceputul si sfarsitul actiunii de tragere
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
			else:
				dragging = false
				
	# Detecteaza miscarea mouse-ului in timp ce tragi
	if dragging and event is InputEventMouseMotion:
		var current_pos = event.position
		var delta = current_pos - last_mouse_pos
		
		scroll_map(delta)
		
		last_mouse_pos = current_pos


func scroll_map(delta: Vector2):
	# Butoanele se misca normal
	level_map_node.position += delta*0.955
	
	# Fundalul se misca ACELASI lucru, in directie opusa
	parallax_bg.scroll_offset += delta # Acum factorul este 1.0

# --- LOGICA DEBLOCARE NIVELURI ---

func update_level_locks():
	# Parcurge toti fiii (PathFollow2D) din Path2D
	for i in range(path_node.get_child_count()):
		var level_follower = path_node.get_child(i)
		
		# Ne asiguram ca nodul PathFollow2D contine un copil (butonul/cufarul)
		if level_follower is PathFollow2D and level_follower.get_child_count() > 0:
			# Obtine referinta la butonul/cufarul real (primul copil)
			var level_button = level_follower.get_child(0) as TextureButton 
			var current_index = i + 1  # Indexul incepand cu 1
			
			if current_index <= unlocked_level:
				# Nivel/Cufar deblocat
				level_button.disabled = false
				level_button.modulate = Color.WHITE # Culoare normala
			else:
				# Nivel blocat
				level_button.disabled = true
				level_button.modulate = Color(0.6, 0.6, 0.6, 1.0) # Gri semitransparent


# --- FUNCTII BUTOANE DE NIVEL ---

# Aceasta functie trebuie conectata la semnalul 'pressed()' al TUTUROR butoanelor de nivel
func _on_level_button_pressed():
	# Deoarece folosim o singura functie pentru toate butoanele, 
	# este necesar sa identificam ce buton a fost apasat.
	
	# Solutie temporara (pentru test):
	print("Un buton de nivel a fost apasat!")
	
	# Solutie finala (trebuie implementata de tine, dupa ce definesti scenele):
	# 1. Obtine numele nodului apasat (exemplu: Level 3)
	# var button_name = get_tree().get_clicked_node_name() # Metoda variaza in Godot 4
	
	# 2. Determina daca este cufarul final
	# if button_name == "Final": # Presupunand ca ai numit cufarul 'Final'
	#     handle_final_chest()
	# else:
	#     # 3. Incarca scena de joc corespunzatoare
	#     var level_number = int(button_name.replace("Level ", "")) # Ex: Level 3 devine 3
	#     get_tree().change_scene_to_file("res://scenes/level_" + str(level_number) + "_game.tscn")
	pass # Lasa 'pass' daca nu ai inca logica de incarcare a scenei


# Logica pentru cufarul final (Nivelul 6)
func handle_final_chest():
	# Cufarul se poate deschide doar daca toate cele 5 nivele au fost terminate
	if unlocked_level > TOTAL_GAME_LEVELS:
		# Aici adaugi logica:
		# 1. Schimba textura cufarului (Level 6) la cufar deschis (cu monede)
		# 2. Adauga puncte la variabila globala de scor
		print("🎉 Cufarul a fost deschis! Puncte bonus adaugate.")
	else:
		print("⚠️ Termina toate cele 5 nivele de joc inainte de a deschide cufarul!")
		
		# --- LIMITE SCROLLING (Ajusteaza aceste valori!) ---
# Aceste limite definesc cat de mult poate fi miscat LevelMap
# (in pixeli, fata de pozitia sa initiala/default)
# Presupunem ca pozitia initiala este (0, 0) sau centrata pe harta.

# Limite pe Orizontala (X)
# MIN_X_POS: Cea mai mica valoare (miscarea maxima spre dreapta)
const MIN_X_POS: float = -1500  
# MAX_X_POS: Cea mai mare valoare (miscarea maxima spre stanga)
const MAX_X_POS: float = 0      

# Limite pe Verticala (Y)
# MIN_Y_POS: Cea mai mica valoare (miscarea maxima in sus)
const MIN_Y_POS: float = 30
# MAX_Y_POS: Cea mai mare valoare (miscarea maxima in jos)
const MAX_Y_POS: float = 300
