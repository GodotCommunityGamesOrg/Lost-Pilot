extends Node
class_name _SaveManager

## A location for storing our saves
const save_folder : String = "res://saves/"
## The types of saves we want,Stats, Inventory, Settings, etc
var save_types : Array[String] = ["Player","Inventory","Settings"]

## Called when we need to save some data.
func save_data() -> void:
	pass

func load_data() -> void:
	pass
