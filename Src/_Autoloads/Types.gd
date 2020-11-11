extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 

# Player
enum LightLevels {Dark = 0, BarelyVisible = 1, FullLight = 2}
enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
enum PlayerStates {Normal, WallDodge, Duck}
enum DetectionLevels{Possible, Sure}
enum UpgradeTypes {Taser_Extended_Battery, Taser_Voltage, False_Alarm, Fitness_Level2, Sneak, DarkNet, Lockpick_Level2, Distraction}

# Minigames
enum Minigames{Test, Keypad, WireCut}
enum MinigameResults{Failed, Succeeded, Doing}

# Objects
enum GuardStates {Wander, Suspect, PlayerDetected, Stunned}
enum CameraStates {Normal, Suspect, PlayerDetected}
enum WireColors {Red, Purple,Green, Blue}
enum NotifierTypes{Exclamation, Question}
enum NoteType {SecretService, Local}
