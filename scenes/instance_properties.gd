extends Window

# Export
@export var edit_title: LineEdit
@export var edit_group: LineEdit

@export var edit_program: LineEdit
@export var edit_args: LineEdit

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
	
	# Update
	edit_title.text = instance.title
	edit_group.text = instance.groupname
	edit_program.text = instance.path
	edit_args.text = instance.args
	
	# Set up window
	title = instance.title
	force_native = true
	show()

## Hide window
func _on_close_requested() -> void:
	hide()
