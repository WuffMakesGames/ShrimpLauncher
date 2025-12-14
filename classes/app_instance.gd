class_name AppInstance extends Node

# Instance variables
var title: String = ""
var groupname: String = ""
var icon_path: String = ""

var playtime: float = 0
var identifier: String = ""
var steam_appid: int = 0

var path: String = ""
var args: String = ""

# Variables
var texture: Texture2D
var was_running: bool = false
var save_timer: float = 30
var proc_id: int

# Process
func _process(delta: float) -> void:
	if was_running and not is_running(): save_config()

	# Check state
	was_running = is_running()
	if not is_running(): return
	
	# Update playtime
	playtime += delta/60
	save_timer -= delta
	if save_timer <= 0:
		save_timer = 30
		save_config()

#region Constructors
## Creates a new app instance from an executable file
static func create_from_executable(path: String) -> AppInstance:
	var title = path.get_slice("/", path.get_slice_count("/")-1).get_basename()
	var instance = AppInstance.new(title, "", "", path)
	
	# Get steam app id
	var directory = path.substr(0, path.rfind(path.get_file()))
	instance.steam_appid = FileAccess.get_file_as_string(str(directory, "steam_appid.txt"))
	
	# Return
	instance.save_config()
	return instance

## Creates and loads an app instance from a config file
static func create_from_config(path: String) -> AppInstance:
	var instance = AppInstance.new("", "", "", "")
	instance.load_config(path)
	return instance

## Creates an app instance with the provided details
func _init(app_title, app_group, app_icon, app_path) -> void:
	title = app_title
	groupname = app_group
	icon_path = app_icon
	path = app_path
	
	# Quick save
	identifier = uuid.v4()

#endregion

#region Runner methods
func launch() -> void:
	if OS.is_process_running(proc_id): return
	proc_id = OS.create_process(path, args.split(","))

func is_running() -> bool:
	return OS.is_process_running(proc_id)

#endregion

#region Methods
func fetch_texture() -> Texture2D:
	var texture_loaded = Loader.load(icon_path)
	if texture_loaded is Texture2D: texture = texture_loaded
	return texture

func get_time_formatted() -> String:
	if playtime < 60: return str(int(playtime), " min")
	return str(String.num(playtime/60, 1) if floor(playtime/60) < playtime/60 else int(playtime/60), " hrs")

#endregion

#region File system
## Saves to a config file in /instances
func save_config():
	var config = ConfigFile.new()
	
	# Main
	config.set_value("main", "title", title)
	config.set_value("main", "group", groupname)
	config.set_value("main", "icon", icon_path)
	config.set_value("main", "playtime", playtime)
	config.set_value("main", "steam_appid", steam_appid)
	config.set_value("main", "uid", identifier)
	
	# Run
	config.set_value("run", "path", path)
	config.set_value("run", "args", args)
	
	# Save config file
	config.save(Global.get_instance_path(self))

## Loads from a config file
func load_config(file: String) -> void:
	var config = ConfigFile.new()
	config.load(file)
	
	# Main
	title 		= config.get_value("main", "title", "Untitled")
	groupname 	= config.get_value("main", "group", "")
	icon_path 	= config.get_value("main", "icon", "")
	playtime 	= config.get_value("main", "playtime", 0)
	identifier 	= config.get_value("main", "uid", uuid.v4())
	steam_appid = config.get_value("main", "steam_appid", 0)
	
	# Run
	path = config.get_value("run", "path")
	args = config.get_value("run", "args")

#endregion
