@tool
extends BaseButton
class_name CircleMenuButton
## A custom radial selection menu for displaying and interacting with options within a 
## circular interface.

# --- Constants ---
const SPRITE_SIZE = Vector2(32, 32)                    ## Size for aligning option text

# --- Exported Properties ---
@export var options: Array[WheelOption]                ## List of selectable options

@export_group("Color", "color_")
@export var color_bg: Color = Color(0.3, 0.3, 0.3)     ## Background circle color
@export var color_line: Color = Color(1, 1, 1)         ## Line color for option dividers
@export var color_highlight: Color = Color(1, 0.5, 0)  ## Highlight color for selected option

@export_group("size", "size_")
@export var size_outer_radius: int = 256               ## Radius for the outer circle
@export var size_inner_radius: int = 64                ## Radius for the inner circle
@export var size_line_width: int = 4                   ## Width of the dividing lines


# --- Private Properties ---
var _selection: int = -1  # Currently selected option index

# --- Signals ---
signal closed ## Signal emitted when the _selection is confirmed

# --- Built-in Callbacks ---
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !visible:
		return
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()

	if mouse_radius < size_inner_radius:
		_selection = -1  # Set _selection to -1 if the mouse is inside the inner circle
	else:
		var mouse_angle = mouse_pos.angle()
		_selection = int(fposmod(mouse_angle, TAU) / (TAU / options.size()))  # Calculate based on angle

	if _selection >= options.size():
		_selection = options.size() - 1
	elif _selection < 0:
		_selection = -1

	if Input.is_action_just_pressed("ui_accept"):
		closed.emit()

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and visible:
			get_tree().get_root().set_input_as_handled()
			closed.emit()

func _draw() -> void:
	var offset = SPRITE_SIZE / -2  # Offset for centering text on options

	draw_circle(Vector2.ZERO, size_outer_radius, color_bg)

	draw_arc(Vector2.ZERO, size_inner_radius, 0, TAU, 128, color_line, size_line_width, true)

	if options.size() == 0:
		return

	var total_options = options.size()  # Total number of options for convenience

	for i in range(total_options):
		var angle = TAU * i / total_options
		var point = Vector2.from_angle(angle)

		draw_line(point * size_inner_radius, point * size_outer_radius, color_line, size_line_width, true)

	if _selection >= 0 and _selection < total_options:
		var selected_index = total_options - 1 - _selection  # Adjust for correct _selection highlighting
		var start_rads = TAU * selected_index / total_options  # Start angle for the option
		var end_rads = TAU * (selected_index + 1) / total_options  # End angle for the next option

		var points_per_arc = 32  # Number of points to define the arc
		var points_inner = PackedVector2Array()
		var points_outer = PackedVector2Array()

		for j in range(points_per_arc + 1):
			var _angle = start_rads + j * (end_rads - start_rads) / points_per_arc
			points_inner.append(size_inner_radius * Vector2.from_angle(-_angle))  # Inner arc points
			points_outer.append(size_outer_radius * Vector2.from_angle(-_angle))  # Outer arc points

		points_outer.reverse()  # Reverse outer points to close the shape

		draw_colored_polygon(points_inner + points_outer, color_highlight)

	for i in range(total_options):
		var default_font = ThemeDB.fallback_font  # Font for option names
		var default_font_size = ThemeDB.fallback_font_size
		var angle = TAU * i / total_options
		var mid_angle = angle + (TAU / (2 * total_options))  # Midpoint angle for text alignment
		var draw_pos = ((size_inner_radius + size_outer_radius) / 2.0) * Vector2.from_angle(mid_angle) + offset

		draw_string(default_font, draw_pos, options[i].name, HORIZONTAL_ALIGNMENT_CENTER, -1, default_font_size)

	if _selection == -1:
		draw_circle(Vector2.ZERO, size_inner_radius, color_highlight)

# --- Custom Methods ---
## Method to close the menu and emit the selected option
func close():
	hide()
	return _selection
