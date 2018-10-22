extends Button

onready var animation = get_parent().get_node("animation")
onready var global = get_node("/root/root")

var customizing = false

func _pressed():
	if customizing:
		customizing = false
		animation.play_backwards("customize")
		
		global._save_game()
	else:
		customizing = true
		animation.play("customize")
