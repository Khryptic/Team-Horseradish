extends Node

var all_peg_layouts = [] 
var current_peg_layout = [] 
var unlit_pegs: int
var current_pegs = []
var current_layout_number: int = 99999
var lit_pegs: int

var has_peg_increased_size: bool = false

var peg_spawn_delay: float #time between each peg spawning
const PEG_SPAWNING_DURATION: float = 1.0; #total time (sec) that pegs will spawn on screen
var time_since_last_peg_added: float 
var pegs_added: int # amount of pegs that have been added to the scene

var specific_level_to_play : int

func _ready() -> void:
	_load_peg_layouts()
	specific_level_to_play = 0


func _process(delta: float) -> void:
	#add pegs to scene
	time_since_last_peg_added += delta
	if (pegs_added < current_pegs.size()):
		while time_since_last_peg_added > 0:
			if (pegs_added >= current_pegs.size()):
				break;
			time_since_last_peg_added -= peg_spawn_delay;
			if (is_instance_valid(current_pegs[pegs_added])):
				get_tree().current_scene.add_child(current_pegs[pegs_added])
				pegs_added += 1
		if (pegs_added == current_pegs.size()):
			GameManager.start_round()

func reset():
	current_pegs.clear()
	unlit_pegs = 0
	lit_pegs = 0
	pegs_added = 0
		

	
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

# Queues new list of pegs to be added to the scene
func _add_pegs_to_scene():
	
	if all_peg_layouts.is_empty():
		print("No peg layouts available.")
		return

	if (specific_level_to_play == 0): # if there is no level requested play random level
		# Random layout
		var randomNum: int = randi() % (all_peg_layouts.size() - 1)

		# make sure it is not the same layout as last one
		if (randomNum >= current_layout_number):
			randomNum += 1
		current_peg_layout = all_peg_layouts[randomNum]
		current_layout_number = randomNum;
	else:
		current_peg_layout = all_peg_layouts[specific_level_to_play -1]
		current_layout_number = specific_level_to_play -1


	time_since_last_peg_added = 0
	
	current_pegs.clear()
	pegs_added = 0
	
	# Queue all normal pegs to be added to scene
	if "pegs" in current_peg_layout:
		var default_pegs = current_peg_layout.pegs
		for peg_location in default_pegs:
			var peg = preload("res://scenes/peg.tscn").instantiate()
			peg.position = Vector2(peg_location.x, peg_location.y)
			current_pegs.append(peg)
		
	# Queue all mega pegs to be added to scene
	if "mega_pegs" in current_peg_layout:
		var mega_pegs = current_peg_layout.mega_pegs
		for peg_location in mega_pegs:
			var peg = preload("res://scenes/mega_peg.tscn").instantiate()
			peg.position = Vector2(peg_location.x, peg_location.y)
			current_pegs.append(peg)
			
	
	peg_spawn_delay = PEG_SPAWNING_DURATION / current_pegs.size()
	lit_pegs = current_pegs.size()
	
		
func _remove_peg(peg : StaticBody2D):
	current_pegs.erase(peg)
	if (current_pegs.size() <= 0):
		call_deferred("_add_pegs_to_scene")
		has_peg_increased_size = false
		
func unlight_peg():
	lit_pegs -= 1
	if (lit_pegs == 0):
		GameManager.emit_round_clear()
		
func play_specific_level(level_num : int):
	specific_level_to_play = level_num
	print(specific_level_to_play)
