extends Node
signal updated

# Export
@export var Icons: Dictionary[String, Texture2D]

# Variables
var settings: ConfigFile = ConfigFile.new()
var instances: Array[ConfigFile] = []
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
## Launches an instance executable with optional arguments
func launch_instance(instance: ConfigFile):
	var path: String = instance.get_value("run", "path") #"C:/Users/howfwuff/AppData/local/Programs/PrismLauncher/prismlauncher.exe"
	var args: PackedStringArray = instance.get_value("run", "args", "").split(",")
	#print(path)
	#print(args)
	var pid = OS.create_process(path, args)

## Loads instances from a specified user directory
func load_instances():
	send_update()
	
	# Load from directories
	var dir = DirAccess.open(str(settings.get_value("user", "path"), "instances"))
	for file in dir.get_files():
		var instance = ConfigFile.new()
		var path = str(dir.get_current_dir(), "/", file)
		var err = instance.load(path)
		if err == OK: add_instance(instance)

## Saves an instance to /instances
func save_instance(instance: ConfigFile):
	var uid = instance.get_value("main", "uid")
	var path = str(settings.get_value("user", "path"), "instances/", uid, ".cfg")
	instance.save(path)

## Returns a new Instance
func new_instance(title: String, path: String, group: String, icon: String) -> ConfigFile:
	var instance = ConfigFile.new()
	
	# Assign values
	instance.set_value("main", "title", title)
	instance.set_value("main", "group", group)
	instance.set_value("main", "icon", icon)
	instance.set_value("run", "path", path)
	
	# Set default values
	instance.set_value("main", "playtime", 0)
	instance.set_value("main", "uid", uuid.v4())
	instance.set_value("run", "args", "")
	
	# Save new instance
	save_instance(instance)
	
	return instance

## Adds an instance to a list
func add_instance(instance: ConfigFile):
	instances.append(instance)
	send_update()
	
## Removes an instance from a list
func remove_instance(instance: ConfigFile):
	var pos = instances.find(instance)
	if pos: instances.remove_at(pos)
	send_update()

#endregion
