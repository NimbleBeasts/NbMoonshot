tool
extends Node2D

enum CabinetType {Blue = 0, Grey = 1, Brown = 2} 

export(CabinetType) var type = CabinetType.Blue
export(bool) var hasBounty = false

var isUsed = false
var playerInRange = false
var loot = 0

func getProgessState():
	return isUsed

func _ready():
	$Sprite.frame = type
	
	if hasBounty:
		loot = Global.gameConstant.basicLoot
		if Global.playerHasUpgrade(Types.UpgradeTypes.DarkNet):
			loot *= Global.gameConstant.upgradeDarkNetModifier
		$Label.set_text("$"+str(loot))
		set_process(false)


func _process(_delta):
	if playerInRange:
		if Input.is_action_just_pressed("open_minigame"):
			if hasBounty and not isUsed:
				# Add money popup anim
				# Emit Hud money update
				isUsed = true
				$AnimationPlayer.play("loot")
				# Global.addMoney(loot)
				Global.game_manager.getCurrentLevel().gainedMoney += loot
				Events.emit_signal("hud_update_money", Global.game_manager.getCurrentLevel().gainedMoney, loot)
				Events.emit_signal("play_sound", "chest_bounty")
			else:
				Events.emit_signal("play_sound", "chest_locked")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerInRange = true
		set_process(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInRange = false
		set_process(false)
