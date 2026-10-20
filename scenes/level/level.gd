class_name Level
extends Node2D

@onready var enemy_path: Path2D = $EnemyPath
@onready var path_line: Line2D = $PathLine

var TOWER=preload("res://scenes/tower/tower.tscn")
var ENEMY_SCENE=preload("res://scenes/enemy/enemy.tscn")

func _init() -> void:
	GameState.init_level(self)

func _ready() -> void:
	resize_subviewports()
	path_line.points=enemy_path.curve.get_baked_points()
	$UI.start_wave_signal.connect(self.start_wave)
	
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("mouse_left")):
		add_tower(get_global_mouse_position())
		
func resize_subviewports():
	var s=get_viewport_rect().size
	$TowerRanges.size=s
	$TowerRanges/SubViewport.size=s
	$NonPlacableAreas.size=s
	$NonPlacableAreas/SubViewport.size=s
	$NonPlacableAreas/SubViewport/ColorRect.path_line=$EnemyPath
		
func can_place_tower(pos:Vector2):
	if (!GameState.can_afford_tower()):
		return false
	var pl=enemy_path.to_local(pos)
	if (enemy_path.curve.get_closest_point(pl).distance_to(pos)<60.0):
		return false
	for t in get_tree().get_nodes_in_group("tower"):
		if (t.global_position.distance_to(pos)<t.stop_place_range):
			return false
	return true
		
func add_tower(pos:Vector2):
	if (!can_place_tower(pos)):
		return
	GameState.on_place_tower()
	var tower=TOWER.instantiate()
	add_child(tower)
	tower.global_position=pos

func _on_spawn_timer_timeout() -> void:
	if (!GameState.is_wave_active):
		$SpawnTimer.stop()
		return
	var enemy:Enemy=ENEMY_SCENE.instantiate()
	enemy.enemy_type=GameState.get_next_enemy_type()
	enemy_path.add_child(enemy)
	
func start_wave():
	if (GameState.is_wave_active):
		return
	GameState.load_wave()
	$SpawnTimer.start(GameState.spawn_interval)
