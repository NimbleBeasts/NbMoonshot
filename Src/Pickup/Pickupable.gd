extends Area2D
class_name Pickupable

# this is the offset that is to be added when setting position to player's position
export var pickupOffset: Vector2
export var pickupName: String 
var isPickedUp: bool = false


func pickup() -> void:
    hide()
    isPickedUp = true