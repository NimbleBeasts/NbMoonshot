extends "res://Src/Levels/BaseLevel.gd"


func _on_AchievementDetector_body_entered(body):
	if body.is_in_group("Player"):
		SteamWorks.setAchievement("STEAM_ACH_11")
