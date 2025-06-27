extends Resource
class_name Item
## This is an important class, Item simply stores un-mutable data about the item

@export var item_name : String
@export_multiline var item_description : String
@export var stackable : bool = false
@export var max_stackable : int = 4
@export var item_texture : Texture2D
