extends Area2D

signal dropped(piece_ref)

@export var piece_id: String = ""

# --- SCHIMBAREA ESTE AICI ---
# 'static' înseamnă că această valoare este împărțită de TOATE piesele din joc.
# Dacă o piesă o face 'true', va fi 'true' pentru toate.
static var is_any_piece_dragging: bool = false 

var dragging: bool = false
var original_position: Vector2
var original_scale: Vector2
var locked: bool = false

func _ready():
	original_position = global_position
	original_scale = scale

func _on_input_event(_viewport, event, _shape_idx):
	if locked: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 1. Verificăm: trage cineva deja o piesă?
				if is_any_piece_dragging:
					return # Dacă da, eu nu fac nimic, ignor click-ul.
				
				# 2. Dacă nu trage nimeni, o iau eu!
				dragging = true
				is_any_piece_dragging = true # Punem lacătul, să știe și celelalte
				
				z_index = 10 # Vin în fața tuturor
				scale = original_scale * 1.1
				
			else:
				# Când dau drumul la click (release)
				if dragging:
					dragging = false
					is_any_piece_dragging = false # Scot lacătul, acum se poate trage altceva
					
					z_index = 1 # Revin la normal
					scale = original_scale
					emit_signal("dropped", self)

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position()

func return_to_start():
	scale = original_scale
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.3).set_trans(Tween.TRANS_SINE)
