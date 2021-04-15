tool
extends "res://Src/Skybox/NewSkybox.gd"

export var speed: float = 1.0 setget updateSpeed;

func _ready():
	updateSpeed(speed)

func updateSpeed(value):
	$ParallaxBackground/L3/Sprite.material.set_shader_param("scroll_spead", 0.1 * value)
	$ParallaxBackground/L2/Sprite.material.set_shader_param("scroll_spead", 0.2 * value)
	$ParallaxBackground/L1/Sprite.material.set_shader_param("scroll_spead", 0.4 * value)
	$ParallaxBackground/Ground/Sprite.material.set_shader_param("scroll_spead", 1 * value)
	speed = value
	
	
