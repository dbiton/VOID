extends KinematicBody2D

onready var void = get_node("/root/root/void")
onready var camera = get_node("/root/root/camera")
onready var global = get_node("/root/root/")
onready var G = get_node("/root/root/").G
onready var sound_sampler = get_node("/root/root/sound_player")

onready var color_shuttle = global.save_array[global.SAVE_ID_COLOR_SHUTTLE]

var radius = 10
var mass = 100

var distance_void
var origin
var velocity
var delta_v
var mass_void
var coe_amp = 0.02
var coe_dur = 0.0007
var volume_min = -30
var volume_max = 0
var speed_volume_max = 500 #above this speed, snare sfx will not be louder

func _ready():
	set_modulate(color_shuttle)

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)

func _die():
	global._reset_score()
	global.player_exists = false 
	queue_free()

func _physics_process(delta):
	var vect = void.get_global_position()-get_global_position()
	var dir = vect.normalized()
	var distance = sqrt(vect.x*vect.x+vect.y*vect.y)
	delta_v = (dir*mass*G)/(distance*distance)
	velocity += delta_v
	var move = move_and_collide(velocity*delta)
	if  move != null:
		if move.collider.is_in_group("planets") and move.collider != origin:
			global._add_score()
			var speed = sqrt(pow(velocity.x,2)+pow(velocity.y,2))
			camera._shake(speed*coe_amp,speed*coe_dur)
			get_node("/root/root/trail")._reset_trail()
			move.collider._colonize()
			sound_sampler.set_volume_db(_translate_units(speed,0,speed_volume_max,volume_min,volume_max))
			sound_sampler.set_stream(move.collider.sfx_snare)
			sound_sampler.play()
			free()
		elif move.collider.get_name() == "void":
			sound_sampler.set_volume_db(void.volume_tom)
			sound_sampler.set_stream(void.sfx_tom)
			sound_sampler.play()
			_die()

