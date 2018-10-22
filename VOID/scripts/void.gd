#todo lose screen - black hole expanding and filling entire screen
extends Node2D

var t = 0
var theta = 1
var amplitude_decay = 0.1

var volume_tom=0

onready var sound_player = get_node("/root/root/sound_player")
onready var sfx_tom = preload("res://sounds/sound_tom.wav")
onready var camera = get_node("/root/root/camera")
var functions = PoolVector2Array()
var size_stable = 1
var i =0
var y = 0
var prev_y = 0

onready var zoom_camera_max = camera.zoom_max
onready var zoom_camera_min = camera.zoom_min 
var volume_max = 0
var volume_min = -80
var volume
var mass = 50

func _oscillate(var amplitude):
	functions.push_back(Vector2(amplitude,0))
	set_process(true)

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)

func _process(delta):
	#volume = _translate_units(zoom_camera_max-camera.zoom[0],zoom_camera_min,zoom_camera_max,volume_min,volume_max)
	#sound_player.set_volume_db(volume)
	
	y=0
	while i < functions.size():
		var amplitude = functions[i][0]
		functions[i][1]+=delta
		y += amplitude*sin(theta*functions[i][1])
		functions[i][0] = amplitude-amplitude_decay
		if functions[i][0]<0:
			functions.remove(i)
			if functions.size() == 0:
				set_process(false)
		i+=1
		prev_y = y
	i=0
	set_scale(Vector2(1,1)*(size_stable+y))