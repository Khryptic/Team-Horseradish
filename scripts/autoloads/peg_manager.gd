extends Node

var all_peg_layouts = [] 
var current_peg_layout = [] 
var unlit_pegs: int
var current_pegs = []
var current_layout_number: int = 99999

func _ready() -> void:
	_load_peg_layouts()

# Loads peg layouts from an external JSON file
func _load_peg_layouts():
	var file = FileAccess.open("res://scripts/pegs.json", FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var parsed_data = JSON.parse_string(json_data)
		if parsed_data is Array:
			all_peg_layouts = parsed_data
		else:
			print("Error: Failed to parse JSON data.")
	else:
		print("Error: Failed to open peg layout file.")

# Adds a new list of pegs to the scene
func _add_pegs_to_scene():
	if all_peg_layouts.is_empty():
		print("No peg layouts available.")
		return

	# Random layout
	var randomNum: int = randi() % (all_peg_layouts.size() - 1)
	
	# make sure is not the same layout as last one
	if (randomNum >= current_layout_number):
		randomNum += 1
	current_peg_layout= all_peg_layouts[randomNum]
	current_layout_number = randomNum;
	unlit_pegs = current_peg_layout.size()

	# Instantiate pegs in the scene
	for peg_data in current_peg_layout:
		var peg = preload("res://scenes/peg.tscn").instantiate()
		peg.position = Vector2(peg_data.x, peg_data.y)
		get_tree().current_scene.add_child(peg)
		

func _update_peg_count():
	unlit_pegs -= 1
	if (unlit_pegs <= 0):
		call_deferred("_add_pegs_to_scene")
		

		
