#TODO: OPTIMIZE (WHAT IS THE FRAME RATE ON ANDROID?), FIX COLOR FADE EFFECT ON PLANETS WHEN THEY BECOME UNCOLONIZED, REMOVE MENU ANIMATION WHEN EXITING, BETTER DEFAULT COLORS EFFECT ON VOID AND BORDER EDGE? STUTTER, BUTTONS? GUI SHOULD LOOK BETTER? EXPLOSION SIZE SHOULD BE RELATIVE TO SIZE OF PLANET
extends Node

var player_exists = false

var array_planets = []

var distance_player = 0
var score = 0
var coins = 0

var spawn_margin = 100 #should be at least half the size of the sprite of generated object (so it wont pop in)

var m_min = 1
var m_max = 30
var v_min = 0
var v_max = 100
var distance_alert = 1200 #abo
var distance_survive = 1400

onready var sprite_background = get_node("background")
onready var button_pause = get_node("/root/root/canvas/button_pause")
onready var global = get_node("/root/root/")
onready var scene_planet = preload("res://prefabs/planet.tscn")
onready var label_score = get_node("/root/root/canvas/container_score/score")
onready var label_highscore = get_node("/root/root/canvas/container_highscore/highscore")
onready var camera = get_node("/root/root/camera")
var player 

var planet
var t_wait = 0.1
var t_elapsed = 0
var d_spawn = 600
var timer = 0

var distance_select_min = 100

var G = 4000

var default_screen_size = Vector2(1080,1920)

#[highscore,color_background,color_void,color_planet_uncolonized,color_planet_colonized,color_shuttle,color_trail]

var SAVE_ID_HIGHSCORE = 0
var SAVE_ID_COLOR_BACKGROUND = 1
var SAVE_ID_COLOR_VOID = 2
var SAVE_ID_COLOR_PLANET_UNCOLONIZED = 3
var SAVE_ID_COLOR_PLANET_COLONIZED = 4
var SAVE_ID_COLOR_SHUTTLE = 5
var SAVE_ID_COLOR_TRAIL = 6
var default_highscore = 0
var default_color_background = Color(0.5,0.5,0.5)
var default_color_void = Color(0,0,0)
var default_color_planet_uncolonized = Color(1,1,1)
var default_color_planet_colonized = Color(1,0,0)
var default_color_shuttle = Color(1,1,1)
var default_color_trail = Color(1,0,0)
var save_array = [default_highscore,default_color_background,default_color_void,default_color_planet_uncolonized,default_color_planet_colonized,default_color_shuttle,default_color_trail]

onready var colorpicker_background = get_node("/root/root/canvas/colorpicker_background")

var polycount = 64

func _input(event): #remove shrinking planets
	if event is InputEventMouseButton and event.is_pressed() and !player_exists and !button_pause.pressed:
		var array_planets = get_tree().get_nodes_in_group("planets")
		var distance_min = get_global_mouse_position().distance_to(array_planets[0].get_global_position())
		var index_distance_min = 0
		for i in range(1,array_planets.size()):
			var distance_planet = get_global_mouse_position().distance_to(array_planets[i].get_global_position())
			if distance_planet<distance_min:
				distance_min=distance_planet
				index_distance_min=i
		if distance_min<distance_select_min:
			player_exists=true
			array_planets[index_distance_min]._select(event)

func _reset_score():
	score=0
	label_score.set_text(str(score))

func _ready():
	sprite_background.set_scale(Vector2(2,2)*distance_survive/sprite_background.texture.get_size()[0])
	print(sprite_background.scale)
	sprite_background.set_modulate(Color(save_array[SAVE_ID_COLOR_BACKGROUND]))
	get_node("/root/root/canvas/colorpicker_background").set_pick_color(save_array[SAVE_ID_COLOR_BACKGROUND])
	get_node("/root/root/canvas/colorpicker_planets_uncolonized").set_pick_color(save_array[SAVE_ID_COLOR_PLANET_UNCOLONIZED])
	get_node("/root/root/canvas/colorpicker_planets_colonized").set_pick_color(save_array[SAVE_ID_COLOR_PLANET_COLONIZED])
	get_node("/root/root/canvas/colorpicker_shuttle").set_pick_color(save_array[SAVE_ID_COLOR_SHUTTLE])
	get_node("/root/root/canvas/colorpicker_trail").set_pick_color(save_array[SAVE_ID_COLOR_TRAIL])
	get_node("/root/root/canvas/colorpicker_void").set_pick_color(save_array[SAVE_ID_COLOR_VOID])
	label_highscore.set_text(str(save_array[SAVE_ID_HIGHSCORE]))
	#set_process_input(false)#delete

func _enter_tree():
	_load_game()
	
func _add_score():
	score+=1
	if score>save_array[SAVE_ID_HIGHSCORE]:
		save_array[SAVE_ID_HIGHSCORE]+=1
		_save_game()
		label_highscore.set_text(str(save_array[SAVE_ID_HIGHSCORE]))
	label_score.set_text(str(score))

func _translate_units(x_val,x_min,x_max,y_min,y_max):
	return y_min+((x_val-x_min)*(y_max-y_min))/(x_max-x_min)

func _process(delta):
	
	if !get_tree().get_nodes_in_group("player").empty():
		player = get_tree().get_nodes_in_group("player")[0]
		distance_player = sqrt(player.get_position().x*player.get_position().x+player.get_position().y*player.get_position().y)
		if distance_player>distance_survive:
			player._die()
	else:
		distance_player=0
	t_elapsed += delta
	if t_elapsed >= t_wait:
		t_elapsed = 0
		planet = scene_planet.instance()
		add_child(planet)
		planet.set("velocity",Vector2(rand_range(v_min,v_max),rand_range(v_min,v_max)))
		var view_dimensions = get_viewport().size*get_node("/root/root/camera").zoom[0]
		var position_random
		var rand_y
		var rand_x
		if rand_range(-1,1)>0:
			if rand_range(-1,1)>0:
				rand_x=-spawn_margin
			else:
				rand_x=view_dimensions.x+spawn_margin
			rand_y = rand_range(0,view_dimensions.y)
		else:
			if rand_range(-1,1)>0:
				rand_y=-spawn_margin
			else:
				rand_y=view_dimensions.y+spawn_margin
			rand_x = rand_range(0,view_dimensions.x)
		if player_exists:
			position_random = player.get_global_position()+Vector2(rand_x,rand_y)-view_dimensions/2
		else:
			position_random = Vector2(rand_x,rand_y)-view_dimensions/2
		planet.set_global_position(position_random)

func _save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	for i in range (save_array.size()):
		save_game.store_line(str(save_array[i]))
	save_game.close()

func _load_game():
	var save_game = File.new()
	if save_game.file_exists("user://savegame.save"):
		save_game.open("user://savegame.save", File.READ)
		for i in range (save_array.size()):
			if i==0:
				save_array[i] = int(save_game.get_line())
			else:
				save_array[i] = _string_to_color(save_game.get_line())
	else:
		_save_game()

func _string_to_color(var string):
	var array_color = ["","","",""]
	var index_color = 0
	for i in range (string.length()):
		if string[i] == ",":
			index_color += 1
		else:
			array_color[index_color] = array_color[index_color]+string[i]
	return Color(array_color[0],array_color[1],array_color[2],array_color[3])

func _on_colorpicker_background_color_changed(color):
	save_array[SAVE_ID_COLOR_BACKGROUND] = color
	sprite_background.set_modulate(Color(save_array[SAVE_ID_COLOR_BACKGROUND]))

func _on_colorpicker_void_color_changed(color):
	save_array[SAVE_ID_COLOR_VOID] = color
	get_node("void/sprite").set_modulate(color)

func _on_colorpicker_trail_color_changed(color):
	save_array[SAVE_ID_COLOR_TRAIL] = color
	get_node("/root/root/trail").gradient.colors[1] = color
	get_node("/root/root/trail").gradient.colors[0] = Color(color[0],color[1],color[2],0)

func _on_colorpicker_shuttle_color_changed(color):
	save_array[SAVE_ID_COLOR_SHUTTLE] = color
	if has_node("shuttle"):
		get_node("shuttle").set_modulate(color)

func _on_colorpicker_planets_colonized_color_changed(color):
	save_array[SAVE_ID_COLOR_PLANET_COLONIZED] = color
	for i in range (array_planets.size()):
		if array_planets[i].is_in_group("player"):
			array_planets[i].set_modulate(color) #modulates current color instead of changing it
		array_planets[i].color_planet_colonized = color

func _on_colorpicker_planets_uncolonized_color_changed(color):
	save_array[SAVE_ID_COLOR_PLANET_UNCOLONIZED] = color
	for i in range (array_planets.size()):
		if !array_planets[i].is_in_group("player"):
			array_planets[i].set_modulate(color)
		array_planets[i].color_planet_uncolonized = color

func _on_colorpicker_planets_uncolonized_button_down():
	array_planets = get_tree().get_nodes_in_group("planets")


func _on_colorpicker_planets_colonized_button_down():
	array_planets = get_tree().get_nodes_in_group("planets")
