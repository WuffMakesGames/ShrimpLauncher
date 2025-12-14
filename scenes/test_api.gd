extends Control

func _ready() -> void:
	var result = Steam.steamInitEx(881100)
	
	# Get achievements
	var achievements: Array[Dictionary] = []
	for i in range(Steam.getNumAchievements()):
		var achievement_name = Steam.getAchievementName(i)
		var status = Steam.getAchievementAndUnlockTime(achievement_name)
		var hidden = Steam.getAchievementDisplayAttribute(achievement_name, "hidden")
		achievements.append({
			"name": achievement_name,
			"achieved": status.get("achieved", false),
			"unlocked": status.get("unlocked", 0),
			"hidden": hidden == "1",
		})
		prints(achievement_name, achievements[len(achievements)-1])
	
	# Generate icons
	while len(achievements) > 0:
		var achievement = achievements.pop_back()
		
		# Get image data
		var icon_handle: int = Steam.getAchievementIcon(achievement.name)
		var icon_size: Dictionary = Steam.getImageSize(icon_handle)
		var icon_buffer: Dictionary = Steam.getImageRGBA(icon_handle)
		
		# Failed
		if not icon_buffer.get("success"):
			achievements.insert(0, achievement)
			continue
		
		# Create texture
		var icon_image: Image = Image.create_from_data(icon_size.width, icon_size.height, false, Image.FORMAT_RGBA8, icon_buffer["buffer"])
		var icon_texture: ImageTexture = ImageTexture.create_from_image(icon_image)
		
		# Create texture
		var texture = TextureRect.new()
		if not achievement.get("achieved"):
			texture.modulate = Color.DIM_GRAY
			if achievement.get("hidden"): texture.modulate = Color(0.096, 0.096, 0.096)
		
		texture.texture = icon_texture
		$HFlowContainer.add_child(texture)
		
		# Wait a short time
		await get_tree().create_timer(1.0).timeout
