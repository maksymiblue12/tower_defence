extends Node2D

@onready var turret:Node2D=$Turret
@onready var barrel:Marker2D=$Turret/Barrel

@export var tower_range:float=200.0
@export var shoot_delay:float=0.75

var BULLET=preload("res://scenes/bullet/bullet.tscn")

var target:Enemy
var current_bullet
var stop_place_range:float

func _ready() -> void:
	stop_place_range=$Sprite.get_rect().size.length()/2+5
	current_bullet=create_bullet()
	$ShootTimer.wait_time=shoot_delay

func find_target():
	var enemies=get_tree().get_nodes_in_group("enemy")
	
	var valid_enemies=enemies.filter(func (e:Enemy): return global_position.distance_to(e.global_position)<=tower_range)
	valid_enemies.sort_custom(func (a:Enemy,b:Enemy): return a.progress_ratio>b.progress_ratio)
	
	for e in valid_enemies:
		if (GameState.predict_position(barrel.global_position,current_bullet,e).is_zero_approx()):
			continue
		target=e
		return

func check_target_is_valid():
	if (!target):
		return false
	if (global_position.distance_to(target.global_position)>tower_range):
		return false
	return true

func point_at_target():
	if (!target):
		return
	turret.look_at(GameState.predict_position(barrel.global_position,current_bullet,target))

func create_bullet():
	var bullet=BULLET.instantiate()
	return bullet

func shoot():
	if (!target or !current_bullet):
		return
	GameState.add_node(current_bullet)
	current_bullet.create(barrel.global_position,Vector2.RIGHT.rotated(turret.global_rotation))
	current_bullet=create_bullet()

func _physics_process(_delta: float) -> void:
	if (!check_target_is_valid()):
		find_target()
	point_at_target()

func _on_shoot_timer_timeout() -> void:
	shoot()
