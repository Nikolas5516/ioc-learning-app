extends Node2D

func _ready():
	# Căutăm toate piesele din container și le conectăm semnalul
	# Asigură-te că piesele tale sunt puse într-un Node2D numit "PiecesContainer"
	# Sau modifică calea dacă sunt puse direct în rădăcină
	for piece in $PiecesContainer.get_children():
		if piece.has_signal("dropped"):
			piece.connect("dropped", _on_piece_dropped)

func _on_piece_dropped(piece):
	var found_correct_slot = false
	var overlapping_areas = piece.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name.begins_with("Slot") and area.get("is_occupied") == false:
			
			if area.correct_id == piece.piece_id:
				
				# --- AICI ESTE MODIFICAREA MAGICĂ ---
				# Calculăm distanța dintre vârful piesei și centrul slotului
				var distanta = piece.global_position.distance_to(area.global_position)
				
				# Dacă distanța e mai mică de 50 pixeli (poți ajusta numărul), dă snap
				if distanta < 35:
					snap_piece_to_slot(piece, area)
					found_correct_slot = true
					break
	
	if not found_correct_slot:
		pass

func snap_piece_to_slot(piece, slot):
	# 1. Mutăm piesa vizual fix peste slot
	piece.global_position = slot.global_position
	
	# 2. Blocăm piesa ca să nu o mai putem muta
	piece.locked = true
	
	# 3. Marcăm slotul ca ocupat
	slot.is_occupied = true
	
