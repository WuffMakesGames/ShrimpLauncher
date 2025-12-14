extends VBoxContainer

# Variables
@onready var panel: PanelContainer = $PanelContainer
@onready var list: HFlowContainer = $PanelContainer/Items
@onready var instance_node: PackedScene = preload("res://classes/CategoryItem.tscn")

# Process
func _process(delta: float) -> void:
	$Label/Label.text = name

# Methods
func add_instance(instance: ConfigFile):
	var node = instance_node.instantiate()
	node.set_deferred("instance", instance)
	list.add_child(node)

# Signals
func _on_label_closed() -> void: panel.hide()
func _on_label_opened() -> void: panel.show()
