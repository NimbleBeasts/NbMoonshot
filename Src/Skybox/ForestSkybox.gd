tool
extends Node2D


func _ready():
	Events.connect("hud_light_level", self, "setLightLevel")


func setLightLevel(level):
	var color = Global.gameConstant.lightLevels[level]
	#$FixedBackground/CanvasModulate.color = color
	$ParallaxBackground/CanvasModulate.color = color
