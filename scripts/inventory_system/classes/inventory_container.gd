extends RefCounted
class_name InventoryContainer

signal slot_pressed(id : int , index : Vector2i)
signal slot_hovered(id : int , index : Vector2i)

var _slots : Dictionary[Vector2i,Slot]
var _item : Dictionary[Vector2i,InvItem]
var _size : Vector2i
var _id   : int
var _container : GridContainer
const _spacing : float = 64


func _init(size : Vector2i) -> void:
	_size = size

func set_id(id : int) -> void:
	_id = id

func generate_cells(container : GridContainer) -> void:
	_container = container
	_container.columns = _size.x
	var slot_pack : PackedScene = preload("res://scenes/inventory_system/slot.tscn")
	
	for x in range(_size.x):
		for y in range(_size.y):
			var slot : Slot = slot_pack.instantiate()
			_container.add_child(slot)
			
			# setup the signals
			slot.button.pressed.connect(slot_is_pressed.bind(slot))
			slot.button.mouse_entered.connect(slot_is_hovered.bind(slot))
			
			# set the slots index and inv id
			slot.index = Vector2i(x,y)
			## this might be useful for detecting multiple different inventories
			#slot.inventory_id = _id
			# set slot into the slots dict to be able to change the item sprite
			_slots[slot.index] = slot
			_slots[slot.index].set_stack(0)
			# set the index into the items dict and set it to null to indicate its empty
			_item[slot.index] = null

func slot_is_pressed(slot : Slot) -> void:
	slot_pressed.emit(_id,slot.index)

func slot_is_hovered(slot : Slot) -> void:
	slot_hovered.emit(_id,slot.index)

func is_cell_free(index : Vector2i) -> bool:
	if not _item.has(index):
		return false
	
	return _item[index] == null

func add_item(inv_item : InvItem) -> bool:
	var index : Vector2i = inv_item.origin
	
	#if not is_cell_free(index):
		#return false
	
	# set item and item icon
	_item[index] = inv_item
	_slots[index].set_icon(inv_item.icon)
	_slots[index].set_stack(inv_item.stack)
	
	return true

func remove_item(inv_item : InvItem) -> void:
	var index : Vector2i = inv_item.origin
	_item[index] = null
	_slots[index].set_icon(null)
	_slots[index].set_stack(0)

func get_item(index : Vector2i) -> InvItem:
	return _item[index]

func load_data(items : Array[Dictionary],database : ItemDatabase) -> void:
	
	for item in items:
		var found_item : Item = database.database[item["ID"]]
		
		var inv_item : InvItem = InvItem.new(item["Position"],item["ID"],found_item)
		add_item(inv_item)
