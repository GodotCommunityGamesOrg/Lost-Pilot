extends CanvasLayer
class_name UI

var holding_item : Object = null

## Pull up or Hides the Inventory. Changes the active inventory slot based on hotkeys and scrolling
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
	if event is InputEventKey:
		var action_string : String = event_text(event)
		if "hotkey" in action_string:
			var sub_action_string = action_string.substr(6)
			PlayerInventory.change_active_item_slot(int(sub_action_string)-1)

## Connects signal to check if any node get added to the scene at runtime 
func _ready() -> void:
	get_tree().node_added.connect(self.tree_changed)

## Changes visibility based on menu changes
func tree_changed(new_node):
	if new_node.name == "PauseMenu":
		visible = false
	if new_node.name == "InGameMenu":
		visible = true

## Used to get Hotkeys
func event_text(event):
	for action in InputMap.get_actions():
		if event.is_action(action):
			return action
