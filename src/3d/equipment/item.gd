extends Resource
class_name Item

## Base item class for all equipable items
## Contains core properties shared by all item types

@export var item_name: String = ""
@export var icon: Texture2D
@export var model_scene: PackedScene  # Changed from Mesh to PackedScene for .glb files
@export var model_mesh: Mesh  # Optional: for simple mesh-only items
@export var category: String = ""
@export var weight: float = 0.0
@export var size: Vector2i = Vector2i(1, 1)
@export var is_two_handed: bool = false
@export_multiline var description: String = ""

func _init(
	p_name: String = "",
	p_icon: Texture2D = null,
	p_model_scene: PackedScene = null,
	p_model_mesh: Mesh = null,
	p_category: String = "",
	p_weight: float = 0.0,
	p_size: Vector2i = Vector2i(1, 1),
	p_is_two_handed: bool = false,
	p_description: String = ""
):
	item_name = p_name
	icon = p_icon
	model_scene = p_model_scene
	model_mesh = p_model_mesh
	category = p_category
	weight = p_weight
	size = p_size
	is_two_handed = p_is_two_handed
	description = p_description

func get_display_name() -> String:
	return item_name if item_name != "" else "Unknown Item"

func get_weight_text() -> String:
	return "%.1f kg" % weight

func get_size_text() -> String:
	return "%dx%d" % [size.x, size.y]

func is_valid() -> bool:
	return item_name != "" and category != ""

func get_info_text() -> String:
	var info = []
	info.append("Name: " + get_display_name())
	info.append("Category: " + category)
	info.append("Weight: " + get_weight_text())
	info.append("Size: " + get_size_text())
	if is_two_handed:
		info.append("Two-handed weapon")
	if description != "":
		info.append("Description: " + description)
	return "\n".join(info)

func has_model() -> bool:
	return model_scene != null or model_mesh != null

func is_scene_model() -> bool:
	return model_scene != null

func is_mesh_model() -> bool:
	return model_mesh != null

func get_model_for_display():
	# Returns the appropriate model for display
	if model_scene:
		return model_scene
	elif model_mesh:
		return model_mesh
	else:
		return null
