extends Node3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

@onready var left_hand = $LeftHand
@onready var right_hand = $RightHand

func equip_item_to_hand(item: Item, hand: Hand) -> bool:
	print("Equipping" + item.get_display_name() + " to " + hand.hand_side + " hand.")
	if not item or not hand:
		return false

	# Check if it's a two-handed weapon
	if item.is_two_handed:
		# Unequip both hands first
		if left_hand.has_item():
			left_hand.unequip_item()
		if right_hand.has_item():
			right_hand.unequip_item()

		# Equip to dominant hand only
		if right_hand.is_dominant:
			return right_hand.equip_item(item)
		else:
			return left_hand.equip_item(item)
	else:
		# Single-handed weapon
		return hand.equip_item(item)

func use_left_hand():
	if left_hand and left_hand.can_perform_action():
		left_hand.perform_action("primary")

func use_right_hand():
	if right_hand and right_hand.can_perform_action():
		right_hand.perform_action("primary")

func get_hands_status() -> String:
	var status = []
	if left_hand:
		status.append(left_hand.get_status_text())
	if right_hand:
		status.append(right_hand.get_status_text())
	return "\n".join(status)


func _on_item_equipped(item, hand):
	print("EQUIPPED ITEM")
	if hand == "right":
		player.hud.update_equipped_item(item)
	else:
		return


func _on_item_unequipped(item, hand):
	if hand == "right":
		player.hud.update_equipped_item(null)
	else:
		return
