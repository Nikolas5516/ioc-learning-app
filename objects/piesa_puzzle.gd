extends Area2D

static var mana_este_ocupata = false

var dragging = false
var drag_offset = Vector2.ZERO
var pozitie_corecta_globala = Vector2.ZERO
var pozitie_start_globala = Vector2.ZERO
var este_blocata = false

const DISTANTA_MAGNET = 50.0

# Margine suplimentară de siguranță (să nu fie lipit de rama monitorului)
const MARGINE_SIGURANTA = 10.0

const CULORI = [
	# ROȘU & PORTOCALIU
	Color("#FF6B6B"), # Roșu pepene
	Color("#FF9F43"), # Portocaliu vibrant
	Color("#FFC312"), # Galben floarea soarelui
	Color("#F79F1F"), # Mandarina
	
	# VERDE
	Color("#C4E538"), # Lime electric
	Color("#A3CB38"), # Verde crud
	Color("#009432"), # Verde pădure (deschis)
	Color("#2ED573"), # Smarald neon
	
	# ALBASTRU & TURCOAZ
	Color("#12CBC4"), # Turcoaz marin
	Color("#1289A7"), # Albastru ocean
	Color("#4BCFFA"), # Albastru ceresc
	Color("#48DBFB"), # Cyan electric
	
	# VIOLET & ROZ
	Color("#D980FA"), # Lavandă intensă
	Color("#FDA7DF"), # Roz bombon
	Color("#9980FA"), # Violet regal deschis
	Color("#5758BB"), # Indigo soft
	
	# DIVERSE
	Color("#FFC048"), # Chihlimbar
	Color("#54a0ff"), # Albastru electric
	Color("#5f27cd"), # Mov strugure (mai deschis pt text)
	Color("#ff5252")  # Roșu coral
]

# --- CONFIGURARE SIMPLĂ (Modifică aici) ---
# Cât de late să fie benzile de pe margini unde stau piesele?
const LATIME_BANDA_STANGA = 250.0
const LATIME_BANDA_DREAPTA = 250.0
const INALTIME_BANDA_SUS = 150.0
const INALTIME_BANDA_JOS = 150.0

func _ready():
	randomize()
	pozitie_corecta_globala = global_position
	var marime_piesa = Vector2(100, 100)
	
	# --- APLICAREA CULORII ---
	# Alegem o culoare random din cele 20 disponibile
	var culoare_aleasa = CULORI.pick_random()
	
	# Colorăm doar forma județului (Sprite), lăsând scrisul neatins
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = culoare_aleasa
	else:
		modulate = culoare_aleasa
	
	
	# Luăm mărimea ecranului curent
	var marime_ecran = get_viewport_rect().size
	# Dacă folosești cameră cu Zoom, trebuie să ajustăm mărimea
	var camera = get_viewport().get_camera_2d()
	var offset_camera = Vector2.ZERO
	if camera:
		marime_ecran = marime_ecran / camera.zoom
		offset_camera = camera.get_screen_center_position() - (marime_ecran / 2)

	# Alegem random o latură: 0=Stanga, 1=Dreapta, 2=Sus, 3=Jos
	var latura = randi() % 4
	
	var x_final = 0.0
	var y_final = 0.0
	
	# Calculăm coordonatele în funcție de latura aleasă
	match latura:
		0: # BANDA STÂNGA (De la 0 la 250px)
			x_final = randf_range(20, LATIME_BANDA_STANGA)
			y_final = randf_range(20, marime_ecran.y - 20)
			
		1: # BANDA DREAPTA (De la capăt minus 250px până la capăt)
			x_final = randf_range(MARGINE_SIGURANTA, marime_ecran.x - marime_piesa.x - MARGINE_SIGURANTA)
			y_final = randf_range(20, marime_ecran.y - 20)
			
		2: # BANDA SUS (De la 0 la 150px)
			x_final = randf_range(20, marime_ecran.x - 20)
			y_final = randf_range(20, INALTIME_BANDA_SUS)
			
		3: # BANDA JOS (De la jos minus 150px până jos)
			x_final = randf_range(20, marime_ecran.x - 20)
			y_final = randf_range(marime_ecran.y - INALTIME_BANDA_JOS, marime_ecran.y - 20)

	# Setăm poziția finală + offset-ul camerei (dacă există)
	pozitie_start_globala = Vector2(x_final, y_final) + offset_camera
	global_position = pozitie_start_globala

func _input_event(viewport, event, shape_idx):
	if este_blocata: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mana_este_ocupata: return
				dragging = true
				mana_este_ocupata = true
				drag_offset = global_position - get_global_mouse_position()
				z_index = 100
				move_to_front()
			else:
				if dragging:
					dragging = false
					mana_este_ocupata = false
					z_index = 0
					verifica_pozitia()

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func verifica_pozitia():
	var distanta = global_position.distance_to(pozitie_corecta_globala)
	if distanta < DISTANTA_MAGNET:
		global_position = pozitie_corecta_globala
		este_blocata = true
		modulate = Color(1, 1, 1, 1)
		print("Ai potrivit un judet!")
	else:
		var tween = create_tween()
		tween.tween_property(self, "global_position", pozitie_start_globala, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
