extends Node

var all_peg_layouts = [] 
var current_peg_layout = [] 
var unlit_pegs: int
var current_pegs = []
var current_layout_number: int = 99999

func _ready() -> void:
	_load_peg_layouts()

# Loads peg layouts from JSON file
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
	current_peg_layout = all_peg_layouts[randomNum]
	current_layout_number = randomNum;
	unlit_pegs = 0

	# Instantiate default pegs in the scene
	# copy this code but change current_peg_layout.x and peg = preload() to desired peg type
	if "pegs" in current_peg_layout:
		var default_pegs = current_peg_layout.pegs
		unlit_pegs += default_pegs.size()
		for peg_location in default_pegs:
			var peg = preload("res://scenes/peg.tscn").instantiate()
			peg.position = Vector2(peg_location.x, peg_location.y)
			get_tree().current_scene.add_child(peg)
		
	# Instantiate all mega pegs in the scene
	if "mega_pegs" in current_peg_layout:
		var mega_pegs = current_peg_layout.mega_pegs
		unlit_pegs += mega_pegs.size()
		for peg_location in mega_pegs:
			var peg = preload("res://scenes/mega_peg.tscn").instantiate()
			peg.position = Vector2(peg_location.x, peg_location.y)
			get_tree().current_scene.add_child(peg)
		

func _update_peg_count():
	unlit_pegs -= 1
	if (unlit_pegs <= 0):
		call_deferred("_add_pegs_to_scene")
		

		
