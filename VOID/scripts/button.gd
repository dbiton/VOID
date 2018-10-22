extends Button

onready var animation = get_parent().get_node("animation")
onready var fade = get_node("/root/root/canvas/fade")

var alpha_min = 0.5 #if alpha larger than this, the button is not clickable (%darkness)

func _pressed():
	if fade.alpha<alpha_min:
		if get_tree().paused == false:
			animation.play("pause")
			get_tree().paused=true
		elif get_tree().paused == true:
			animation.play_backwards("pause")
			get_tree().paused=false
