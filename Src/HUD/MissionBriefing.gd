extends Control


const FUN_FACT_SIZE = 22


func setLevel(id):
	if id < 20: #Level amount
		if id == 0:
			print("Error!!!!!!!!!!!!!!!")
			print("setlevel: " + str(id))
		$BriefingLabel.bbcode_text = tr("MISSION_BRIEFING_LEVEL"+str(id))
	else:
		print("Briefing Text out of Range")
	
	#enum LevelTypes {USA, USSR, Ustria}
	if id == Types.LevelTypes.USSR:
		$MapSprite.frame = 0
		$CountryLabel.set_text(tr("NATION_USSR"))
	elif id == Types.LevelTypes.Ustria:
		$MapSprite.frame = 2
		$CountryLabel.set_text(tr("NATION_USTRIA"))
	elif id == Types.LevelTypes.Switzerland:
		$MapSprite.frame = 3
		$CountryLabel.set_text(tr("NATION_SWITZERLAND"))
	else: 
		$MapSprite.frame = 1
		$CountryLabel.set_text(tr("NATION_USA"))
	
	showMissionBriefing()


func showMissionBriefing():
	randomize()
	$FunFactLabel.bbcode_text = "                " + tr("FUNFACT" + str(randi() % FUN_FACT_SIZE))


