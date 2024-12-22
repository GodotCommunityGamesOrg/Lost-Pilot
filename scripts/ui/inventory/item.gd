extends Node

var item_name : String
var item_quantity : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	$TextureRect.texture = ResourceData.item_data[item_name].image
	var stack_size : int = int(ResourceData.item_data[item_name].stacksize)
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = str(item_quantity)
	
func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = str(item_quantity)
	
