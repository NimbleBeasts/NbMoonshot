extends Area2D
class_name Pickupable

# this is the offset that is to be added when setting position to player's position
export var pickupOffset: Vector2
export var pickupName: String
export var showGameHints: bool = true
var isPickedUp: bool = false
var mainNode = self # this is needed for the pressure button, don't remove this

func _ready() -> void:
    # for pressure
    set_collision_layer_bit(9, true)

    
func pickup() -> void:
    isPickedUp = true
    if showGameHints:
        Events.emit_signal("hud_game_hint", "Picked up " + str(pickupName))

    
func drop() -> void:
    isPickedUp = false
    if showGameHints:
        Events.emit_signal("hud_game_hint", "Dropped " + str(pickupName))
