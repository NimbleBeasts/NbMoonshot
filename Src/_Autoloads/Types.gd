extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 
enum LightLevels {Dark = 0, BarelyVisible = 1, FullLight = 2}
enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
enum PlayerStates {Normal, WallDodge, Duck}
enum Minigames{Test, Keypad, WireCut}
enum MinigameResults{Failed, Succeeded, Doing}
enum DetectionLevels{Possible, Sure}
enum GuardStates {Wander, Suspect, PlayerDetected, Stunned}
enum CameraStates {Normal, Suspect, PlayerDetected}
enum WireColors {Red, Purple,Green, Blue}
enum NotifierTypes{Exclamation, Question}
