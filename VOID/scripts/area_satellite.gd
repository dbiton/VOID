extends Area2D

var volume = 0

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and !get_node("/root/root/").player_exists:
		var global = get_node("/root/root/")
		var sound_player = get_node("/root/root/sound_player")
		var sfx_hi_hat = preload("res://sounds/sound_hi_hat.wav")
		sound_player.set_volume_db(volume)
		sound_player.set_stream(sfx_hi_hat)
		sound_player.play()
		global.player_exists = true
		get_parent()._colonize()
		get_parent()._stroke(event)
