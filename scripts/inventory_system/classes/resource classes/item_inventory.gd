extends Resource
class_name ItemInventory
## A resource class for storing item_containers which can be used for saving and loading.
## E.G the player would have an item inventory.
@export var inventory_size : Vector2i = Vector2i.ONE
@export var inventory : Array[ItemContainer]
