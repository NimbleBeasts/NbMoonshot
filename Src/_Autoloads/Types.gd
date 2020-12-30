extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 

# Steam
enum Achievement {Test = 0}
var AchievementStrings = ["ACH_BETA_TEST"]

# HUD
enum HudNotificationType {BuyZone, SaveZone, OpenDoor, Interact}

# Player
enum LightLevels {Dark = 0, BarelyVisible = 1, FullLight = 2}
enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
enum PlayerStates {Normal, WallDodge, Duck, DraggingGuard, InCloset, DraggingItem}
enum DetectionLevels{Possible, Sure}
enum UpgradeTypes {Taser_Extended_Battery, Taser_Voltage, False_Alarm, Fitness_Level2, Sneak, DarkNet, Lockpick_Level2, Distraction}

# Minigames
enum Minigames{Test, Keypad, WireCut, Lockpick, Photo}
enum MinigameResults{Failed, Succeeded, Doing}

# Objects
enum GuardStates {Wander, Suspect, PlayerDetected, Stunned, BeingDragged}
enum EliteGuardStates {Roaming, MovingToPlayer, Suspicious, TaseringPlayer}
enum CameraStates {Normal, Suspect, PlayerDetected, Rotating, Frozen}
enum WireColors {Red, Purple,Green, Blue}
enum NotifierTypes{Exclamation, Question}
enum NoteType {SecretService, Local}

# Levels
enum LevelTypes {Western, Eastern}
enum Nations {USA, USSR, Ustria}

# Dialog
enum DialogButtons {Option0 = 0, Option1 = 1, Option2 = 2, NoBranch = 3}

# Dog
enum DogStates {Idle, Roaming, Sleeping, Suspicious, Detection, Eating, Stunned, Angry, MovingToSnack}

# Potraits
enum Potraits {Player, Boss, Secretary}

# Weapons
enum Weapons {Taser = 0, StoneThrower = 1, SnackThrower = 2}

# Keys
enum KeyColors {Red, Blue, Yellow}
