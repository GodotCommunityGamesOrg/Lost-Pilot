extends Resource
class_name Item

@export var item_name : String
@export_multiline var item_description : String
@export var stackable : bool = false
@export var max_stackable : int = 4
@export var item_texture : Texture2D
