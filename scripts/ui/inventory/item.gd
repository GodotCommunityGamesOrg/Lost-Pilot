extends Node
class_name Item


var item_name : String
var item_quantity : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

## Sets the attributes of an item
func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	$TextureRect.texture = ResourceData.item_data[item_name].image
	var stack_size : int = int(ResourceData.item_data[item_name].stacksize)
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = str(item_quantity)

## Increases the item quantity
func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)
	
## Decreases the item quantity
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = str(item_quantity)
	
