extends Label

func _ready():
	var color_colorpicker = get_parent().get_pick_color()
	add_color_override("font_color", Color(255-color_colorpicker[0],255-color_colorpicker[1],255-color_colorpicker[2]))
	
	
func _on_colorpicker_background_color_changed(color):
	add_color_override("modulate",(Color(255-color[0],255-color[1],255-color[2])))
