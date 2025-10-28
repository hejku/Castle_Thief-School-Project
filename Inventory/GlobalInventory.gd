extends Node

var items: Array = []  
var max_slots: int = 9
var completed_minigames := []

func _ready():
	print("GlobalInventory loaded!")

func add_item(item: Dictionary) -> bool:
	if items.size() < max_slots:
		items.append(item)
		print("Added item to global inventory: ", item)
		return true
	else:
		print("Inventory full! Cannot add item: ", item)
		return false

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		var removed_item = items.pop_at(index)
		print("Removed item from global inventory: ", removed_item)

func get_items() -> Array:
	return items.duplicate()  

func has_space() -> bool:
	return items.size() < max_slots

func is_minigame_completed(minigame_id: String) -> bool:
	return minigame_id in completed_minigames

func mark_minigame_completed(minigame_id: String):
	if not minigame_id in completed_minigames:
		completed_minigames.append(minigame_id)
		
func clear_inventory() -> void:
	items.clear()
	print("Global inventory cleared")


func debug_inventory() -> void:
	print("=== GLOBAL INVENTORY DEBUG ===")
	print("Items count: ", items.size())
	print("Max slots: ", max_slots)
	print("Items: ", items)
	print("==============================")
