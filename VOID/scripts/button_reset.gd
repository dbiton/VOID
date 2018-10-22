extends Button

onready var animation = get_parent().get_node("animation")
onready var fade = get_node("/root/root/canvas/fade")
onready var sprite = get_node("sprite")
onready var global = get_node("/root/root/")
onready var sprite_exit = preload("res://sprites/sprite_exit.png")
onready var sprite_reset = preload("res://sprites/sprite_reset.png")
var i = -1
#if player exists it resets, otherwise exit

func _pressed():
	if global.player_exists:
		get_tree().get_nodes_in_group("player")[0].queue_free()
		global.player_exists=false
	else:
		get_tree().quit()
	animation.play_backwards("pause")
	get_tree().paused=false

func _on_animation_animation_started(anim_name):
	if anim_name == "pause":
		i = i*-1
		if i == 1:
			if global.player_exists:
				sprite.set_texture(sprite_reset)
			else:
				sprite.set_texture(sprite_exit)
