extends Window

# Export
@export_group("Main")
@export var edit_title: LineEdit
@export var edit_group: LineEdit
@export var edit_notes: TextEdit

@export_group("Runtime")
@export var edit_program: LineEdit
@export var edit_args: LineEdit

@export_group("Labels")
@export var playtime: Label

# Variables
var edit_instance: AppInstance

# Methods
## Open window with instance
func open(instance: AppInstance) -> void:
	edit_instance = instance
	
	# Signals
	edit_title.text_changed.connect		(func(text): edit_instance.title = text)
	edit_group.text_changed.connect		(func(text): edit_instance.groupname = text)
	edit_program.text_changed.connect	(func(text): edit_instance.path = text)
	edit_args.text_changed.connect		(func(text): edit_instance.args = text)
	
	edit_notes.text_changed.connect		(func(): edit_instance.notes = edit_notes.text)
	
	# Update
	edit_title.text = instance.title
	edit_group.text = instance.groupname
	edit_notes.text = instance.notes
	edit_program.text = instance.path
	edit_args.text = instance.args
	
	playtime.text = "Time played: {0} - Launched {1} times".format([instance.get_time_formatted(), instance.launches])
	
	# Set up window
	title = instance.title
	force_native = true
	show()

## Hide window
func _on_close_requested() -> void:
	print("Saved and Closed")
	edit_instance.save_config()
	hide()
