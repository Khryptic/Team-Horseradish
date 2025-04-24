extends Node

const save_path = "user://save_data.save"

var most_recently_played_level: int = 0
var arcade_high_score: int = 0

# If a level's high score isn't in the dictionary, it means the level has not been beaten yet.
var high_scores: Dictionary[String, int]

func _ready():
	load_game()

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)

		# Read Data
		most_recently_played_level = file.get_64()
		high_scores = file.get_var()

		print("Loaded High Scores: ", high_scores)
		print("Data loaded successfully.")

		file.close()
	else:
		print("No data saved. Using default values.")

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	# Save Data
	file.store_64(most_recently_played_level)
	file.store_var(high_scores)

	file.close()
