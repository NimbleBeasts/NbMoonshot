extends Node2D

signal invoked(type, pos)

export var audio_listener_x_size: int = 72
const audio_listener_y_size = 24

onready var self_parent = get_parent()

func _ready():
	Events.connect("audio_level_changed", self, "check_audio_source")

func check_audio_source(audio_level: int, audio_pos: Vector2, _emitter) -> void:
	var pos = global_position

	#Check if inside the audio boundaries
	if pos.y - audio_listener_y_size <= audio_pos.y and audio_pos.y < pos.y + audio_listener_y_size:

		if pos.x - audio_listener_x_size <= audio_pos.x and audio_pos.x < pos.x + audio_listener_x_size:
			#Raycast for walls
			var space_state = get_world_2d().direct_space_state
			pos.y -= 24
			var result = space_state.intersect_ray(pos, audio_pos, [self_parent])
			
			if result:
				#enum AudioLevels {LoudNoise = 0, SmallNoise = 1, Silent = 2}
				audio_level += 1
			
			if audio_level < 2:
				emit_signal("invoked", audio_level, audio_pos)

