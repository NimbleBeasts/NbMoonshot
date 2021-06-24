extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 

# Steam
enum Achievement {Test = 0}
var AchievementStrings = ["ACH_BETA_TEST"]

# HUD
enum HudNotificationType {BuyZone, SaveZone, OpenDoor, Interact}

# Music
enum MusicType {
	DefaultLevelType = -1,
	westernMusic = 0,
	easternMusic = 1,
	hqIntro,
	hqMusic,
	menuIntro,
	menuMusic,
	hq_full,
	surfin_ussr,
	rocket,
	russia_win,
	titleFull,
	bank,
}


# Player
enum LightLevels {EvenDarker = 0, Dark = 1, BarelyVisible = 2, FullLight = 3}
enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
enum PlayerStates {Normal, WallDodge, Duck, DraggingGuard, InCloset, DraggingItem}
enum DetectionLevels{Possible, Sure}
enum UpgradeTypes {Taser_Extended_Battery, Dog_Whisperer, False_Alarm, Fitness_Level2, Sneak, DarkNet, Lockpick_Level2, Distraction}

# Minigames
enum Minigames{Test, Keypad, WireCut, Lockpick, Photo, Cryptogram}
enum MinigameResults{Failed, Succeeded, Doing}
enum DoorLockType {open = 0, lockedLevel1 = 1, lockedLevel2 = 2, locked = 3, buttonLocked = 4, keyLocked = 5}

# Guards
enum GuardStates {Idle, Wander, Suspect, PlayerDetected, Stunned, BeingDragged}
enum EliteGuardStates {Roaming, MovingToPlayer, Suspicious, TaseringPlayer}

# Civilians
enum CivilianStates {Normal, Stunned, BeingDragged, Kneeling}

# Objects
enum CameraStates {Normal, Suspect, PlayerDetected, Rotating, Frozen}
enum NotifierTypes{Exclamation, Question}
enum NoteType {SecretService, Local}

# Levels
enum LevelTypes {USA = 0, USSR = 1, Ustria = 2, Switzerland}
enum LevelLightning {Dusk, Night, Dawn}


# Dialog
enum DialogButtons {Option0 = 0, Option1 = 1, Option2 = 2, NoBranch = 3}

# Dog
enum DogStates {Idle, Roaming, Sleeping, Suspicious, Detection, Eating, Stunned, Angry, MovingToSnack}

# Potraits
enum Potraits {Player, Boss, Secretary, Bot}

# Weapons
enum Weapons {Taser = 0, StoneThrower = 1, SnackThrower = 2}

# Keys
enum KeyColors {Red = 0, Blue = 1, Yellow = 2}

#Minigames 
enum WireColors {Red, Purple,Green, Blue}
enum SimonSaysColors {Red, Blue, Yellow, Green}

enum Countries {ussr, usa}
