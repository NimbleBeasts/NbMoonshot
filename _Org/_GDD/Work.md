# How to

Please do not modify this file. Task tracking is done in:
https://github.com/NimbleBeasts/NbGameOff2020/projects/3

Pick your task, enter your name and move it to "In progress". In this file you find a description of what to do in this task. Not all tasks are immediately listed on the board. They maybe less important, not finalized or require other task to be complete before. If your task is ready, check linter, commit and move the task to review tab.

# Active Work Tasks

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

## WP-8 Multi Language Support

- Add Multi Language Support
- Add mechanism for Notes
- Add mechanism for dialogues
- Add mechanism for safe code. The code shall be random 2 digit wise like 4242 or 6565 generated on level ready. The code must be assigned on safe as well as on the note

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

# Backlog

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
