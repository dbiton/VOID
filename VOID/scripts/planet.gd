#very low performance on android for some reason
extends KinematicBody2D

onready var sfx_kick = preload("res://sounds/sound_kick.wav")
onready var sfx_snare = preload("res://sounds/sound_snare.wav")
onready var sfx_hi_hat = preload("res://sounds/sound_hi_hat.wav")
onready var sfx_cymbal = preload("res://sounds/sound_cymbal.wav")
onready var scene_shuttle = preload("res://prefabs/shuttle.tscn")
onready var scene_explosion = preload("res://prefabs/explosion.tscn")
onready var sprite_crosshair = preload("res://sprites/sprite_triangle.png")

onready var sprite = get_node("sprite")
onready var collision_shape = get_node("collision")
onready var collision_shape_area = get_node("area/collision")
onready var camera = get_node("/root/root/camera")
onready var sound_player = get_node("/root/root/sound_player")
onready var global = get_node("/root/root/")
onready var void = get_node("/root/root/void")

onready var mass_void = void.mass
onready var G = global.G

var velocity = Vector2(0,0)
var colonized = false

var d_stroke
var stroke_held = false 
var d_min = 20 #dragging for below this distance will not launch a shuttle
var d_max = 200 #dragging above this distance will not make the shuttle faster
var v_min = 100
var v_max = 500
var dir
var v
var pos0 = 0
var crosshair
var crshr_r_max = 1
var crshr_r_min = 0.1
var crshr_d_max = 200
var crshr_d_min = 10
var crshr_d
var crshr_r
var crshr_angle = 0
var crshr_scale_coe = 0.05

var volume_kick = 0
var volume_hi_hat = 0
var volume_max = 0
var volume_min = -30

var oscillate_coe = 15 #the larger this is, the less the void oscillates when a planet hits it (affected by mass)

var time_shrink = 0.25 #time it takes in seconds after colliding with another planet to shring and dissapear
var timer_shrink = 0
var shrinking = false

var planet_polycount = 6
var planet_radius_min = 16
var planet_radius_max = 32
onready var color_planet_colonized = global.save_array[global.SAVE_ID_COLOR_PLANET_COLONIZED]
onready var color_planet_uncolonized = global.save_array[global.SAVE_ID_COLOR_PLANET_UNCOLONIZED]
var time_color_uncolonize = 0.5 #the time in seconds it takes for a planet to change it's color after the player leaves it
var timer_color_uncolonize = 0
onready var color_planet = global.save_array[global.SAVE_ID_COLOR_PLANET_UNCOLONIZED]
onready var radius = rand_range(planet_radius_min,planet_radius_max)
onready var array_polygon = _generate_circle(radius,planet_polycount)#

func _select(var event):
	sound_player.set_volume_db(volume_hi_hat)
	sound_player.set_stream(sfx_hi_hat)
	sound_player.play()
	_colonize()
	_stroke(event)

func _ready():
	add_to_group("planets")
	set_modulate(global.save_array[global.SAVE_ID_COLOR_PLANET_UNCOLONIZED])
	sprite.set_scale(Vector2(1,1)*radius/50)
	set_process_input(false) #enable on impact with shuttle and with first planet
	collision_shape.polygon = array_polygon
	collision_shape_area.polygon = _generate_circle(2*radius,planet_polycount)#change with planet_radius+shuttle_radius+small val

func _process(delta):
	if stroke_held:
		var d = _translate_units(d_stroke,d_min,d_max,crshr_d_min,crshr_d_max)
		var r = _translate_units(d_stroke,d_min,d_max,crshr_r_min,crshr_r_max)
		crosshair.set_position(d*dir)
		crosshair.set_scale(Vector2(1,1)*r*crshr_scale_coe)
		crosshair.set_rotation(crshr_angle)
	if !colonized and color_planet!=color_planet_uncolonized:#remove and false
		if timer_color_uncolonize>0:
			timer_color_uncolonize-=delta
			if color_planet_uncolonized.r<color_planet_colonized.r:
				color_planet.r = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_uncolonized.r,color_planet_colonized.r)
			else:
				color_planet.r = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_colonized.r,color_planet_uncolonized.r)
			if color_planet_uncolonized.g<color_planet_colonized.g:
				color_planet.g = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_uncolonized.g,color_planet_colonized.g)
			else:
				color_planet.g = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_colonized.g,color_planet_uncolonized.g)
			if color_planet_uncolonized.r<color_planet_colonized.r:
				color_planet.b = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_uncolonized.b,color_planet_colonized.b)
			else:
				color_planet.b = _translate_units(time_color_uncolonize-timer_color_uncolonize,0,time_color_uncolonize,color_planet_colonized.b,color_planet_uncolonized.b)
		else:
			color_planet = color_planet_uncolonized
		sprite.set_modulate(color_planet)

func _physics_process(delta):
	
	var vect = void.get_global_position()-get_global_position()
	var direction = vect.normalized()
	var distance = sqrt(vect.x*vect.x+vect.y*vect.y)
	var velocity_delta = (direction*mass_void*G)/(distance*distance)
	velocity += velocity_delta
	var move = move_and_collide(velocity*delta)
	if  move != null:
		if move.collider.name == "void":
			move.collider._oscillate(radius/oscillate_coe)#
			if colonized:
				sound_player.set_volume_db(void.volume_tom)
				sound_player.set_stream(void.sfx_tom)
				sound_player.play()
				get_node("/root/root/trail")._reset_trail()
				global._reset_score()
				global.player_exists = false
				free()
			else:
				free()
		elif move.collider.is_in_group("planets"):
			var colliding_planet = move.collider
			if colonized or colliding_planet.colonized:
				sound_player.set_volume_db(volume_kick)
				sound_player.set_stream(sfx_kick)
				sound_player.play()
				_die()
			var explosion = scene_explosion.instance()
			get_parent().add_child(explosion)
			explosion.set_global_position(get_global_position())
			queue_free()
			colliding_planet.queue_free()

func _input(event):
	if event.is_action_pressed("click"):
		_stroke(event)
	elif event.is_action_released("click") and stroke_held:
		stroke_held = false
		crosshair.free()
		if d_stroke>d_min:
			colonized = false
			set_collision_layer_bit(1,false)
			set_collision_mask_bit(1,false)
			if d_stroke<d_max:
				v = _translate_units(d_stroke,d_min,d_max,v_min,v_max)
			else:
				v = v_max
			var shuttle = scene_shuttle.instance()
			get_parent().add_child(shuttle)
			shuttle.set_global_position(get_global_position())
			shuttle.set("velocity",Vector2(dir*v))
			shuttle.set("origin",self)
			shuttle.add_to_group("player")
			get_node("/root/root/trail")._reset_trail()
			_uncolonize()
			var volume = _translate_units(d_stroke,d_min,d_max,volume_min,volume_max)
			sound_player.set_volume_db(volume)
			sound_player.set_stream(sfx_cymbal)
			sound_player.play()
	if  event is InputEventMouseMotion and stroke_held:
		d_stroke = pos0.distance_to(event.position)
		if d_stroke>d_max:
			d_stroke=d_max
		if d_stroke<d_min:
			d_stroke=d_min
		crshr_angle = pos0.angle_to_point(event.position)
		dir = (pos0-event.position).normalized()

func _colonize():
	add_to_group("player")
	colonized = true
	set_process_input(true)
	color_planet_colonized = global.save_array[global.SAVE_ID_COLOR_PLANET_COLONIZED]
	color_planet=color_planet_colonized
	sprite.set_modulate(color_planet)

func _uncolonize():
	remove_from_group("player")
	colonized = false
	set_process_input(false)
	timer_color_uncolonize=time_color_uncolonize

func _die():
	get_node("/root/root/trail")._reset_trail()
	global._reset_score()
	global.player_exists = false
	shrinking = true

func _disable_collision():
	set_collision_layer_bit(1,false)
	set_collision_mask_bit(1,false)
	set_collision_layer_bit(2,false)
	set_collision_mask_bit(2,false)

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)

func _stroke(var event):
	d_stroke=0
	dir = Vector2(0,0)
	stroke_held = true
	pos0 = event.position
	crosshair = Sprite.new()
	add_child(crosshair)
	crosshair.texture = sprite_crosshair

func _generate_circle(var radius,var polygon_count):
	var i = 1
	var polygon_array = []
	while i<=polygon_count:
		var angle_point = i*2*PI/polygon_count
		polygon_array.push_back(Vector2(cos(angle_point),sin(angle_point))*radius)
		i+=1
	return polygon_array

#func _draw():
#	var polygon = draw_polygon(array_polygon,PoolColorArray([color_planet]))

func _on_area_body_shape_exited(body_id, body, body_shape, area_shape):
	if body != null:
		if body.get_name() == "shuttle":
			set_collision_layer_bit(1,true)
			set_collision_mask_bit(1,true)
