extends Control

@onready var health_bar: ProgressBar = $MarginContainer/Bars/HealthBar
@onready var health_bar_label: Label = $MarginContainer/Bars/HealthBar/Value

@onready var mana_bar: ProgressBar = $MarginContainer/Bars/ManaBar
@onready var mana_bar_label: Label = $MarginContainer/Bars/ManaBar/Value

@onready var stamina_bar: ProgressBar = $MarginContainer/Bars/StaminaBar
@onready var stamina_bar_label: Label = $MarginContainer/Bars/StaminaBar/Value

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
		"stamina":
			stamina_bar.max_value = max
			stamina_bar.value = current
			stamina_bar_label.text = str(int(current)) + "/" + str(int(max))
