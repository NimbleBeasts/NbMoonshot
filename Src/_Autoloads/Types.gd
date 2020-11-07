extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 
enum LightLevels {Dark, BarelyVisible, FullLight}
enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
enum PlayerStates {Normal, WallDodge, Duck}
enum Minigames{Test, Keypad, WireCut}
enum MinigameResults{Failed, Succeeded, Doing}
enum DetectionLevels{Possible, Sure}
enum GuardStates {Wander, Suspect, PlayerDetected}
enum CameraStates {Normal, Suspect, PlayerDetected}
