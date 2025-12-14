extends Node
signal updated

# Export
@export var Icons: Dictionary[String, Texture2D]

# Variables
var settings: ConfigFile = ConfigFile.new()
var instances: Array[AppInstance] = []
var processes: Array[Dictionary] = []

const PATH_SETTINGS = "user://settings.cfg"

# Process
func send_update(): call_deferred("emit_signal", "updated")
func _ready() -> void:
	load_settings()
	load_instances()

#region Settings
func save_settings(): settings.save(PATH_SETTINGS)
func load_settings():
	settings.load(PATH_SETTINGS)
	
	# Default settings
	settings.set_value("user", "path", settings.get_value("user", "path", "user://"))
	
	# Create default directories
	var dir = DirAccess.open(settings.get_value("user", "path"))
	dir.make_dir("instances")
	
	# Save defaults
	save_settings()

#endregion
#region Instances
## Loads instances from a specified user directory
func load_instances():
	var dir = DirAccess.open(str(settings.get_value("user", "path"), "instances"))
	for file in dir.get_files():
		var path = str(dir.get_current_dir(), "/", file)
		var instance: AppInstance = AppInstance.create_from_config(path)
		add_instance(instance)

## Saves an instance to /instances
func get_instance_path(instance: AppInstance):
	return str(settings.get_value("user", "path"), "instances/", instance.identifier, ".cfg")

## Adds an instance to a list
func add_instance(instance: AppInstance):
	instances.append(instance)
	add_child(instance)
	send_update()
	
## Removes an instance from a list
func remove_instance(instance: AppInstance):
	var pos = instances.find(instance)
	if pos: instances.remove_at(pos)
	remove_child(instance)
	send_update()

#endregion
