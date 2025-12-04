extends Node2D

@onready var feedback_label = $TextureRect/Feedback_Label 

var current_selection = "" 
const CORRECT_ANSWERS = {
	"A": "Cluj-Napoca",
	"B": "Bucuresti",
	"C" : "Iasi",
	"D": "Timisoara",
	"E": "Podisul Dobrogei",
	"F": "Podisul Moldovei",
	"H": "Muntii Maramuresului"
}

func _on_map_area_clicked(viewport, event, shape_idx, area_id):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_selection = area_id
		print("Map area clicked: " + current_selection) 


func _on_answer_button_pressed(selected_answer_text: String):
	var cleaned_answer_text = selected_answer_text.strip_edges()
	
	if current_selection == "":
		display_feedback("Please select a point on the map first.", Color.YELLOW)
		return

	var correct_answer = CORRECT_ANSWERS.get(current_selection)
	if cleaned_answer_text == correct_answer: 
		display_feedback(" Correct! " + correct_answer, Color.GREEN)
	else:
		display_feedback(" Wrong answer. The correct answer was: " + correct_answer, Color.RED)
	
	current_selection = ""

func display_feedback(message, color):
	if is_inside_tree() and has_node("Feedback_Timer"):
		$Feedback_Timer.queue_free()

	feedback_label.text = message
	feedback_label.add_theme_color_override("font_color", color) 
	feedback_label.visible = true

	var timer = Timer.new()
	timer.name = "Feedback_Timer"
	timer.one_shot = true
	timer.wait_time = 3.0 
	timer.timeout.connect(func(): 
		feedback_label.visible = false
		timer.queue_free()
		)
	
	add_child(timer)
	timer.start()
	

func _on_area_a_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_b_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_c_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_e_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_f_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_h_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_button_a_pressed() -> void:
	pass # Replace with function body.


func _on_button_b_pressed() -> void:
	pass # Replace with function body.


func _on_button_c_pressed() -> void:
	pass # Replace with function body.


func _on_button_d_pressed() -> void:
	pass # Replace with function body.


func _on_button_e_pressed() -> void:
	pass # Replace with function body.


func _on_button_f_pressed() -> void:
	pass # Replace with function body.


func _on_button_h_pressed() -> void:
	pass # Replace with function body.


func _on_button_w_1_pressed() -> void:
	pass # Replace with function body.
