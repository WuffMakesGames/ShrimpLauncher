extends Container

enum POPUP_ID {
	RENAME=0, COVER=1,
	LAUNCH=10, STOP=11,
	PROPERTIES=20, GROUP=21, COPY=22, DELETE=23,
	AWARD=30,
}

# Export
@export var icon_material: ShaderMaterial
@export var label_title: Label
@export var label_time: Label
@export var overlay: PanelContainer

# Variables
@onready var popup: PopupMenu = $PopupMenu
@onready var properties: Window = $InstanceProperties
@onready var icon: TextureRect = $Icon

var hover: float = 0.0
var border_active: bool = false

var tween: Tween
var instance: AppInstance
var update_icon: bool = true

# Process
func _ready() -> void:
	icon.material = icon_material.duplicate()
	popup.hide()
	
	# Signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_mouse_entered)
	focus_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not instance: return
	
	# Enable pass-through when dragging instance
	var dragging = get_viewport().gui_get_drag_data()
	mouse_filter = Control.MOUSE_FILTER_IGNORE if dragging is AppInstance else Control.MOUSE_FILTER_STOP
	
	# Set labels
	label_title.text = instance.title
	label_time.text = instance.get_time_formatted()
	
	# Set icon
	if update_icon:
		instance.fetch_texture()
		update_icon = false
	icon.texture = instance.texture
	
	# Animate item
	icon.pivot_offset = icon.size / 2.0
	icon.scale = Vector2(1+hover*0.05, 1+hover*0.05)
	icon.material.set_shader_parameter("hover", hover)
	overlay.modulate.a = hover
	
	# Animate border
	%Border.modulate = Color(0.157, 0.592, 1.0).lerp(Color(0.616, 0.797, 1.0), 0.5 + sin(Time.get_ticks_msec()/200.0)*0.5)
	%Border.visible = border_active

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse: border_active = false
	else: border_active = true
	
	# Mouse buttons
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click: instance.launch()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			open_popup()
	
	# Inputs
	if event.is_action_pressed("ui_accept"):
		instance.launch()

# Methods
func open_popup():
	popup.clear()
	
	# Create items
	popup.add_icon_item(instance.texture, label_title.text, 100)
	
	popup.add_separator("")
	
	#popup.add_icon_item(Global.Icons.pencil, "Rename", POPUP_ID.RENAME)
	popup.add_icon_item(Global.Icons.paint, "Set Cover", POPUP_ID.COVER)
	
	popup.add_separator("")
	
	popup.add_icon_item(Global.Icons.play, "Launch", POPUP_ID.LAUNCH)
	popup.add_icon_item(Global.Icons.x, "Stop", POPUP_ID.STOP)
	
	popup.add_separator("")
	
	popup.add_icon_item(Global.Icons.adjustments, "Properties", POPUP_ID.PROPERTIES)
	popup.add_icon_item(Global.Icons.tags, "Change Group", POPUP_ID.GROUP)
	popup.add_icon_item(Global.Icons.award, "Achievements", POPUP_ID.AWARD)
	popup.add_icon_item(Global.Icons.copy, "Copy", POPUP_ID.COPY)
	popup.add_icon_item(Global.Icons.trash, "Delete", POPUP_ID.DELETE)
	
	# Disable items
	popup.set_item_disabled(popup.get_item_index(100), true)
	popup.set_item_disabled(popup.get_item_index(POPUP_ID.LAUNCH), instance.is_running())
	popup.set_item_disabled(popup.get_item_index(POPUP_ID.STOP), not instance.is_running())
	popup.set_item_disabled(popup.get_item_index(POPUP_ID.AWARD), instance.steam_appid == 0)
	
	# Show popup
	var viewport = get_viewport_rect()
	var min_size = popup.get_contents_minimum_size()
	var rect = Rect2(get_viewport().get_mouse_position(), Vector2(max(min_size.x, 200), min_size.y))
	popup.position = rect.position.clamp(Vector2.ZERO, viewport.size - rect.size)
	popup.size = rect.size
	popup.show()

# Signals
func _on_mouse_entered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "hover", 1.0, 0.1)

func _on_mouse_exited() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "hover", 0.0, 0.1)

func _on_file_cover_file_selected(path: String) -> void:
	instance.icon_path = path
	instance.save_config()
	update_icon = true

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == POPUP_ID.PROPERTIES: $InstanceProperties.open(instance)
	elif id == POPUP_ID.COVER: $FileCover.show()

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview: Control = icon.duplicate()
	for child in preview.get_children(): preview.remove_child(child)
	preview.custom_minimum_size.x = 100
	instance.dragged()
	
	set_drag_preview(preview)
	return instance
