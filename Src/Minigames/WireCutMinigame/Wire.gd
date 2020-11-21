class_name Wire
extends Area2D

signal wire_cut(color_type)
var plier_entered: bool = false
var is_cut: bool = false

export (Types.WireColors) var color_type: int 

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	$AnimatedSprite.play("normal")


func _process(delta: float) -> void:
	if plier_entered:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and not is_cut:
			cut()
			emit_signal("wire_cut", color_type)
			Events.emit_signal("play_sound", "wirecut")

func cut():
	is_cut = true
	$AnimatedSprite.play("cut")
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Plier"):
		plier_entered = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Plier"):
		plier_entered = false
