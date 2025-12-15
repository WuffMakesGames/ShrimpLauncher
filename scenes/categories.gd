extends VBoxContainer

# Drop data
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is AppInstance and data.groupname != ""

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is AppInstance:
		data.groupname = ""
		data.save_config()
		Global.send_update()
