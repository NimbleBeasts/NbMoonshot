extends Node

export var guardPath: NodePath
onready var guard = get_node(guardPath)


func onGuardLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Civilian"):
		if body.state == Types.CivilianStates.Kneeling or body.state == Types.CivilianStates.Stunned:
			guard.set_state(Types.GuardStates.PlayerDetected)
