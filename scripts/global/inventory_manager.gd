extends Node
## Inventory manager, handles storing the inventory in a global space
## each time a new inventory is added it gets a new id
## potentional issue is if the player opens to many inventories and the next id 
## somehow becomes to big which I dont think will ever happen but we never know...

#var inventories : Dictionary[int,InventoryContainer]
var inventories : Array[InventoryContainer]
var next_id : int = 0

## Player related
var player_items : ItemInventory = preload("res://resources/inventories/player_inventory.tres")
var player_inv : InventoryContainer = InventoryContainer.new(player_items.inventory_size):
	set(value):
		unregister_inventory(player_inv)
		register_inventory(value)
		player_inv = value

func _ready() -> void:
	register_inventory(player_inv)

## The register and unregister functions might need to be reworked because of how loading new scenes
## might be handled, if the inventory is fresh then it might not have an id already set when loading
## a new scene, but I think it will work still...
func register_inventory(inv : InventoryContainer) -> void:
	
	## if the id is -1, it means the inventory has not been set
	match inv.get_id():
		-1:
			inventories.append(inv)
			inv.set_id(next_id)
			## this might not be needed if we just use the array size, leaving it for now.
			next_id += 1
		_:
			inventories[inv.get_id()] = inv
	
func unregister_inventory(inv : InventoryContainer) -> void:
	var id : int = inv.get_id()
	
	if id <= -1:
		return
	## when we want to not use an inventory it is better to set it to null
	## this is because we dont want to shuffle the array and also cause mismatch inventory IDs.
	inventories[id] = null

func get_inventory(id : int) -> InventoryContainer:
	return inventories.get(id)
