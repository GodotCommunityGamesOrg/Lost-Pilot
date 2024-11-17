extends CanvasLayer

var holding_item = null

# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		$Inventory.visible = !$Inventory.visible
		$Hotbar.tooltip_change()
	if event.is_action_pressed("scroll_up"):
		if $Inventory.visible:
			PlayerInventory.active_inventory_item_scroll_up()
		else:
			PlayerInventory.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		if $Inventory.visible:
			PlayerInventory.active_inventory_item_scroll_down()
		else:
			PlayerInventory.active_item_scroll_down()
	if event.is_action_pressed("hotkey1"):
		PlayerInventory.change_active_item_slot(0)
	if event.is_action_pressed("hotkey2"):
		PlayerInventory.change_active_item_slot(1)
	if event.is_action_pressed("hotkey3"):
		PlayerInventory.change_active_item_slot(2)
	if event.is_action_pressed("hotkey4"):
		PlayerInventory.change_active_item_slot(3)
	if event.is_action_pressed("hotkey5"):
		PlayerInventory.change_active_item_slot(4)
	if event.is_action_pressed("hotkey6"):
		PlayerInventory.change_active_item_slot(5)
	if event.is_action_pressed("hotkey7"):
		PlayerInventory.change_active_item_slot(6)
	if event.is_action_pressed("hotkey8"):
		PlayerInventory.change_active_item_slot(7)
		

func _ready() -> void:
	get_tree().node_added.connect(self.tree_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func tree_changed(new_node):
	if new_node.name == "PauseMenu":
		visible = false
	if new_node.name == "InGameMenu":
		visible = true
