extends Window

# Export
@export var playtime: Label

# Variables
var edit_instance: AppInstance

# Process
func _process(delta: float) -> void:
	if edit_instance:
		var time = edit_instance.get_time_formatted()
		var launches = edit_instance.launches
		playtime.text = "Time played: {0} - Launched {1} times".format([time, launches])

# Methods
## Open window with instance
func open(instance: AppInstance) -> void:
	edit_instance = instance
	
	# Signals
	%InputTitle.text_changed.connect		(func(text): edit_instance.title = text)
	%InputGroupname.text_changed.connect	(func(text): edit_instance.groupname = text)
	%InputNotes.text_changed.connect		(func(): edit_instance.notes = %InputNotes.text)
	
	%InputProgram.text_changed.connect		(func(text): edit_instance.path = text)
	%InputArguments.text_changed.connect	(func(text): edit_instance.args = text)
	
	%InputSteamAppID.text_changed.connect	(func(text): edit_instance.steam_appid = int(text))
	
	# Update
	%InputTitle.text = instance.title
	%InputGroupname.text = instance.groupname
	%InputNotes.text = instance.notes
	
	%InputProgram.text = instance.path
	%InputArguments.text = instance.args
	
	%InputSteamAppID.text = str(instance.steam_appid)
	
	# Set up window
	title = instance.title
	force_native = true
	show()

## Hide window
func _on_close_requested() -> void:
	edit_instance.save_config()
	hide()
