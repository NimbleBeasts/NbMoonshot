extends Node2D 

var isUsed = false

export(int) var keyPadCode = 0
export(Types.Minigames) var minigameType = Types.Minigames.Keypad
export(NodePath) var openTarget = null
export var showHintOnSucceed: bool = false
export var hint: String
export var hasBounty: bool = false

const lockpickSpawnerScript := preload("res://Src/Minigames/LockpickMinigame/LockpickMinigameSpawner.gd")
const keypadSpawnerScript := preload("res://Src/Minigames/KeypadMinigame/KeypadMinigameSpawner.gd")


func getProgessState():
	return isUsed
	

func _ready():
	match minigameType:
		Types.Minigames.Keypad:
			$MinigameSpawner.set_script(keypadSpawnerScript)
			$MinigameSpawner.lock_code = keyPadCode
		Types.Minigames.Lockpick:
			$MinigameSpawner.set_script(lockpickSpawnerScript)
		_:
			printerr("Warning! Tresor only supports the keypad and lockpick minigame atm, defaulting to keypad minigame.")
			$MinigameSpawner.set_script(keypadSpawnerScript)
			$MinigameSpawner.lock_code = keyPadCode
	$MinigameSpawner.connect("minigame_succeeded", self, "openTresor")
	

func openTresor():
	if isUsed:
		return
	
	$Sprite.frame = 1
	isUsed = true
	if Global.gameState.interactionCounters.boss == 0:
		Events.emit_signal("tutorial_finished")
		SteamWorks.setAchievement("STEAM_ACH_1")
	if showHintOnSucceed:
		Events.emit_signal("hud_game_hint", tr(hint))
	if openTarget:
		get_node(openTarget).open()
	if hasBounty:
		var loot = Global.gameConstant.basicLoot * 5
		if Global.playerHasUpgrade(Types.UpgradeTypes.DarkNet):
			loot *= Global.gameConstant.upgradeDarkNetModifier
		$Label.set_text("$"+str(loot))
		$LootAnim.play("loot")
		Global.addMoney(loot)

