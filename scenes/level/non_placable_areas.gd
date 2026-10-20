extends ColorRect

var path_line:Path2D

const RED=Color(0,1,1,1)
const RED_BORDER=Color(1,0,0,1)

func _draw() -> void:
	if (!GameState.can_afford_tower()):
		return
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.stop_place_range,RED)
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.stop_place_range,RED_BORDER,false,3)
	draw_polyline(path_line.curve.get_baked_points(),RED_BORDER,65)
	draw_polyline(path_line.curve.get_baked_points(),RED,58)
