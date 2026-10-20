extends ColorRect

var path_line:Path2D

func _draw() -> void:
	if (!GameState.can_afford_tower()):
		return
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.stop_place_range,Color(1,0,0,1))
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.stop_place_range,Color(0,1,0,1),false,3)
	draw_polyline(path_line.curve.get_baked_points(),Color(0,1,0,1),65)
	draw_polyline(path_line.curve.get_baked_points(),Color(1,0,0,1),58)
