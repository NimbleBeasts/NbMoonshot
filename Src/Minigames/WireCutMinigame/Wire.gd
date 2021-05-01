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
		if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_action_just_pressed("interact"):
			cut()


func cut():
	if not is_cut:
		is_cut = true
		$AnimatedSprite.play("cut")
		emit_signal("wire_cut", color_type)
		get_parent().get_parent().get_node("WireCut").play()

	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Plier"):
		plier_entered = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Plier"):
		plier_entered = false
