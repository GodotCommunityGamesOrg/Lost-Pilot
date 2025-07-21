extends RefCounted
class_name InvItem
## InvItem is mutable data, this is created on item loads when an inventory container
## is created and set.


# the top left of the item/slot
var origin : Vector2i = Vector2i(-1,-1)
# I dont think we need an id anymore, if the items are stored locally.
# but maybe we need to get an item
var id : int = -1
var stackable : bool = false
var stack : int = -1
var icon : Texture2D
var object : Node2D
var data : Item

func _init(_origin : Vector2i, item : Item) -> void:
#func _init(_origin : Vector2i,_id : int, item : Item) -> void:
	origin = _origin
	data = item
	#id = _id
	stackable = item.stackable
	stack = 1
	icon = item.item_texture

func get_item_data() -> Item:
	return data
