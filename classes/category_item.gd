extends PanelContainer

enum POPUP_ID {
	RENAME=0, COVER=1,
	LAUNCH=10, STOP=11,
	PROPERTIES=20, GROUP=21, COPY=22, DELETE=23
}

# Export
@export var icon_material: ShaderMaterial
@export var label_title: RichTextLabel
@export var label_time: RichTextLabel

# Variables
@onready var appicon: TextureRect = $Icon
@onready var overlay: PanelContainer = $Icon/Overlay
@onready var popup: PopupMenu = $PopupMenu

var hover: float = 0.0
var tween: Tween
var instance: ConfigFile
var update_icon: bool = true

# Process
func _ready() -> void:
	appicon.material = icon_material.duplicate()
	popup.hide()
	
	# Signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Values
	var title = instance.get_value("main", "title")
	var time = instance.get_value("main", "playtime", 0)
	var icon = instance.get_value("main", "icon", "res://default.png")
	
	# Process playtime
	if time < 60: time = str(int(time), " min")
	else: time = str(String.num(time/60, 1) if floor(time/60) < time/60 else int(time/60), "hrs")
	
	# Set labels
	label_title.text = title
	label_time.text = time
	
	# Set icon
	if update_icon and FileAccess.file_exists(icon):
		var texture = Loader.load(icon)
		if texture is Texture2D: appicon.texture = texture
		update_icon = false
	
	# Animate item
	appicon.pivot_offset = appicon.size/2
	appicon.scale = Vector2(1+hover*0.05, 1+hover*0.05)
	appicon.material.set_shader_parameter("hover", hover)
	overlay.modulate.a = hover

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: grab_focus()
		if event.double_click: Global.launch_instance(instance)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		open_popup()

# Methods
func open_popup():
	popup.clear()
	
	# Create items
	popup.add_icon_item(Loader.load_image(instance.get_value("run", "path")), label_title.text, 100)
	popup.set_item_disabled(popup.get_item_index(100), true)
	
	popup.add_separator("")
	
	popup.add_icon_item(Global.Icons.pencil, "Rename", POPUP_ID.RENAME)
	popup.add_icon_item(Global.Icons.paint, "Set Cover", POPUP_ID.COVER)
	
	popup.add_separator("")
	
	popup.add_icon_item(Global.Icons.play, "Launch", POPUP_ID.LAUNCH)
	popup.add_icon_item(Global.Icons.cancel, "Stop", POPUP_ID.STOP)
	popup.set_item_disabled(popup.get_item_index(POPUP_ID.STOP), true)
	
	popup.add_separator("")
	
	popup.add_icon_item(Global.Icons.adjustments, "Properties", POPUP_ID.PROPERTIES)
	popup.add_icon_item(Global.Icons.tags, "Change Group", POPUP_ID.GROUP)
	popup.add_icon_item(Global.Icons.copy, "Copy", POPUP_ID.COPY)
	popup.add_icon_item(Global.Icons.trash, "Delete", POPUP_ID.DELETE)
	
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
	instance.set_value("main", "icon", path)
	update_icon = true
	Global.save_instance(instance)

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == POPUP_ID.COVER: $FileCover.show()
