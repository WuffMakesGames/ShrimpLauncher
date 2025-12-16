extends VBoxContainer

# Variables
@onready var panel: PanelContainer = $PanelContainer
@onready var list: HFlowContainer = $PanelContainer/Items
@onready var instance_node: PackedScene = preload("res://classes/ui_elements/CategoryItem.tscn")

# Process
func _process(delta: float) -> void:
	$Label/Label.text = name

# Methods
func add_instance(instance: AppInstance):
	var node = instance_node.instantiate()
	node.set_deferred("instance", instance)
	list.add_child(node)

# Drop data
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is AppInstance:
		if name == "Unsorted": return data.groupname != ""
		return data.groupname != name
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is AppInstance:
		data.groupname = "" if name=="Unsorted" else name
		data.save_config()
		Global.send_update()

# Signals
func _on_label_closed() -> void: panel.hide()
func _on_label_opened() -> void: panel.show()
