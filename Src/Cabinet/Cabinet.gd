tool
extends Node2D

enum CabinetType {Blue = 0, Grey = 1, Brown = 2} 

export(CabinetType) var type = CabinetType.Blue
export(bool) var hasBounty = false

var isLooted = false
var playerInRange = false
var loot = 0

func _ready():
	$Sprite.frame = type
	
	if not hasBounty:
		print("no bounty")
		if not Engine.editor_hint:
			self.remove_child($Area2D)
	else:
		loot = Global.gameConstant.basicLoot
		if Global.playerHasUpgrade(Types.UpgradeTypes.DarkNet):
			loot *= Global.gameConstant.upgradeDarkNetModifier
		$Label.set_text("$"+str(loot))

func _process(delta):
	if playerInRange:
		if Input.is_action_just_pressed("open_minigame"):
			print("bounty")
			if hasBounty and not isLooted:
				# Add money popup anim
				# Emit Hud money update
				isLooted = true
				$AnimationPlayer.play("loot")
				Global.addMoney(loot)
				print("looted")
				pass
			else:
				print("no loot")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerInRange = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInRange = false
