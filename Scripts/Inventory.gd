extends Control

var gridContainer : GridContainer
var items : Array
var capacity := 48
var hoveredButton
var grabbedButton
var lastClickedMousePos : Vector2
@export var CanSwapEmpty : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	gridContainer = $ScrollContainer/GridContainer
	populateButtons()
	pass # Replace with function body.

func _input(event):
	$Mouse.position = get_tree().root.get_mouse_position()
	if hoveredButton != null:
		if Input.is_action_just_pressed("shoot"):
			grabbedButton = hoveredButton
			lastClickedMousePos = get_tree().root.get_mouse_position()
			
		if lastClickedMousePos.distance_to(get_tree().root.get_mouse_position()) > 2:
			if Input.is_action_pressed("shoot"):
				$Mouse/InventoryButton.show()
				$Mouse/InventoryButton.UpdateItem(grabbedButton.currentItem, 0)
			if Input.is_action_just_released("shoot"):
				SwapButtons(grabbedButton, hoveredButton)
				$Mouse/InventoryButton.hide()
				pass
				
	if Input.is_action_just_released("shoot") && $Mouse/InventoryButton.visible:
		$Mouse/InventoryButton.hide()
		grabbedButton = null

func populateButtons():
	for i in capacity:
		var packedScene = ResourceLoader.load("res://GUI/inventorybutton.tscn")
		var itemButton : Button = packedScene.instantiate()
		itemButton.connect("OnButtonClick", OnButtonClicked)
		$ScrollContainer/GridContainer.add_child(itemButton)
		
func SwapButtons(button1, button2):
	var button1Index = button1.get_index()
	var button2Index = button2.get_index()
	gridContainer.move_child(button1, button2Index)
	gridContainer.move_child(button2, button1Index)

func Add(item : Resource):
	var currentItem = item.duplicate()
	for i in items.size():
		if items[i].ID == currentItem.ID && items[i].Quantity != items[i].StackSize:
			if items[i].Quantity + currentItem.Quantity > items[i].StackSize:
				items[i].Quantity = currentItem.StackSize
				currentItem.Quantity = -(currentItem.Quantity - items[i].StackSize)
				UpdateButton(i)
			else:
				items[i].Quantity += currentItem.Quantity
				currentItem.Quantity = 0
				UpdateButton(i)
	if currentItem.Quantity > 0:
		if currentItem.Quantity < currentItem.StackSize:
			items.append(currentItem)
			UpdateButton(items.size() - 1)
		else:
			var tempItem = currentItem.duplicate()
			tempItem.Quantity = currentItem.StackSize
			items.append(tempItem)
			UpdateButton(items.size() - 1)
			currentItem.Quantity -= currentItem.StackSize
			Add(currentItem)

func Remove(item : Resource):
	var currentItem = item
	for i in items.size():
		if items[i].ID == currentItem.ID:
			if items[i].Quantity - currentItem.Quantity < 0:
				currentItem.Quantity -= items[i].Quantity
				items[i].Quantity = 0
				UpdateButton(i)
			else:
				items[i].Quantity -= currentItem.Quantity
				currentItem.Quantity = 0
				UpdateButton(i)
				
		if currentItem.Quantity <= 0:
			break
	var tempItems = items.duplicate()
	var offset = 0
	for i in tempItems.size():
		if items[i - offset].Quantity == 0:
			items.remove_at(i - offset)
			offset += 1
	reflowButtons()


func reflowButtons():
	for i in capacity:
		UpdateButton(i)

func UpdateButton(index : int):
	if range(items.size()).has(index):
		gridContainer.get_child(index).UpdateItem(items[index], index)	
	else:
		gridContainer.get_child(index).UpdateItem(null, index)

func OnButtonClicked(index, currentItem):
	if currentItem != null:
		currentItem.UseItem()


func _on_add_item_button_down():
	Add(ResourceLoader.load("res://TestItem.tres"))
	pass # Replace with function body.


func _on_remove_item_button_down():
	Remove(ResourceLoader.load("res://TestItem.tres"))
	pass # Replace with function body.


func _on_mouse_area_entered(area):
	hoveredButton = area.get_parent()
	pass # Replace with function body.


func _on_mouse_area_exited(area):
	hoveredButton = null
	pass # Replace with function body.
