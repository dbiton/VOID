extends Camera2D

var player
var player_existed_last_frame
var smoothing_factor = 1
var zoom_min = 0.2
var zoom_max = 2
var zoom_default = 1
var time_reset_zoom = 0.5
var timer_reset_zoom = 0
var distance_zoom_min =0
var shake_amount = 2
var shaking
var timer_shake
var zoom_initial = zoom_default
var zoom_current
var zoom_delta
onready var distance_zoom_max = get_node("/root/root/").distance_survive
onready var global = get_node("/root/root/")

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)

func _shake(var amplidtude,var duration):
	shaking = true
	timer_shake=duration

func _physics_process(delta):
	if shaking:
		timer_shake-=delta
		set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount ))
		if timer_shake<=0:
			timer_shake = 0
			shaking=false
	if global.player_exists:
		player_existed_last_frame=true
		var position_player = get_tree().get_nodes_in_group("player")[0].get_global_position()
		var distance_void = sqrt(position_player.x*position_player.x+position_player.y*position_player.y)
		var zoom_cur = _translate_units(distance_void,distance_zoom_min,distance_zoom_max,zoom_min,zoom_max)
		zoom = Vector2(1,1)*zoom_cur
		set_global_position(position_player)
	else:
		if zoom[0]!=zoom_default:
			if player_existed_last_frame:
				if zoom[0]>zoom_default:
					zoom_initial = zoom[0]
				elif zoom[0] <zoom_default:
					zoom_initial = zoom[0]
				zoom_current = zoom_initial
				zoom_delta=zoom_initial-zoom_default
			timer_reset_zoom+=delta
			if zoom[0]>zoom_default:
				zoom_current = _translate_units(timer_reset_zoom-time_reset_zoom,0,time_reset_zoom,zoom_initial,zoom_default)
				if zoom_current<zoom_default:
					zoom_current=zoom_default
					timer_reset_zoom=0
			elif zoom[0]<zoom_default:
				#var smoothing = zoom_delta*smoothing_factor*sin(PI+timer_reset_zoom*PI/time_reset_zoom)
				zoom_current = _translate_units(timer_reset_zoom,0,time_reset_zoom,zoom_initial,zoom_default)
				if zoom_current>zoom_default:
					zoom_current=zoom_default
					timer_reset_zoom=0
			zoom = Vector2(1,1)*zoom_current
		
		set_global_position(Vector2(0,0))
		player_existed_last_frame=false
