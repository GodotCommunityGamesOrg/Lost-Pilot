extends Control
class_name UserInterface
## A Base UI class to contain common UI features within the game such as:[br]
## - Controller Ui Support.[br]
## - viewport Text Reizing.[br]
## - Translation Switching (Unimplemented).

# --- Exported Properties ---
@export_group("Focus Start", "start")
@export var start_on: bool = true                                 ## Enables Focus Start
@export var start_focus: Control = null                           ## The [Control] that will grab focus based on [param start_MODE].
@export var start_MODE: FOCUS_START_ENUM = FOCUS_START_ENUM.READY ## the focus selection mode for when to grab focus on [param start_focus] (only should be changed on menues.) (uses: [enum FOCUS_START_ENUM]).

@export_group("Text Resize", "resize")
@export var resize_on:bool = true                                 ## Enables Text Resizing.
@export var resize_MODE: RESIZE_MODE_ENUM = RESIZE_MODE_ENUM.AUTO ## Setting for how the [UserInterface] handles font resizing.

# --- Private Properties ---
static var _base_size: Vector2 = Vector2( ## original viewport size.
	ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height")
) 

var _font_nodes: Dictionary = {} ## [Dictionary] to hold nodes with font size overrides

# --- Enum ---
enum RESIZE_MODE_ENUM 
{
	AUTO = 0,
	## the [Control]'s returned by [method get_all_children] [param font_size] property will be resized using the [Viewport]'s width and height property.
	BOTH = 1, 
	## the [Control]'s returned by [method get_all_children] [param font_size] property will be resized using the [Viewport]'s width property.
	WIDTH = 2, 
	## the [Control]'s returned by [method get_all_children] [param font_size] property will be resized using the [Viewport]'s height property.
	HEIGHT = 3 
}

enum FOCUS_START_ENUM 
{
	## The [Control] selected by [param start_on] will grab focus 
	## when the [method _ready] function is called.
	READY, 
	## The [Control] selected by [param start_on] will grab focus 
	## when the [method _on_visibility_changed] function is called.
	VISIBILITY_CHANGED,
	## The [Control] selected by [param start_on] will grab focus 
	## when either the [method _ready] function or [method _on_visibility_changed] fuction is called.
	BOTH
}

# --- Built-in Callbacks ---
func _ready() -> void:
	self.visibility_changed.connect(_on_visibility_changed)
	# Store font size and node
	for node: Node in UtilityFunctions.get_all_Children(self, UserInterface):
		if node is Control:
			if node.has_theme_font_size_override("font_size"):
				_font_nodes[node] = node.get("theme_override_font_sizes/font_size")
			elif node.has_theme_font_size("font_size"):
				_font_nodes[node] = node.get_theme_font_size("font_size")
	
	get_tree().get_root().size_changed.connect(_font_resize)
	_font_resize()
	if start_MODE == FOCUS_START_ENUM.READY or start_MODE == FOCUS_START_ENUM.BOTH:
		_focus_grab()

func _on_visibility_changed() -> void:
	if start_focus.is_inside_tree() && visible == true \
	and (start_MODE == FOCUS_START_ENUM.VISIBILITY_CHANGED or start_MODE == FOCUS_START_ENUM.BOTH):
		_focus_grab()

# --- Custom Methods ---
func _focus_grab() -> void: ## checks if the [Control] should be focused on before calling [method grab_focus] on the [param start_focus] [Control]
	if !start_on:
		return;
	if start_focus != null:
		if start_focus.get_parent() is TabContainer:
			start_focus.get_parent().current_tab = start_focus.get_parent().get_children().find(start_focus)
			start_focus.get_parent().get_tab_bar().grab_focus()
		else:
			start_focus.grab_focus()
	else:
		push_error("You do not have a focus node selected in UI class \n turn focus off or select focus node")

func _font_resize() -> void: ## Resizes all of the child nodes fonts acording to the viewport size.
	if !resize_on:
		return
		
	var viewport_size = get_viewport().size
	for node: Node in _font_nodes.keys():
		var formula: float = 1.0
		match resize_MODE:
			0:
				formula = min(viewport_size.y / _base_size.y, viewport_size.x / _base_size.x)
			1:  # Resize based on both width and height
				formula = (viewport_size.x / _base_size.x + viewport_size.y / _base_size.y) / 2.0
			2:  # Resize based on height
				formula = viewport_size.y / _base_size.y
			3:  # Resize based on width
				formula = viewport_size.x / _base_size.x

		# Apply the new font size to the node
		node.add_theme_font_size_override("font_size", _font_nodes[node] * formula)
