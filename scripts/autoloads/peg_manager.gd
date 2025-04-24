extends Node

@export var tscn_peg: PackedScene
@export var tscn_mega_peg: PackedScene
@export var tscn_bumper_peg: PackedScene
@export var tscn_cracked_peg: PackedScene
@export var tscn_chained_peg: PackedScene

@export var basic_peg_sprites: Array[PegSprite]
@export var cracked_peg_sprites: Array[PegSprite]
@export var bumper_peg_sprite: PegSprite

var all_peg_layouts = [] 
var current_peg_layout = [] 
var unlit_pegs: int
var current_pegs = []
var current_layout_number: int = 99999
var lit_pegs: int

var has_peg_increased_size: bool = false

@onready var peg_types: Dictionary = {
	"pegs": tscn_peg,
	"mega_pegs": tscn_mega_peg,
	"bumper_pegs": tscn_bumper_peg,
	"cracked_pegs": tscn_cracked_peg,
	"chained_pegs": tscn_chained_peg
}

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
	if (SceneManager.CURRENT_SCENE != SceneManager.SCENE.GAME):
		return
	
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
	
	for peg_type in peg_types.keys():
		if peg_type in current_peg_layout:

			var locations = current_peg_layout[peg_type]
			for location in locations:

				# Pick sprite based on peg type
				var sprite: PegSprite
				if(peg_type == "pegs" or peg_type == "mega_pegs" or peg_type == "chained_pegs"):
					sprite = basic_peg_sprites.pick_random()
				elif(peg_type == "bumper_pegs"):
					sprite = bumper_peg_sprite
				elif("cracked_pegs"):
					sprite = cracked_peg_sprites.pick_random()

				add_peg_to_scene(peg_types[peg_type], sprite, Vector2(location.x, location.y))	
	
	peg_spawn_delay = PEG_SPAWNING_DURATION / current_pegs.size()
	lit_pegs = current_pegs.size()
	
func _add_random_pegs_to_scene():
	# Reset pegs
	current_pegs.clear()
	pegs_added = 0
	time_since_last_peg_added = 0
	
	# Only include 2 types of pegs (always regular pegs)
	# Add normal pegs to scene
	for n in randi_range(6, 12):
		add_random_peg(tscn_peg, basic_peg_sprites.pick_random(), 40)
	
	var types = [1, 2, 3]
	var pegIndex = randi_range(0, types.size() - 1)
	var peg = types[pegIndex]
	match (peg):
		1:
			# Add mega pegs to scene
			for n in randi_range(1, 4):
				add_random_peg(tscn_mega_peg, basic_peg_sprites.pick_random(), 60)
		2:
			# Add bumper pegs to scene
			for n in randi_range(1, 3):
				add_random_peg(tscn_bumper_peg, bumper_peg_sprite, 50)
		3:
				# Add chained pegs to scene
			for n in randi_range(1, 3):
				add_random_peg(tscn_chained_peg, basic_peg_sprites.pick_random(), 40)
	
	peg_spawn_delay = PEG_SPAWNING_DURATION / current_pegs.size()
	lit_pegs = current_pegs.size()
		
func _remove_peg(peg : StaticBody2D):
	current_pegs.erase(peg)

	if (current_pegs.size() <= 0):	
		has_peg_increased_size = false
		
func unlight_peg():
	lit_pegs -= 1
	if (lit_pegs == 0):
		GameManager.emit_round_clear()
		
func play_specific_level(level_num : int):
	specific_level_to_play = level_num

func add_peg_to_scene(peg_scene: PackedScene, sprite: PegSprite, location: Vector2):
	var peg = peg_scene.instantiate()
	peg.position = location
	peg.peg_sprite = sprite
	current_pegs.append(peg)

func add_random_peg(peg_scene: PackedScene, sprite: PegSprite, max_overlap: int):

	const lowerBound := Vector2i(40, 100)
	const upperBound := Vector2i(450, 300)

	var peg = peg_scene.instantiate()
	peg.global_position = Vector2(randi_range(lowerBound.x, upperBound.x), randi_range(lowerBound.y, upperBound.y))
	peg.peg_sprite = sprite
	
	var timer = 0
	
	## Check for overlap
	if (current_pegs.size() == 0):
		peg.position = Vector2(randi_range(lowerBound.x, upperBound.x), randi_range(lowerBound.y, upperBound.y))
	
	else:
		var index = -1
		while (index < current_pegs.size() - 1 && timer < 300000000):
			index += 1
			timer += 1
			var p = current_pegs[index]
			while(peg.position.x >= p.position.x - max_overlap &&
				peg.position.x <= p.position.x + max_overlap &&
				peg.position.y >= p.position.y - max_overlap &&
				peg.position.y <= p.position.y + max_overlap):
					peg.position = Vector2(randi_range(lowerBound.x, upperBound.x), randi_range(lowerBound.y, upperBound.y))
					index = -1

	if (timer < 300000000):
		current_pegs.append(peg)
