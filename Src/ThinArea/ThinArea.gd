class_name ThinArea
extends Area2D

export var reduced_up = 0
export var reduced_down = 0
export var isLadder: bool

onready var destination_up_position: Vector2 = $DestinationUp.global_position  - Vector2(0, reduced_up * 8)
onready var destination_down_position: Vector2 = $DestinationDown.global_position - Vector2(0, reduced_down * 8)

