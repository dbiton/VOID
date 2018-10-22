extends Node2D

onready var global = get_node("/root/root/")

var alpha = 1
var time_fade_in = 1
var timer_fade_in = 0

onready var rect_width = get_viewport().size[1]
onready var rect_height = get_viewport().size[0]

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)
	
func _process(delta):
	if global.distance_player>global.distance_alert:
		alpha = global._translate_units(global.distance_player,global.distance_alert,global.distance_survive,0,1)
		update()
	if !global.player_exists and alpha!=0:
		timer_fade_in+=delta
		alpha = _translate_units(time_fade_in-timer_fade_in,0,time_fade_in,0,1)
		if alpha<=0:
			alpha = 0
			timer_fade_in=0
		update()

func _draw():
	draw_rect(Rect2(0,0,rect_width,rect_height),Color(0,0,0,alpha))
