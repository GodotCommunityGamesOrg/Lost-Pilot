extends Node

var item_data : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_data = LOADDATA("res://Data/ItemData.json")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func LOADDATA(file_path):
	var json_data
	var file_data = FileAccess.get_file_as_string(file_path)
	json_data = JSON.parse_string(file_data)
	return json_data
