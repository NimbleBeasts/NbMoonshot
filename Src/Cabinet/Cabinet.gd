tool
extends Node2D

enum CabinetType {Blue = 0, Grey = 1, Brown = 2} 

export(CabinetType) var type = CabinetType.Blue
export(bool) var hasBounty = false
export(bool) var isObjective = false
export(bool) var checkable = true

export(bool) var containsKey = false
export (Types.KeyColors) var keyColor: int

var isUsed = false
var playerInRange
var loot = 0
var isPickedUp: bool = false #Key pickup stuff
var stringName: String

func getProgessState():
	return isUsed

func _ready():
	if $Sprite.hframes > 1:
		$Sprite.frame = type
		# Ignore type for lockers, maybe I add some more locker types
	
	if hasBounty:
		loot = Global.gameConstant.basicLoot
		
		var hasDarkNet:bool = false
		for v in Global.gameState.playerUpgrades:
			if v == 5:
				hasDarkNet = true
	
		if hasDarkNet:
			loot *= Global.gameConstant.upgradeDarkNetModifier
		$Label.set_text("$"+str(loot))
		set_process(false)

	if containsKey:
		stringName = Types.KeyColors.keys()[keyColor]
		$Key/KeySprite.frame = keyColor
	


func _process(_delta):
	if playerInRange and playerInRange.state != Types.PlayerStates.DraggingGuard:
		if Input.is_action_just_pressed("open_minigame"):
			if not checkable:
				return
			if isObjective:
				isUsed = true
				Events.emit_signal("level_hint", tr("HUD_MISSION_COMPLETE"))
				$ChestSounds/HasBounty.play()
			elif (hasBounty and not isUsed):
				# Add money popup anim
				# Emit Hud money update
				isUsed = true
				$LootAnim.play("loot")
				Global.addMoney(loot)
				if get_node_or_null("ChestSounds/HasBounty") != null:
					$ChestSounds/HasBounty.play()
			elif (containsKey and not isPickedUp):
				isPickedUp = true
				$ChestSounds/KeyPickup.play()
				$KeyAnim.play("show")
			else:
				if get_node_or_null("ChestSounds/Locked") != null:
					$ChestSounds/Locked.play()
				else:
					print("Locker sound missing")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerInRange = body
		set_process(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInRange = null
		set_process(false)
