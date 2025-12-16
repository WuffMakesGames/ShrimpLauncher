extends Control

# Export
@export var categories: Control

# Variables
@onready var category_node: PackedScene = preload("res://classes/Category.tscn") 

# Methods
func _ready() -> void:
	Global.updated.connect(_update)

func _update():
	for child in categories.get_children(): child.free()
	
	# Create groups and add instances
	var cache: Dictionary = {}
	for instance: AppInstance in Global.instances:
		var groupname = instance.groupname
		if groupname == "": groupname = "Unsorted"
		
		# Create group
		var group = cache.get(groupname)
		if not group:
			group = category_node.instantiate()
			group.set_deferred("name", groupname)
			cache.set(groupname, group)
		
		# Add instance to group
		group.call_deferred("add_instance", instance)
	
	# Sort groups and add to list
	cache.sort()
	for group in cache.values(): categories.add_child(group)
	
	# Make last group expand
	var last_group = categories.get_child(categories.get_child_count()-1)
	if last_group: last_group.set_deferred("size_flags_vertical", Control.SIZE_EXPAND_FILL)

# Signals
func _on_add_game_pressed() -> void:
	var window := $NativeFileDialog
	window.title = "Add a Game"
	window.show()

func _on_native_file_dialog_file_selected(path: String) -> void:
	var title = path.get_slice("/", path.get_slice_count("/")-1).get_basename()
	var instance = AppInstance.new(title, "", "", path)
	Global.add_instance(instance)
	instance.save_config()
