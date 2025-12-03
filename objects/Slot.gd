extends Area2D

# Aici vom scrie manual numele zonei în Inspector (ex: "delta_dunarii")
@export var correct_id: String = "subcarpatii"

# Aici ținem minte dacă am pus deja o piesă corectă, ca să nu mai punem alta
var is_occupied: bool = false
