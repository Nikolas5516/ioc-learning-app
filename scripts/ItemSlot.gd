extends Button

var item_id: String = ""
var item_data: Dictionary = {}

@onready var item_icon: TextureRect = $BackgroundPanel/MarginContainer/VBoxContainer/item_icon
@onready var item_name: Label = $BackgroundPanel/MarginContainer/VBoxContainer/NameLabel
@onready var item_price: Label = $BackgroundPanel/MarginContainer/VBoxContainer/PriceLabel
@onready var equipped_badge: TextureRect = $BackgroundPanel/EquippedIcon

signal show_confirmation(item_id: String, action: String)

func _ready():
	print("🎬 ITEMSLOT _ready() CALLED for: ", self.name)
	
	# 1. DIMENSIUNI FIXE (dimensiune mai mică pentru test)
	self.custom_minimum_size = Vector2(160, 200)
	self.size = Vector2(160, 200)
	
	# 2. SIZE FLAGS SHRINK (nu FILL!)
	self.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	self.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# 3. DEZACTIVEAZĂ TEMELE DEFAULT
	self.theme = null  # CRITIC! Dezactivează orice temă globală
	
	# 4. APLICĂ STILURILE IMEDIAT
	_setup_button_style()
	
	# 5. Așteaptă ca stilurile să se aplice
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 6. DEBUG VISUAL - Adaugă o etichetă vizibilă
	var debug_button = Button.new()
	debug_button.text = "CUMPĂRĂ!"
	debug_button.add_theme_color_override("font_color", Color(1, 0, 0))
	debug_button.add_theme_font_size_override("font_size", 14)
	debug_button.position = Vector2(5, 5)
	debug_button.pressed.connect(_on_debug_button_pressed)
	self.add_child(debug_button)
	
	
	# 7. Configurează restul
	if item_name:
		item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_name.add_theme_color_override("font_color", Color(1, 1, 1))  # Alb
		item_name.add_theme_font_size_override("font_size", 16)
	
	if item_price:
		item_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_price.add_theme_color_override("font_color", Color(1, 1, 0))  # Galben
		item_price.add_theme_font_size_override("font_size", 14)
	
	if equipped_badge:
		equipped_badge.visible = false
	
	# 8. Conectează semnalul
	self.pressed.connect(_on_pressed)
	
	# 9. FORȚEAZĂ FINAL REDRAW
	await get_tree().process_frame
	self.queue_redraw()
	
	print("✅ ItemSlot fully initialized")



func _on_debug_button_pressed():
	print("Debug button pressed!")

func _setup_button_style():
	print("🔧 SETTING UP BUTTON STYLES...")
	
	# 1. RESET
	self.remove_theme_stylebox_override("normal")
	self.remove_theme_stylebox_override("hover")
	self.remove_theme_stylebox_override("pressed")
	
	await get_tree().process_frame  # Așteaptă puțin
	
	# 2. CREEAZĂ STILURI FOARTE VIZIBILE
	# Stil normal - PORTOCALIU STRĂLUCITOR (imposibil să nu-l vezi!)
	var normal_style = StyleBoxFlat.new()
	normal_style.draw_center = true
	normal_style.bg_color = Color(1.0, 0.5, 0.0, 1.0)  # PORTOCALIU STRĂLUCITOR!
	normal_style.border_color = Color(0, 0, 0, 1.0)    # NEGRU
	normal_style.border_width_left = 3
	normal_style.border_width_top = 3
	normal_style.border_width_right = 3
	normal_style.border_width_bottom = 3
	
	# Stil hover - VERDE NEON
	var hover_style = StyleBoxFlat.new()
	hover_style.draw_center = true
	hover_style.bg_color = Color(0.0, 1.0, 0.0, 1.0)  # VERDE NEON!
	hover_style.border_color = Color(1, 1, 1, 1.0)    # ALB
	hover_style.border_width_left = 3
	hover_style.border_width_top = 3
	hover_style.border_width_right = 3
	hover_style.border_width_bottom = 3
	
	# Stil pressed - ROZ NEON
	var pressed_style = StyleBoxFlat.new()
	pressed_style.draw_center = true
	pressed_style.bg_color = Color(1.0, 0.0, 1.0, 1.0)  # ROZ NEON!
	pressed_style.border_color = Color(1, 1, 0, 1.0)    # GALBEN
	pressed_style.border_width_left = 3
	pressed_style.border_width_top = 3
	pressed_style.border_width_right = 3
	pressed_style.border_width_bottom = 3
	
	# 3. APLICĂ FORȚAT CU set()
	self.set("theme_override_styles/normal", normal_style)
	self.set("theme_override_styles/hover", hover_style)
	self.set("theme_override_styles/pressed", pressed_style)
	
	# 4. FORȚEAZĂ UPDATE-URI
	self.notify_property_list_changed()
	self.queue_redraw()
	
	# 5. VERIFICĂ
	print("✅ Styles applied:")
	print("   Normal: ORANGE ", normal_style.bg_color)
	print("   Hover: GREEN ", hover_style.bg_color)
	print("   Pressed: PINK ", pressed_style.bg_color)

func setup(id: String, data: Dictionary):
	item_id = id
	item_data = data
	
	# Așteaptă și FORȚEAZĂ dimensiuni
	#await get_tree().process_frame
	
	# FORȚEAZĂ dimensiuni (din nou, pentru siguranță)
	self.custom_minimum_size = Vector2(100, 130)
	self.size = Vector2(100, 130)
	
	# 1. Setează numele (trunchiat dacă e prea lung)
	var item_name_text = data.get("name", "N/A")
	if item_name_text.length() > 12:
		item_name_text = item_name_text.substr(0, 10) + "..."
	item_name.text = item_name_text
	
	# 2. Iconiță mai mică
	item_icon.custom_minimum_size = Vector2(70, 50)  # Redus semnificativ!
	
	# 3. Încarcă textura
	var texture_path = data.get("texture", "")
	if texture_path and texture_path != "":
		if ResourceLoader.exists(texture_path):
			item_icon.texture = load(texture_path)
			item_icon.modulate = Color.WHITE
		else:
			_show_placeholder_icon()
	else:
		_show_placeholder_icon()
	
	# 4. Actualizează starea
	_update_state()

func _show_placeholder_icon():
	if item_data.get("slot") == "hat":
		item_icon.modulate = Color(0.6, 0.6, 1.0)  # Albastru deschis
	else:
		item_icon.modulate = Color(1.0, 0.6, 0.6)  # Roz deschis

func _update_state():
	if not DataManager:
		return
	
	await get_tree().process_frame
	
	var is_unlocked = DataManager.is_unlocked(item_id)
	var is_equipped = DataManager.is_equipped(item_id)
	var cost = item_data.get("cost", 0)
	
	# Actualizează prețul
	if is_unlocked:
		if is_equipped:
			item_price.text = "✓ ECHIPAT"
			item_price.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
			if equipped_badge:
				equipped_badge.visible = true
				equipped_badge.modulate = Color(0, 1, 0)
		else:
			item_price.text = "ECHIPEAZĂ"
			item_price.add_theme_color_override("font_color", Color(1.0, 1.0, 0.2))
			if equipped_badge:
				equipped_badge.visible = false
	else:
		item_price.text = str(cost) + " PTS"
		if DataManager.get_score() >= cost:
			item_price.add_theme_color_override("font_color", Color.WHITE)
		else:
			item_price.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		if equipped_badge:
			equipped_badge.visible = false

func _on_pressed():
	if not DataManager:
		return
	
	var is_unlocked = DataManager.is_unlocked(item_id)
	var is_equipped = DataManager.is_equipped(item_id)
	
	if is_unlocked:
		if is_equipped:
			show_confirmation.emit(item_id, "unequip")
		else:
			show_confirmation.emit(item_id, "equip")
	else:
		show_confirmation.emit(item_id, "buy")
	
	await get_tree().process_frame
	_update_state()
