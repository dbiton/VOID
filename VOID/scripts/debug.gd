extends Node

var speed = 100

func _process(delta):
	set_global_position(get_global_position()+speed*Vector2(1,0)*delta)