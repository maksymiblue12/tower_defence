extends ColorRect

const BLUE=Color(0,0,1,1)
const BLUE_BORDER=Color(0,1,0,1)

func _draw() -> void:
	if (!GameState.show_ranges):
		return
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.tower_range,BLUE)
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.tower_range,BLUE_BORDER,false,3)
