extends Control

@export var level_buttons: Array[LevelButton]

var page: int = 0;
var last_level_num: int = 1

func _ready() -> void:
	last_level_num = PegManager.all_peg_layouts.size()
	updateButtons()


	
func updateButtons():
	for i in range(6):
		level_buttons[i].show()
		var levelNumber: int = page  * 6 + i + 1
		if (levelNumber > last_level_num):
			level_buttons[i].hide()
		else:
			level_buttons[i].set_level_to_go_to(levelNumber)
	
func next_page():
	if (page * 6 + 7 > last_level_num):
		return
	page += 1
	updateButtons()
	
func back_page():
	if (page > 0):
		page -= 1
		updateButtons()
