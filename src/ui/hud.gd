extends Control

@onready var health_bar: ProgressBar = $MarginContainer/Bars/HealthBar
@onready var health_bar_label: Label = $MarginContainer/Bars/HealthBar/Value

@onready var mana_bar: ProgressBar = $MarginContainer/Bars/ManaBar
@onready var mana_bar_label: Label = $MarginContainer/Bars/ManaBar/Value

@onready var equipped_item_icon: TextureRect = $MarginContainer/EquippedItem/ItemIcon
@onready var equipped_item_label: Label = $MarginContainer/EquippedItem/ItemLabel

func update_bar(bar: String, current: float, max: float):
	match bar:
		"health":
			health_bar.max_value = max
			health_bar.value = current
			health_bar_label.text = str(int(current)) + "/" + str(int(max))
		"mana":
			mana_bar.max_value = max
			mana_bar.value = current
			mana_bar_label.text = str(int(current)) + "/" + str(int(max))

func update_equipped_item(item: Item):
	if !item:
		equipped_item_icon.texture = null
		equipped_item_label.text = "No item"
	equipped_item_icon.texture = item.icon
	equipped_item_label.text = item.get_display_name()