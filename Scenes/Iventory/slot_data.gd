extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 99 #Change this later for different stack sizes depending on item type

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1
