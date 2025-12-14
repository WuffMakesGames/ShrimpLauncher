extends HBoxContainer
signal opened
signal closed

# Variables
@onready var open: bool = true
@onready var icon: TextureRect = $Icon
@onready var label: RichTextLabel = $Label

@onready var icon_open: Texture2D = preload("res://assets/icons/chevron-down.svg")
@onready var icon_closed: Texture2D = preload("res://assets/icons/chevron-right.svg")

# Process
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_click()

# Methods
func on_click() -> void:
	open = not open
	if open:
		emit_signal("opened")
		icon.texture = icon_open
	else:
		emit_signal("closed")
		icon.texture = icon_closed
