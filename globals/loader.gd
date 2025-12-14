class_name Loader extends Node

## Attempts to load a file.
static func load(path: String) -> Variant:
	var ext = path.get_extension()
	var output = null
	
	# Images
	if ext == "png": output = load_image(path)
	elif ext == "jpg": output = load_image(path)
	elif ext == "bmp": output = load_image(path)
	
	# Return loaded asset, or null if it failed
	return output

## Loads an image from a file.
static func load_image(path: String):
	return ImageTexture.create_from_image(Image.load_from_file(path))
