tool
extends Node2D

export var speed: float = 1.0 setget updateSpeed;

func _ready():
	updateSpeed(speed)
	Events.connect("hud_light_level", self, "setLightLevel")

func updateSpeed(value):
	$ParallaxBackground/L3/Sprite.material.set_shader_param("scroll_spead", 0.1 * value)
	$ParallaxBackground/L2/Sprite.material.set_shader_param("scroll_spead", 0.2 * value)
	$ParallaxBackground/L1/Sprite.material.set_shader_param("scroll_spead", 0.4 * value)
	$ParallaxBackground/Ground/Sprite.material.set_shader_param("scroll_spead", 1 * value)
	speed = value
	
	
func setLightLevel(level):
	var color = Global.gameConstant.lightLevels[level]
	#$FixedBackground/CanvasModulate.color = color
	$ParallaxBackground/CanvasModulate.color = color
