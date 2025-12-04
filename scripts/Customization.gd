extends Control

@onready var hat_slot: TextureRect = $MarginContainer/MainHBox/DinoPanel/Hat_Slot
@onready var scarf_slot: TextureRect = $MarginContainer/MainHBox/DinoPanel/Scarf_Slot
@onready var score_label: Label = $MarginContainer/MainHBox/ShopPanel/TopBar/ScoreLabel
@onready var grid_container: GridContainer = $MarginContainer/MainHBox/ShopPanel/Scroller/GridContainer

#@onready var confirmation_popup: Control = $ConfirmationPopup
#@onready var confirmation_message: Label = $ConfirmationPopup/PanelContainer/VBoxContainer/MessageLabel
#@onready var confirm_button: Button = $ConfirmationPopup/PanelContainer/VBoxContainer/HBoxContainer/ConfirmButton
#@onready var cancel_button: Button = $ConfirmationPopup/PanelContainer/VBoxContainer/HBoxContainer/CancelButton
#@onready var item_preview: TextureRect = $ConfirmationPopup/PanelContainer/VBoxContainer/ItemPreview

var selected_item_id: String = ""
var selected_item_data: Dictionary = {}

func _ready():
	print("=== CUSTOMIZATION START ===")
	_check_and_fix_background()
	# Verifică nodurile
	print("HatSlot:", "GĂSIT" if hat_slot else "NU")
	print("ScarfSlot:", "GĂSIT" if scarf_slot else "NU")
	print("GridContainer:", "GĂSIT" if grid_container else "NU")
	#print("ConfirmationPopup:", "GĂSIT" if confirmation_popup else "NU")
	#
	## Ascunde popup-ul inițial
	#if confirmation_popup:
		#confirmation_popup.visible = false
	#
	## Conectează semnalele
	#if confirm_button:
		#confirm_button.pressed.connect(_on_confirm_pressed)
	#
	#if cancel_button:
		#cancel_button.pressed.connect(_on_cancel_pressed)
	#
	if DataManager:
		DataManager.score_updated.connect(_update_score_display)
		DataManager.equip_changed.connect(_update_character_appearance)
		print("✅ DataManager conectat")
	else:
		print("❌ DataManager nu este încărcat!")
	
	_create_test_points_button()
	_create_test_points_button2()
	
	_create_simple_dino_title()
	
	#lock_all_items()
	_create_exit_button()
	await get_tree().process_frame
	
	_update_score_display(DataManager.get_score())
	_update_character_appearance()
	_populate_shop()
	
	print("=== CUSTOMIZATION READY ===")
	
func _check_and_fix_background():
	
	var background = get_node_or_null("Background")
	if not background:
		background = get_node_or_null("TextureRect")
		if not background:
			background = get_node_or_null("MarginContainer/Background")
	
	if background:
		print("✅ Found background node:", background.name)
		
		# Forțează vizibilitatea
		background.visible = true
		
		# Forțează dimensiunile
		background.size = get_viewport().size
		
		# Forțează redesenarea
		background.queue_redraw()
		
		## Verifică dacă are textură
		#if background is TextureRect:
			#var texture_rect = background as TextureRect
			#if texture_rect.texture == null:
				#print("⚠️ Background has no texture! Loading default...")
				## Încarcă o textură default
				#var default_bg = preload("res://assets/backgrounds/default_bg.png")
				#if default_bg:
					#texture_rect.texture = default_bg
				#else:
					## Creează un fundal colorat de urgență
					#texture_rect.texture = null
					#texture_rect.modulate = Color(0.2, 0.3, 0.4, 1.0)
	#else:
		#print("❌ No background node found! Creating emergency background...")
		#_create_emergency_background()

func _create_emergency_background():
	# Creează un fundal de urgență
	var emergency_bg = ColorRect.new()
	emergency_bg.name = "EmergencyBackground"
	emergency_bg.color = Color(0.1, 0.2, 0.3, 1.0)  # Albastru închis
	emergency_bg.anchor_left = 0.0
	emergency_bg.anchor_right = 1.0
	emergency_bg.anchor_top = 0.0
	emergency_bg.anchor_bottom = 1.0
	
	# Pune-l în spatele tuturor
	add_child(emergency_bg)
	move_child(emergency_bg, 0)
	
	print("✅ Created emergency background")

func _create_simple_dino_title():
	"""Creează doar textul fără casetă decorativă"""
	
	var title_label = Label.new()
	title_label.name = "DinoTitleSimple"
	title_label.text = "Dulapul lui Dino"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Stil verde închis frumos
	var label_settings = LabelSettings.new()
	label_settings.font_size = 36
	label_settings.font_color = Color("#006400")  # Verde închis
	
	# Adaugă umbră pentru vizibilitate
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	
	title_label.label_settings = label_settings
	
	# Adaugă la panoul Dino
	var dino_panel = get_node_or_null("MarginContainer/MainHBox/DinoPanel")
	if dino_panel:
		title_label.position = Vector2(300, 50)
		dino_panel.add_child(title_label)
		print("✅ Text simplu 'Dulapul lui Dino' adăugat")

func lock_all_items():
	"""Blochează toate itemele (cu excepția celor default)"""
	var count = 0
	
	for item_id in DataManager.ITEMS_DATA:
		# Păstrează itemele default deblocate
		if item_id != "default_hat" and DataManager.unlocked_items.has(item_id):
			DataManager.unlocked_items.erase(item_id)
			
			# Dacă e echipat, scoate-l
			if DataManager.is_equipped(item_id):
				DataManager.unequip_item(item_id)
			
			count += 1
	
	print("🔒 Blocate ", count, " iteme")
	_show_bottom_message("🔒 Blocate " + str(count) + " iteme", Color(0.5, 0.2, 0.7, 1.0))
	_refresh_shop()


func _create_exit_button():
	"""Creează butonul de exit în dreapta jos"""
	var exit_button = Button.new()
	exit_button.name = "ExitButton"
	exit_button.text = "🚪 ÎNAPOI"
	exit_button.custom_minimum_size = Vector2(150, 50)
	
	# Stil roșu pentru exit
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)
	normal_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.9, 0.3, 0.3, 1.0)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.7, 0.1, 0.1, 1.0)
	
	exit_button.add_theme_stylebox_override("normal", normal_style)
	exit_button.add_theme_stylebox_override("hover", hover_style)
	exit_button.add_theme_stylebox_override("pressed", pressed_style)
	
	exit_button.add_theme_font_size_override("font_size", 16)
	exit_button.add_theme_color_override("font_color", Color(1, 1, 1))
	exit_button.focus_mode = Control.FOCUS_NONE
	
	# Poziționează în dreapta jos
	var screen_size = get_viewport().size
	exit_button.position = Vector2(screen_size.x - 170, screen_size.y - 70)
	
	# Conectează semnalul
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Adaugă butonul la scenă
	add_child(exit_button)
	
	print("✅ Buton exit creat")

func _create_test_points_button():
	"""Creează un buton pentru a adăuga puncte de test"""
	var test_button = Button.new()
	test_button.name = "TestPointsButton"
	test_button.text = "➕ 100 PUNCTE TEST"
	test_button.custom_minimum_size = Vector2(200, 50)
	
	# Poziționează în colțul stânga-sus
	test_button.position = Vector2(20, 90)
	
	# Stil pentru buton
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.7, 0.2, 1.0)  # Verde
	normal_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # Verde mai deschis
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.1, 0.6, 0.1, 1.0)  # Verde mai închis
	
	test_button.add_theme_stylebox_override("normal", normal_style)
	test_button.add_theme_stylebox_override("hover", hover_style)
	test_button.add_theme_stylebox_override("pressed", pressed_style)
	
	test_button.add_theme_font_size_override("font_size", 16)
	test_button.add_theme_color_override("font_color", Color(1, 1, 1))
	test_button.focus_mode = Control.FOCUS_NONE
	
	# Conectează semnalul
	test_button.pressed.connect(_on_test_points_button_pressed)
	
	# Adaugă butonul la scenă
	add_child(test_button)
	
	print("✅ Buton test puncte creat")

func _on_test_points_button_pressed():
	"""Adaugă 100 de puncte pentru testare"""
	print("🎮 Adăugare 100 puncte test...")
	DataManager.add_score(100)
	_show_points_added_message()
	_refresh_shop()

func _show_points_added_message():
	"""Afișează mesajul că au fost adăugate puncte"""
	_show_bottom_message("✅ 100 puncte adăugate!", Color(0.2, 0.8, 0.2, 1.0))




func _create_test_points_button2():
	"""Creează un buton pentru a scadea puncte de test"""
	var test_button2 = Button.new()
	test_button2.name = "TestPointsButton2"
	test_button2.text = "- 100 PUNCTE TEST"
	test_button2.custom_minimum_size = Vector2(200, 50)
	
	# Poziționează în colțul stânga-sus
	test_button2.position = Vector2(20, 40)
	
	# Stil pentru buton
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.7, 0.2, 0.2, 1.0)  # Verde
	normal_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.8, 0.3, 0.3, 1.0)  # Verde mai deschis
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.6, 0.1, 0.1, 1.0)  # Verde mai închis
	
	test_button2.add_theme_stylebox_override("normal", normal_style)
	test_button2.add_theme_stylebox_override("hover", hover_style)
	test_button2.add_theme_stylebox_override("pressed", pressed_style)
	
	test_button2.add_theme_font_size_override("font_size", 16)
	test_button2.add_theme_color_override("font_color", Color(1, 1, 1))
	test_button2.focus_mode = Control.FOCUS_NONE
	
	# Conectează semnalul
	test_button2.pressed.connect(_on_test_points_button_pressed2)
	
	# Adaugă butonul la scenă
	add_child(test_button2)
	
	print("✅ Buton test puncte creat")

func _on_test_points_button_pressed2():
	DataManager.add_score(-100)
	_show_points_scazute_message2()
	_refresh_shop()

func _show_points_scazute_message2():
	"""Afișează mesajul că au fost adăugate puncte"""
	_show_bottom_message("- 100 puncte scazute!", Color(0.8, 0.2, 0.2, 1.0))




func _populate_shop():
	if not grid_container:
		print("❌ GridContainer is null!")
		return
	
	print("=== START POPULATE SHOP ===")
	
	# Curăță GridContainer
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	await get_tree().process_frame  # Așteaptă suficient
	
	# Configurează GridContainer
	grid_container.columns = 2
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# Spații generoase
	grid_container.add_theme_constant_override("h_separation", 25)
	grid_container.add_theme_constant_override("v_separation", 25)
	
	# Margini
	grid_container.add_theme_constant_override("margin_left", 20)
	grid_container.add_theme_constant_override("margin_right", 20)
	grid_container.add_theme_constant_override("margin_top", 50)
	grid_container.add_theme_constant_override("margin_bottom", 20)
	
	# Obține toate itemele (excluzând default_hat dacă există)
	var item_ids = []
	for item_id in DataManager.ITEMS_DATA:
		if item_id != "default_hat":
			item_ids.append(item_id)
	
	print("Adaug ", item_ids.size(), " iteme în shop")
	
	# Creează butoane pentru fiecare item
	for i in range(item_ids.size()):
		var item_id = item_ids[i]
		var item_data = DataManager.ITEMS_DATA[item_id]
		
		# Creează container pentru item
		var item_container = _create_item_button(item_id, item_data)
		
		# Adaugă la GridContainer
		grid_container.add_child(item_container)
		
		print("  ✅ Adăugat item ", i+1, ": ", item_id)
		
		# Așteaptă puțin pentru stabilizare
		await get_tree().process_frame
	
	print("=== END POPULATE SHOP ===")

func _create_item_button(item_id: String, item_data: Dictionary) -> Control:
	"""Creează un buton pentru un item cu imagine, nume și preț"""
	
	# 1. Container principal
	var container = VBoxContainer.new()
	container.name = "Item_" + item_id
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.custom_minimum_size = Vector2(200, 250)
	container.add_theme_constant_override("separation", 8)
	
	# 2. Buton principal (cu imaginea item-ului)
	var item_button = Button.new()
	item_button.name = "ItemButton_" + item_id
	item_button.custom_minimum_size = Vector2(180, 180)
	item_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	item_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	item_button.expand_icon = true
	
	# Încarcă imaginea item-ului
	var texture_path = item_data.get("texture", "")
	if texture_path and ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		item_button.icon = texture
	else:
		# Dacă nu există imagine, folosește un placeholder
		item_button.text = "No Image"
	
	var is_equipped = DataManager.is_equipped(item_id)
	
	# Stil pentru buton
	var normal_style = StyleBoxFlat.new()
	
	if is_equipped:
		normal_style.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # Verde când e echipat
	else:
		normal_style.bg_color = Color(0.5, 0.3, 0.2, 1.0)  # Maro când nu e echipat
	
	normal_style.border_color = Color(0.8, 0.8, 0.8, 1.0)
	normal_style.border_width_left = 3
	normal_style.border_width_top = 3
	normal_style.border_width_right = 3
	normal_style.border_width_bottom = 3
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.corner_radius_bottom_left = 12
	
	var hover_style = normal_style.duplicate()
	if is_equipped:
		hover_style.bg_color = Color(0.1, 0.6, 0.1, 1.0)  # Verde mai deschis
		hover_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
	else:
		hover_style.bg_color = Color(0.6, 0.4, 0.3, 1.0)  # Maro mai deschis
		hover_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
	
	var pressed_style = normal_style.duplicate()
	if is_equipped:
		pressed_style.bg_color = Color(0.2, 0.5, 0.2, 1.0)  # Verde mai închis
		pressed_style.border_color = Color(0.7, 0.7, 0.7, 1.0)
	else:
		pressed_style.bg_color = Color(0.4, 0.2, 0.1, 1.0)  # Maro mai închis
		pressed_style.border_color = Color(0.7, 0.7, 0.7, 1.0)
	
	item_button.add_theme_stylebox_override("normal", normal_style)
	item_button.add_theme_stylebox_override("hover", hover_style)
	item_button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Conectează semnalul
	item_button.pressed.connect(_on_item_button_pressed.bind(item_id))
	
	# 3. Label pentru nume
	var name_label = Label.new()
	name_label.name = "NameLabel_" + item_id
	name_label.text = item_data.get("name", "Fără nume")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var name_style = LabelSettings.new()
	name_style.font_size = 16
	name_style.font_color = Color(0, 0, 0, 1)
	name_label.label_settings = name_style
	
	# 4. Label pentru preț/stare
	var status_label = Label.new()
	status_label.name = "StatusLabel_" + item_id
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var status_style = LabelSettings.new()
	status_style.font_size = 14
	
	# Determină textul în funcție de stare
	if DataManager.is_item_unlocked(item_id):
		if DataManager.is_equipped(item_id):
			status_label.text = "✓ ECHIPAT"
			status_style.font_color = Color(0.4, 0.4, 0, 1)  # Verde foarte deschis
		else:
			status_label.text = "✓ DEBLOCAT"
			status_style.font_color = Color(0.4, 0.4, 0, 1)  # Galben deschis
	else:
		var cost = item_data.get("cost", 0)
		status_label.text = "Cost: %d puncte" % cost
		if DataManager.get_score() >= cost:
			status_style.font_color = Color(0, 0, 0, 1)  # Galben
		else:
			status_style.font_color = Color(0, 0, 0, 1)  # Roșu deschis
	
	status_label.label_settings = status_style
	
	# 5. Asamblează totul
	container.add_child(item_button)
	container.add_child(name_label)
	container.add_child(status_label)
	
	return container

func _on_item_button_pressed(item_id: String):
	print("🎯 Item button pressed: ", item_id)
	
	selected_item_id = item_id
	selected_item_data = DataManager.ITEMS_DATA.get(item_id, {})
	
	if not selected_item_data:
		print("❌ Datele item-ului nu există!")
		return
	
	var item_name = selected_item_data.get("name", "acest articol")
	var cost = selected_item_data.get("cost", 0)
	
	# Verifică dacă jucătorul are suficiente puncte pentru cumpărare
	if not DataManager.is_item_unlocked(item_id) and DataManager.get_score() < cost:
		# Mesaj simplu și clar ca la butoanele de test
		var message = "❌ Nu ai suficiente puncte pentru a cumpăra acest item"
		_show_bottom_message(message, Color(0.8, 0.2, 0.2, 1.0))
		return
	
	# Apelează funcția de confirmare
	_ask_for_confirmation(item_name, cost)
	

func _show_bottom_message2(message: String, color: Color = Color(0.8, 0.2, 0.2, 1.0)):
	"""Afișează un mesaj în partea de jos a ecranului"""
	
	# Creează sau găsește containerul pentru mesaj
	var message_container = get_node_or_null("BottomMessageContainer")
	if not message_container:
		message_container = _create_bottom_message_container()
	
	# Actualizează mesajul
	var message_label = message_container.get_node("Panel/VBoxContainer/MessageLabel") as Label
	var close_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/CloseButton") as Button
	var confirm_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/ConfirmButton") as Button
	
	if message_label:
		message_label.text = message
		# Actualizează culoarea textului
		var label_settings = message_label.label_settings
		if not label_settings:
			label_settings = LabelSettings.new()
			message_label.label_settings = label_settings
		label_settings.font_color = color
	
	# Configurează butonul de închidere
	if close_button and not close_button.is_connected("pressed", _on_close_bottom_message):
		close_button.pressed.connect(_on_close_bottom_message)
	
	if confirm_button and not confirm_button.is_connected("pressed", _on_confirm_pressed):
		confirm_button.pressed.connect(_on_close_bottom_message)
	
	# Afișează mesajul cu animație
	message_container.visible = true
	message_container.modulate = Color(1, 1, 1, 0)
	
	# Animație fade in
	var tween = create_tween()
	tween.tween_property(message_container, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Ascunde automat după 5 secunde
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_close_bottom_message)

func _on_confirm_button_message():
	"""Închide mesajul din partea de jos"""
	var container = get_node_or_null("BottomMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)
	_on_confirm_pressed()

func _show_insufficient_points_message(item_name: String, cost: int):
	"""Afișează mesaj în josul paginii pentru puncte insuficiente"""
	var current_score = DataManager.get_score()
	var message = "❌ Nu ai suficiente puncte!\n%s costă %d puncte\nTu ai doar %d puncte." % [
		item_name, 
		cost, 
		current_score
	]
	_show_bottom_message(message, Color(0.8, 0.2, 0.2, 1.0))

func _show_bottom_message(message: String, color: Color = Color(0.8, 0.2, 0.2, 1.0)):
	"""Afișează un mesaj în partea de jos a ecranului"""
	
	# Creează sau găsește containerul pentru mesaj
	var message_container = get_node_or_null("BottomMessageContainer")
	if not message_container:
		message_container = _create_bottom_message_container()
	
	# Actualizează mesajul
	var message_label = message_container.get_node("Panel/VBoxContainer/MessageLabel") as Label
	var close_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/CloseButton") as Button
	
	if message_label:
		message_label.text = message
		# Actualizează culoarea textului
		var label_settings = message_label.label_settings
		if not label_settings:
			label_settings = LabelSettings.new()
			message_label.label_settings = label_settings
		label_settings.font_color = color
	
	# Configurează butonul de închidere
	if close_button and not close_button.is_connected("pressed", _on_close_bottom_message):
		close_button.pressed.connect(_on_close_bottom_message)
	
	# Afișează mesajul cu animație
	message_container.visible = true
	message_container.modulate = Color(1, 1, 1, 0)
	
	# Animație fade in
	var tween = create_tween()
	tween.tween_property(message_container, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Ascunde automat după 5 secunde
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_close_bottom_message)

func _create_bottom_message_container() -> Control:
	"""Creează containerul pentru mesajul din partea de jos"""
	
	# 1. Container principal
	var container = Control.new()
	container.name = "BottomMessageContainer"
	container.anchor_left = 0.0
	container.anchor_right = 1.0
	container.anchor_top = 0.0
	container.anchor_bottom = 1.0
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.visible = false
	
	# 2. Panel pentru mesaj (centrat în partea de jos)
	var panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(500, 150)
	panel.size = Vector2(500, 150)
	
	# Stil pentru panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Fundal semi-transparent
	panel_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# 3. VBoxContainer pentru conținut
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(480, 130)
	vbox.position = Vector2(10, 10)
	vbox.add_theme_constant_override("separation", 10)
	
	# 4. Label pentru mesaj
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "Mesaj"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var label_style = LabelSettings.new()
	label_style.font_size = 18
	label_style.font_color = Color(1, 1, 1, 1)
	label_style.line_spacing = 8
	message_label.label_settings = label_style
	
	# 5. HBoxContainer pentru buton
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 6. Buton de închidere (X)
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "✕ Închide"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de închidere
	var close_normal = StyleBoxFlat.new()
	close_normal.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Roșu
	close_normal.border_color = Color(1, 1, 1, 1.0)
	close_normal.border_width_left = 2
	close_normal.border_width_top = 2
	close_normal.border_width_right = 2
	close_normal.border_width_bottom = 2
	close_normal.corner_radius_top_left = 8
	close_normal.corner_radius_top_right = 8
	close_normal.corner_radius_bottom_right = 8
	close_normal.corner_radius_bottom_left = 8
	
	var close_hover = close_normal.duplicate()
	close_hover.bg_color = Color(0.9, 0.3, 0.3, 1.0)  # Roșu deschis
	
	var close_pressed = close_normal.duplicate()
	close_pressed.bg_color = Color(0.7, 0.1, 0.1, 1.0)  # Roșu închis
	
	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_stylebox_override("pressed", close_pressed)
	
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	close_button.focus_mode = Control.FOCUS_NONE
	
	# 7. Asamblează totul
	hbox.add_child(close_button)
	vbox.add_child(message_label)
	vbox.add_child(hbox)
	panel.add_child(vbox)
	container.add_child(panel)
	
	# 8. Adaugă la scenă
	add_child(container)
	
	# 9. Poziționează panel-ul în partea de jos, centrat
	_update_bottom_message_position(container)
	
	# 10. Conectează resize-ul viewport-ului
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	return container

func _update_bottom_message_position(container: Control):
	"""Actualizează poziția mesajului din partea de jos"""
	var panel = container.get_node("Panel") as Panel
	if panel:
		var screen_size = get_viewport().size
		panel.position = Vector2(
			(screen_size.x - panel.size.x) / 2,  # Centrat orizontal
			screen_size.y - panel.size.y - 20     # 20px de la marginea de jos
		)

func _on_viewport_size_changed():
	"""Reactualizează poziția când se schimbă dimensiunea viewport-ului"""
	var container = get_node_or_null("BottomMessageContainer")
	if container:
		_update_bottom_message_position(container)

func _on_close_bottom_message():
	"""Închide mesajul din partea de jos"""
	var container = get_node_or_null("BottomMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)

func _on_confirm_pressed():
	print("✅ Confirm pressed for item: ", selected_item_id)
	
	if not selected_item_id or selected_item_data.is_empty():
		print("❌ Nu este selectat niciun item!")
		return
	
	var cost = selected_item_data.get("cost", 0)
	var item_name = selected_item_data.get("name", "")
	
	# Determină acțiunea în funcție de stare
	if DataManager.is_item_unlocked(selected_item_id):
		if DataManager.is_equipped(selected_item_id):
			# Scoate item-ul
			DataManager.unequip_item(selected_item_id)
			print("✓ Scoat: ", item_name)
			_show_bottom_message("✅ %s a fost scoș!" % item_name, Color(0.2, 0.8, 0.2, 1.0))
		else:
			# Echipsează item-ul
			DataManager.equip_item(selected_item_id)
			print("✓ Echipat: ", item_name)
			_show_bottom_message("✅ %s a fost echipat!" % item_name, Color(0.2, 0.8, 0.2, 1.0))
	else:
		# Cumpără item-ul
		if DataManager.get_score() >= cost:
			DataManager.unlock_item(selected_item_id)
			DataManager.add_score(-cost)
			DataManager.equip_item(selected_item_id)
			print("✓ Cumpărat și echipat: ", item_name)
			_show_bottom_message("✅ %s cumpărat și echipat cu succes!" % item_name, Color(0.2, 0.8, 0.2, 1.0))
		else:
			print("✗ Puncte insuficiente!")
			_show_insufficient_points_message(item_name, cost)
	
	# Ascunde popup-ul
	#if confirmation_popup:
		#confirmation_popup.visible = false
	#
	# Reîmprospătează întregul shop
	_refresh_shop()

func _on_cancel_pressed():
	print("❌ Anulat")
	#if confirmation_popup:
		#confirmation_popup.visible = false

func _refresh_shop():
	"""Reîmprospătează întregul shop"""
	print("🔄 Refreshing shop...")
	
	# Reîmprospătează toate butoanele
	for child in grid_container.get_children():
		if child is VBoxContainer:
			var item_id = child.name.replace("Item_", "")
			if item_id and DataManager.ITEMS_DATA.has(item_id):
				_update_item_button(child, item_id)
	
	# Actualizează personajul și scorul
	_update_character_appearance()
	_update_score_display(DataManager.get_score())

func _update_item_button(container: VBoxContainer, item_id: String):
	"""Actualizează starea unui buton de item (inclusiv culoarea)"""
	if not container or not DataManager.ITEMS_DATA.has(item_id):
		return
	
	var item_data = DataManager.ITEMS_DATA[item_id]
	
	# Găsește butonul principal (primul copil din VBoxContainer)
	var item_button = container.get_child(0) as Button
	if item_button:
		# Actualizează culoarea butonului în funcție de stare
		var is_equipped = DataManager.is_equipped(item_id)
		
		# Creează stiluri noi
		var normal_style = StyleBoxFlat.new()
		var hover_style = StyleBoxFlat.new()
		var pressed_style = StyleBoxFlat.new()
		
		if is_equipped:
			# VERDE pentru item echipat
			normal_style.bg_color = Color(0.4, 0.4, 0, 1.0)  # Verde
			hover_style.bg_color = Color(0.4, 0.7, 0.4, 1.0)   # Verde deschis
			pressed_style.bg_color = Color(0.2, 0.5, 0.2, 1.0) # Verde închis
		else:
			# MARO pentru item neechipat
			normal_style.bg_color = Color(0.5, 0.3, 0.2, 1.0)  # Maro
			hover_style.bg_color = Color(0.6, 0.4, 0.3, 1.0)   # Maro deschis
			pressed_style.bg_color = Color(0.4, 0.2, 0.1, 1.0) # Maro închis
		
		# Proprietăți comune
		for style in [normal_style, hover_style, pressed_style]:
			style.border_color = Color(0.8, 0.8, 0.8, 1.0)
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_right = 12
			style.corner_radius_bottom_left = 12
		
		hover_style.border_color = Color(0.9, 0.9, 0.9, 1.0)
		pressed_style.border_color = Color(0.7, 0.7, 0.7, 1.0)
		
		# Aplică stilurile
		item_button.add_theme_stylebox_override("normal", normal_style)
		item_button.add_theme_stylebox_override("hover", hover_style)
		item_button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Găsește label-ul de stare (ultimul copil din VBoxContainer)
	var status_label = container.get_child(container.get_child_count() - 1) as Label
	if status_label:
		# Actualizează textul în funcție de stare
		if DataManager.is_item_unlocked(item_id):
			if DataManager.is_equipped(item_id):
				status_label.text = "✓ ECHIPAT"
				if status_label.label_settings:
					status_label.label_settings.font_color = Color(0.4, 0.4, 0, 1)  # Verde foarte deschis
			else:
				status_label.text = "✓ DEBLOCAT"
				if status_label.label_settings:
					status_label.label_settings.font_color = Color(0.4, 0.4, 0, 1)  # Galben deschis
		else:
			var cost = item_data.get("cost", 0)
			status_label.text = "Cost: %d puncte" % cost
			if status_label.label_settings:
				if DataManager.get_score() >= cost:
					status_label.label_settings.font_color = Color(0.4, 0.4, 0, 1)  # Galben
				else:
					status_label.label_settings.font_color = Color(0.6, 0, 0, 1)  # Roșu deschis

func _update_score_display(new_score: int):
	if score_label:
		score_label.text = "Puncte: %d" % new_score
	else:
		print("ScoreLabel nu este găsit!")

func _update_character_appearance():
	if hat_slot:
		var hat_id = DataManager.equipped_items.get("hat", "")
		if hat_id and DataManager.ITEMS_DATA.has(hat_id):
			var hat_texture_path = DataManager.ITEMS_DATA[hat_id].get("texture", "")
			if hat_texture_path and ResourceLoader.exists(hat_texture_path):
				hat_slot.texture = load(hat_texture_path)
			else:
				hat_slot.texture = null
		else:
			hat_slot.texture = null
	
	if scarf_slot:
		var scarf_id = DataManager.equipped_items.get("scarf", "")
		if scarf_id and DataManager.ITEMS_DATA.has(scarf_id):
			var scarf_texture_path = DataManager.ITEMS_DATA[scarf_id].get("texture", "")
			if scarf_texture_path and ResourceLoader.exists(scarf_texture_path):
				scarf_slot.texture = load(scarf_texture_path)
			else:
				scarf_slot.texture = null
		else:
			scarf_slot.texture = null

func _on_exit_button_pressed():
	print("🚪 Înapoi la meniul principal")
	queue_free()
	
	
func _create_confirmation_message_container() -> Control:
	"""Creează containerul pentru mesajul de confirmare cu două butoane"""
	
	# 1. Container principal
	var container = Control.new()
	container.name = "ConfirmationMessageContainer"
	container.anchor_left = 0.0
	container.anchor_right = 1.0
	container.anchor_top = 0.0
	container.anchor_bottom = 1.0
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.visible = false
	
	# 2. Panel pentru mesaj (centrat în partea de jos)
	var panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(500, 150)
	panel.size = Vector2(500, 150)
	
	# Stil pentru panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Fundal semi-transparent
	panel_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# 3. VBoxContainer pentru conținut
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(480, 130)
	vbox.position = Vector2(10, 10)
	vbox.add_theme_constant_override("separation", 10)
	
	# 4. Label pentru mesaj
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "Mesaj de confirmare"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var label_style = LabelSettings.new()
	label_style.font_size = 18
	label_style.font_color = Color(1, 1, 1, 1)
	label_style.line_spacing = 8
	message_label.label_settings = label_style
	
	# 5. HBoxContainer pentru butoane
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 6. Buton de confirmare (VERDE)
	var confirm_button = Button.new()
	confirm_button.name = "ConfirmButton"
	confirm_button.text = "✓ Confirmă"
	confirm_button.custom_minimum_size = Vector2(120, 40)
	confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de confirmare (VERDE)
	var confirm_normal = StyleBoxFlat.new()
	confirm_normal.bg_color = Color(0.2, 0.7, 0.2, 1.0)  # Verde
	confirm_normal.border_color = Color(1, 1, 1, 1.0)
	confirm_normal.border_width_left = 2
	confirm_normal.border_width_top = 2
	confirm_normal.border_width_right = 2
	confirm_normal.border_width_bottom = 2
	confirm_normal.corner_radius_top_left = 8
	confirm_normal.corner_radius_top_right = 8
	confirm_normal.corner_radius_bottom_right = 8
	confirm_normal.corner_radius_bottom_left = 8
	
	var confirm_hover = confirm_normal.duplicate()
	confirm_hover.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # Verde deschis
	
	var confirm_pressed = confirm_normal.duplicate()
	confirm_pressed.bg_color = Color(0.1, 0.6, 0.1, 1.0)  # Verde închis
	
	confirm_button.add_theme_stylebox_override("normal", confirm_normal)
	confirm_button.add_theme_stylebox_override("hover", confirm_hover)
	confirm_button.add_theme_stylebox_override("pressed", confirm_pressed)
	
	confirm_button.add_theme_font_size_override("font_size", 16)
	confirm_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	confirm_button.focus_mode = Control.FOCUS_NONE
	
	# 7. Buton de închidere (ROȘU)
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "✕ Anulează"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de închidere (ROȘU)
	var close_normal = StyleBoxFlat.new()
	close_normal.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Roșu
	close_normal.border_color = Color(1, 1, 1, 1.0)
	close_normal.border_width_left = 2
	close_normal.border_width_top = 2
	close_normal.border_width_right = 2
	close_normal.border_width_bottom = 2
	close_normal.corner_radius_top_left = 8
	close_normal.corner_radius_top_right = 8
	close_normal.corner_radius_bottom_right = 8
	close_normal.corner_radius_bottom_left = 8
	
	var close_hover = close_normal.duplicate()
	close_hover.bg_color = Color(0.9, 0.3, 0.3, 1.0)  # Roșu deschis
	
	var close_pressed = close_normal.duplicate()
	close_pressed.bg_color = Color(0.7, 0.1, 0.1, 1.0)  # Roșu închis
	
	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_stylebox_override("pressed", close_pressed)
	
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	close_button.focus_mode = Control.FOCUS_NONE
	
	# 8. Asamblează totul
	hbox.add_child(confirm_button)
	hbox.add_child(close_button)
	vbox.add_child(message_label)
	vbox.add_child(hbox)
	panel.add_child(vbox)
	container.add_child(panel)
	
	# 9. Adaugă la scenă
	add_child(container)
	
	# 10. Poziționează panel-ul în partea de jos, centrat
	_update_confirmation_message_position(container)
	
	# 11. Conectează resize-ul viewport-ului
	get_viewport().size_changed.connect(_on_viewport_size_changed_confirmation)
	
	return container


func _update_confirmation_message_position(container: Control):
	"""Actualizează poziția mesajului de confirmare"""
	var panel = container.get_node("Panel") as Panel
	if panel:
		var screen_size = get_viewport().size
		panel.position = Vector2(
			(screen_size.x - panel.size.x) / 2,  # Centrat orizontal
			screen_size.y - panel.size.y - 20     # 20px de la marginea de jos
		)

func _on_viewport_size_changed_confirmation():
	"""Reactualizează poziția mesajului de confirmare la resize"""
	var container = get_node_or_null("ConfirmationMessageContainer")
	if container:
		_update_confirmation_message_position(container)
		
func _show_confirmation_message(message: String, cost: int):
	"""Afișează un mesaj de confirmare cu două butoane"""
	
	# Creează sau găsește containerul pentru mesajul de confirmare
	var message_container = get_node_or_null("ConfirmationMessageContainer")
	if not message_container:
		message_container = _create_confirmation_message_container()
	
	# Actualizează mesajul
	var message_label = message_container.get_node("Panel/VBoxContainer/MessageLabel") as Label
	var confirm_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/ConfirmButton") as Button
	var close_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/CloseButton") as Button
	
	if message_label:
		message_label.text = message
	
	# Configurează butonul de confirmare
	if confirm_button:
		# Dezactivează conexiunile anterioare pentru a evita duplicate
		if confirm_button.is_connected("pressed", _on_confirm_confirmation_message):
			confirm_button.disconnect("pressed", _on_confirm_confirmation_message)
		
		# Conectează funcția de confirmare cu cost-ul specific
		confirm_button.pressed.connect(_on_confirm_confirmation_message.bind(cost))
	
	# Configurează butonul de închidere
	if close_button:
		if close_button.is_connected("pressed", _on_close_confirmation_message):
			close_button.disconnect("pressed", _on_close_confirmation_message)
		
		close_button.pressed.connect(_on_close_confirmation_message)
	
	# Afișează mesajul cu animație
	message_container.visible = true
	message_container.modulate = Color(1, 1, 1, 0)
	
	# Animație fade in
	var tween = create_tween()
	tween.tween_property(message_container, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Ascunde automat după 10 secunde (mai mult decât mesajul normal)
	var timer = get_tree().create_timer(10.0)
	timer.timeout.connect(_on_close_confirmation_message)
	
func _ask_for_confirmation(item_name: String, cost: int):
	"""Afișează mesaj de confirmare potrivit stării itemului"""
	var message = ""
	
	if DataManager.is_item_unlocked(selected_item_id):
		if DataManager.is_equipped(selected_item_id):
			# Item echipat - întreabă dacă vrei să îl scoți
			message = "Vrei să scoți %s?" % item_name
		else:
			# Item deblocat dar neechipat - întreabă dacă vrei să îl echipezi
			message = "Vrei să echipezi %s?" % item_name
	else:
		# Item necumpărat - întreabă dacă vrei să îl cumperi
		message = "Vrei să cumperi %s pentru %d puncte?" % [item_name, cost]
	
	_show_confirmation_message(message, cost)
	

func _on_confirm_confirmation_message(cost: int):
	"""Funcția apelată când se apasă butonul de confirmare"""
	print("✅ Confirm pressed from popup, cost:", cost)
	
	# Închide mesajul de confirmare
	_on_close_confirmation_message()
	
	# Apelează funcția originală de confirmare
	_on_confirm_pressed()

func _on_close_confirmation_message():
	"""Închide mesajul de confirmare"""
	var container = get_node_or_null("ConfirmationMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)
