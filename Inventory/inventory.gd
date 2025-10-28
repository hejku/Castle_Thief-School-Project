extends Control

var panel: Panel
var button_inventory: Button
var button_notebook: Button
var button_options: Button
var grid: GridContainer
var slots := []  

func _ready() -> void:
	visible = false
	_setup_ui()
	_load_inventory_from_global()  

func _setup_ui():
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_color_override("panel", Color(0, 0, 0, 0.8))
	add_child(panel)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center_container)
	
	var main_container = VBoxContainer.new()
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_theme_constant_override("separation", 40)
	center_container.add_child(main_container)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 50)
	hbox.custom_minimum_size = Vector2(0, 100)
	main_container.add_child(hbox)
	
	button_inventory = Button.new()
	button_inventory.text = "Inventory"
	button_inventory.custom_minimum_size = Vector2(180, 60)
	hbox.add_child(button_inventory)
	
	button_notebook = Button.new()
	button_notebook.text = "Notatnik"
	button_notebook.custom_minimum_size = Vector2(180, 60)
	hbox.add_child(button_notebook)
	
	button_options = Button.new()
	button_options.text = "Opcje"
	button_options.custom_minimum_size = Vector2(180, 60)
	hbox.add_child(button_options)
	
	var grid_center = CenterContainer.new()
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(grid_center)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 145) 
	grid_center.add_child(margin)

	grid = GridContainer.new()
	grid.columns = 3
	grid.custom_minimum_size = Vector2(600, 600)
	margin.add_child(grid)

	
	for i in range(9):
		var slot = ColorRect.new()
		slot.color = Color(1, 1, 1, 0.4)
		slot.custom_minimum_size = Vector2(150, 150)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var texture = TextureRect.new()
		texture.name = "ItemTexture"
		texture.expand = true
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture.visible = false
		texture.size = Vector2(100, 100)
		texture.custom_minimum_size = Vector2(100, 100)
		texture.position = Vector2(25, 25)
		slot.add_child(texture)
		
		grid.add_child(slot)
		slots.append(slot)
	
	button_inventory.connect("pressed", Callable(self, "_on_inventory_pressed"))
	button_notebook.connect("pressed", Callable(self, "_on_notebook_pressed"))
	button_options.connect("pressed", Callable(self, "_on_options_pressed"))
	
func _load_inventory_from_global():
	var global_items = GlobalInventory.get_items()
	
	for slot in slots:
		var tex_rect = slot.get_node_or_null("ItemTexture")
		if tex_rect:
			tex_rect.texture = null
			tex_rect.visible = false
		slot.set_meta("item", null)
		
	for i in range(min(global_items.size(), slots.size())):
		var item = global_items[i]
		var slot = slots[i]
		var tex_rect = slot.get_node_or_null("ItemTexture")
		if tex_rect:
			tex_rect.texture = item["texture"]
			tex_rect.visible = true
			slot.set_meta("item", item)
			
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		visible = not visible
		if visible:
			_load_inventory_from_global()  
			debug_inventory()
		
func _on_inventory_pressed() -> void:
	print("Otwieram inventory")
	
func _on_notebook_pressed() -> void:
	print("Otwieram notatnik")
	
func _on_options_pressed() -> void:
	print("Otwieram opcje")
	
func add_item(item: Dictionary) -> void:
	if GlobalInventory.add_item(item):
		_load_inventory_from_global()
		print("Item added to inventory successfully!")
	else:
		print("Failed to add item - inventory full!")
		
func debug_inventory() -> void:
	print("=== UI INVENTORY DEBUG ===")
	print("Visible: ", visible)
	print("Number of slots: ", slots.size())
	GlobalInventory.debug_inventory()
	print("==========================")
