extends Node



func _ready() -> void:
	DiscordRPC.app_id = 1161745725659549786
	DiscordRPC.details = ""
	DiscordRPC.state = "Looking for something to play"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	print(DiscordRPC.get_current_user())
	
	DiscordRPC.refresh()

func _update() -> void:
	pass
	
