extends Line2D

var player
var width_trail 
var length_trail = 50

func _reset_trail():
	while get_point_count()>0:
			remove_point(0)

func _physics_process(delta):
	if get_node("/root/root/").player_exists:
		width = 2*get_tree().get_nodes_in_group("player")[0].radius
		add_point(get_tree().get_nodes_in_group("player")[0].get_global_position())
		while get_point_count()>length_trail:
			remove_point(0)
	else:
		_reset_trail()