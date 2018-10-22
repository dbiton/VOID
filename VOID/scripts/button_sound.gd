extends Button

onready var sprite_mute=preload("res://sprites/sprite_mute.png")
onready var sprite_sound=preload("res://sprites/sprite_sound.png")
var muted = false

func _pressed():
	if muted:
		get_node("sprite").texture = sprite_sound
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
		muted = false
	else:
		get_node("sprite").texture = sprite_mute
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)
		muted = true