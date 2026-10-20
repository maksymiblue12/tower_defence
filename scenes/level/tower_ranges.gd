extends ColorRect

func _draw() -> void:
	if (!GameState.show_ranges):
		return
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.tower_range,Color(1.,0.,0.,1.))
	for t in get_tree().get_nodes_in_group("tower"):
		draw_circle(t.global_position,t.tower_range,Color(0.,1.,0.,1.),false,3)
