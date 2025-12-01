extends Node

var levels: Array = []
var questions: Array = []
var current_level_id: int = -1
var current_score: int = 0

func _ready():
	load_levels()
	load_questions()
	# Uncomment pentru a rula teste automat la pornire
	test_data_manager()

# ===== LOADING FUNCTIONS =====
func load_levels():
	var file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		levels = JSON.parse_string(json_text)
		if levels == null:
			levels = []
			push_error("Failed to parse levels.json")
	else:
		push_error("Failed to open levels.json")

func load_questions():
	var file := FileAccess.open("res://data/questions.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		questions = JSON.parse_string(json_text)
		if questions == null:
			questions = []
			push_error("Failed to parse questions.json")
	else:
		push_error("Failed to open questions.json")

# ===== LEVEL FUNCTIONS =====
func get_all_levels() -> Array:
	return levels

func get_level_by_id(level_id: int) -> Dictionary:
	for level in levels:
		if level["id"] == level_id:
			return level
	return {}

func get_levels_by_difficulty(difficulty: String) -> Array:
	return levels.filter(func(level): return level["name"] == difficulty)

func get_level_count() -> int:
	return levels.size()

func set_current_level(level_id: int) -> void:
	current_level_id = level_id

func get_current_level() -> Dictionary:
	return get_level_by_id(current_level_id)

# ===== QUESTION FUNCTIONS =====
func get_all_questions() -> Array:
	return questions

func get_questions_for_level(level_id: int) -> Array:
	return questions.filter(func(q): return q["level_id"] == level_id)

func get_question_by_id(question_id: int) -> Dictionary:
	for question in questions:
		if question["id"] == question_id:
			return question
	return {}

func get_questions_by_difficulty(difficulty: String) -> Array:
	var level_ids = []
	for level in get_levels_by_difficulty(difficulty):
		level_ids.append(level["id"])
	
	return questions.filter(func(q): return q["level_id"] in level_ids)

func get_questions_by_type(question_type: String) -> Array:
	return questions.filter(func(q): return q.get("question_type", "multiple_choice") == question_type)

func get_flashcards_for_level(level_id: int) -> Array:
	return questions.filter(func(q): 
		return q["level_id"] == level_id and q.get("question_type", "") == "flashcard"
	)

func get_multiple_choice_for_level(level_id: int) -> Array:
	return questions.filter(func(q): 
		return q["level_id"] == level_id and q.get("question_type", "multiple_choice") == "multiple_choice"
	)

# ===== ANSWER CHECKING =====
func check_answer(question_id: int, selected_option: String) -> bool:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		push_error("Question not found: " + str(question_id))
		return false
	
	# For multiple choice questions
	if question.has("correct_option"):
		return question["correct_option"] == selected_option.to_upper()
	
	return false

# Check if a flashcard statement is correct or false
func check_flashcard_answer(question_id: int, is_statement_correct: bool) -> bool:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		push_error("Question not found: " + str(question_id))
		return false
	
	# For flashcard questions, we need to know if the shown statement was correct or false
	# The player answers if they think it's correct (true) or false (false)
	# This function returns true if player's assessment matches reality
	return is_statement_correct

func get_correct_answer(question_id: int) -> String:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return ""
	return question["correct_option"]

func get_answer_text(question_id: int, option: String) -> String:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return ""
	
	var option_key = "option_" + option.to_lower()
	if question.has(option_key):
		return question[option_key]
	return ""

# ===== SCORING FUNCTIONS =====
func calculate_points(question_id: int, attempts_used: int) -> int:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return 0
	
	var base_points = question["points"]
	var max_attempts = question.get("attempts_allowed", 3)
	
	# If answered within allowed attempts, give full points
	if attempts_used <= max_attempts:
		return base_points
	
	# If exceeded max attempts, no points
	return 0

func add_score(points: int) -> void:
	current_score += points

func get_score() -> int:
	return current_score

func reset_score() -> void:
	current_score = 0

# ===== UTILITY FUNCTIONS =====
func get_total_questions_for_difficulty(difficulty: String) -> int:
	return get_questions_by_difficulty(difficulty).size()

func get_max_score_for_level(level_id: int) -> int:
	var level_questions = get_questions_for_level(level_id)
	var max_score = 0
	for question in level_questions:
		max_score += question["points"]
	return max_score

func get_max_score_for_difficulty(difficulty: String) -> int:
	var difficulty_questions = get_questions_by_difficulty(difficulty)
	var max_score = 0
	for question in difficulty_questions:
		max_score += question["points"]
	return max_score

# ===== DEBUG FUNCTIONS =====
func print_all_levels() -> void:
	print("=== ALL LEVELS ===")
	for level in levels:
		print("ID: ", level["id"], " | Name: ", level["name"], " | Order: ", level["level_order"])

func print_all_questions() -> void:
	print("=== ALL QUESTIONS ===")
	for question in questions:
		var q_type = question.get("question_type", "multiple_choice")
		var q_text = ""
		
		if q_type == "flashcard":
			q_text = question.get("correct_statement", "N/A")
		else:
			q_text = question.get("question_text", "N/A")
		
		print("ID: ", question["id"], " | Level: ", question["level_id"], " | Type: ", q_type, " | Text: ", q_text)

# ===== TEST FUNCTION =====
func test_data_manager():
	print("\n=== TESTING DATA MANAGER ===\n")
	
	# Test 1: Print all data
	print_all_levels()
	print("\n")
	print_all_questions()
	
	# Test 2: Get levels by difficulty
	print("\n=== EASY LEVELS ===")
	var easy_levels = get_levels_by_difficulty("Easy")
	print("Found ", easy_levels.size(), " Easy levels")
	for level in easy_levels:
		print("  - Level ID: ", level["id"])
	
	print("\n=== NORMAL LEVELS ===")
	var normal_levels = get_levels_by_difficulty("Normal")
	print("Found ", normal_levels.size(), " Normal levels")
	
	print("\n=== HARD LEVELS ===")
	var hard_levels = get_levels_by_difficulty("Hard")
	print("Found ", hard_levels.size(), " Hard levels")
	
	# Test 3: Get questions for a level
	print("\n=== QUESTIONS FOR LEVEL 1 ===")
	var level1_questions = get_questions_for_level(1)
	print("Found ", level1_questions.size(), " questions")
	if level1_questions.size() > 0:
		print("First question: ", level1_questions[0]["question_text"])
	
	# Test 4: Check answer
	if questions.size() > 0:
		print("\n=== TESTING ANSWER CHECKING ===")
		var first_q_id = questions[0]["id"]
		var correct_ans = questions[0]["correct_option"]
		print("Question ID: ", first_q_id)
		print("Correct answer is: ", correct_ans)
		
		var is_correct_A = check_answer(first_q_id, "A")
		var is_correct_B = check_answer(first_q_id, "B")
		print("Is 'A' correct? ", is_correct_A)
		print("Is 'B' correct? ", is_correct_B)
	
	# Test 5: Calculate points
	if questions.size() > 0:
		print("\n=== TESTING SCORING ===")
		var first_q_id = questions[0]["id"]
		var points_1_attempt = calculate_points(first_q_id, 1)
		var points_2_attempts = calculate_points(first_q_id, 2)
		var points_3_attempts = calculate_points(first_q_id, 3)
		var points_4_attempts = calculate_points(first_q_id, 4)
		print("Points with 1 attempt: ", points_1_attempt)
		print("Points with 2 attempts: ", points_2_attempts)
		print("Points with 3 attempts: ", points_3_attempts)
		print("Points with 4 attempts: ", points_4_attempts)
	
	# Test 6: Max scores
	print("\n=== MAX SCORES ===")
	if levels.size() > 0:
		print("Max score for level 1: ", get_max_score_for_level(1))
	print("Max score for Easy difficulty: ", get_max_score_for_difficulty("Easy"))
	print("Max score for Normal difficulty: ", get_max_score_for_difficulty("Normal"))
	print("Max score for Hard difficulty: ", get_max_score_for_difficulty("Hard"))
	
	# Test 7: Score management
	print("\n=== TESTING SCORE MANAGEMENT ===")
	print("Initial score: ", get_score())
	add_score(10)
	print("After adding 10: ", get_score())
	add_score(25)
	print("After adding 25: ", get_score())
	reset_score()
	print("After reset: ", get_score())
	
	print("\n=== ALL TESTS COMPLETE ===\n")
