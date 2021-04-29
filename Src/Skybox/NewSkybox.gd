tool
extends Node2D

#enum Nations {USA, USSR, Ustria}

const baseDirectory = "res://Assets/Skyboxes/"
const pathNames = ["CityBlueish", "CityRedish", "UstriaSkybox"]

func _ready():
	setup(get_parent().level_nation_type)
	Events.connect("hud_light_level", self, "setLightLevel")

func setup(level_type):
	var basePath = baseDirectory
	
	if level_type == 3:
		#Switzerland is like Ustria
		level_type = 2
	basePath += pathNames[level_type]

	$FixedBackground/Sky.texture = load(basePath + "_BG.png")
	$ParallaxBackground/L1/Sprite.texture = load(basePath + "_L1.png")
	$ParallaxBackground/L2/Sprite.texture = load(basePath + "_L2.png")
	$ParallaxBackground/L3/Sprite.texture = load(basePath + "_L3.png")

func setLightLevel(level):
	var color = Global.gameConstant.lightLevels[level]
	#$FixedBackground/CanvasModulate.color = color
	$ParallaxBackground/CanvasModulate.color = color
