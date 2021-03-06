# How to

Please do not modify this file. Task tracking is done in:
https://github.com/NimbleBeasts/NbGameOff2020/projects/3

Pick your task, enter your name and move it to "In progress". In this file you find a description of what to do in this task. Not all tasks are immediately listed on the board. They maybe less important, not finalized or require other task to be complete before. If your task is ready, check linter, commit and move the task to review tab.

# Active Work Tasks

## WP-12 Fake Gravity

To enable some more cool features we need some sort of fake gravity on items, stunned guards and the player

- Add Raycast2D for the player (guess we need 2 so the player can stay on edges)
- Add gravity to the player if the non of the raycasts detect ground
- Add Raycast2D for stunned guards and gravity so the player can throw them from a building
- Add Raycast2D for items so the player can throw them from a building

## WP-13 Distraction Feature

Add a distraction feature which result in changing the guards routes

- Guards shall support multiple path routes (e.g. first child is normal patrolling, second is special or special routes are marked with a boolean)
- Guards shall provide a switch function which will be called from the distraction node
- Distraction nodes shall export a array of node paths
- If a guards switch function is activated, he will leave the default route and follow the special route
- At the end of the special route he shall wait a specific amount of time and return to point 0 to fall back to normal route
- Distraction nodes shall be activated by the player by pressing "E"
- Distraction nodes shall behave like a note (highlighting and !)

## WP-8 Multi Language Support

- Add Multi Language Support
- Add mechanism for Notes
- Add mechanism for dialogues
- Add mechanism for safe code. The code shall be random 2 digit wise like 4242 or 6565 generated on level ready. The code must be assigned on safe as well as on the note

# Backlog

## WP-9 Doors and Keys

Adapt Door Levels:

- Locked: Locked for ever cant be opened
- minigameLevel1 = lockedLevel1
- minigameLevel2 = lockedLevel2 (harder)
- buttonLocked
- keyLocked

Pickupable Key:
Keys can have 3 colors. Signs over the door will show required key color. When the player walks over the key it will be picked up. The node will be hidden. When the player wants to open the door, the assigned key node path will be checked if the key was picked up.
Only the key will hold the color information: Red, Blue or Yellow
Sprite: Doors/Keys.png

Button Locked:
The door will be opened from another node. No adaption needed on door node.

Minigames:

- LockPicking lite for wooden doors
- Connect 5 for metal doors. (we need an easier version of that for L1 doors)

## WP-11 Simon Says Game for Metal Doors Level 1

- Could be like original simon says 4 fields or more
- I was thinking about creating some hardware platine look a like thing (like arduino simon says implementations)
- It plays a random sequence of 4-6 (also random) colors (blue, red, green, yellow)
- Player has to repeat this sequence in the right order to unlock the door

## WP-10 Civilians

- Implement according to GDD
- Have 4 dummy animations: idle, walk, kneeDown, knee_idle

## WP-3 Mission Progress Screen

- Implement the mission progress screen as described
- TODO: curve has to be defined

# Closed

## WP-1 Controls

- Implement new control scheme
- Implement ability to switch weapons (so, that WP-2 can be done)
- Implement holding mechanism for camera movement (movement itself has not to be included now)
- Implement picking up body (no anim yet, just stick the guard to the player for now)
- Implement laying down body

## WP-4 Moveable Camera

- Implement as described

Requires: WP-1

## WP-5 Dog

- Implement Dog as described

## WP-6 Guard

- Check and implement whats not in

## WP-7 Elite Guard

- Implement Elite Guard as described

## WP-2 Stone & Meat Throw

- Implement stone throw meachnism
- Implement drawing predicted flying curve (guess line2d)
- Hitting the floor will result in a "sound" which shall distract the guards
- Guard distraction shall be adapted if not working correctly
- Dogs are unaffected by stones, but react to meat

Requires: WP-1, WP-5, WP-6
