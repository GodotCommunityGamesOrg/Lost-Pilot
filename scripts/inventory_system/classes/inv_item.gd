extends RefCounted
class_name InvItem


# the top left of the item/slot
var origin : Vector2i = Vector2i(-1,-1)

var id : int = -1
var stackable : bool = false
var stack : int = -1
var icon : Texture2D
var object : Node2D

func _init(_origin : Vector2i,_id : int, item : Item) -> void:
	origin = _origin
	id = _id
	stackable = item.stackable
	stack = 1
	icon = item.item_texture
