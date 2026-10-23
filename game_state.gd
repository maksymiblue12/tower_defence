extends Node

signal changed_money(new_amount:int)
signal changed_health(new_amount:int,max_health:int)
signal changed_tower_cost(new_amount:int)
signal on_start_wave
signal on_end_wave

var lvl:Level

var show_ranges:bool=false
var is_wave_active:bool=false
var spawn_interval:float=-1.0
var enemies:Array[Enemy.EnemyType]=[]
var money:int=5
var max_health:int=5
var health:int=max_health

var tower_cost:int=5

func _init() -> void:
	create_keybinds()

func create_keybind(keybind_name:String,key:Key):
	InputMap.add_action(keybind_name)
	var event:InputEventKey=InputEventKey.new()
	event.keycode=key
	InputMap.action_add_event(keybind_name,event)

func create_mousebind(keybind_name:String,key:MouseButton):
	InputMap.add_action(keybind_name)
	var event:InputEventMouseButton=InputEventMouseButton.new()
	event.button_index=key
	InputMap.action_add_event(keybind_name,event)
	
func create_keybinds():
	create_keybind("key_h",KEY_H)
	create_keybind("key_esc",KEY_ESCAPE)
	create_mousebind("mouse_left",MOUSE_BUTTON_LEFT)

func init_level(level:Level):
	lvl=level

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("key_esc")):
		lvl.get_tree().quit()
	if (Input.is_action_just_pressed("key_h")):
		show_ranges=!show_ranges
		for node in get_tree().get_nodes_in_group("requires_redraw"):
			node.queue_redraw()
	
func find_intercept_time(shooter_pos:Vector2,bullet_speed:float,segment_start:Vector2,target_velocity:Vector2,t_start:float,t_end:float):
	var pos_offset:Vector2=segment_start-target_velocity*t_start
	var diff:Vector2=pos_offset-shooter_pos

	var a:float=target_velocity.length_squared()-bullet_speed*bullet_speed
	var b:float=2.0*diff.dot(target_velocity)
	var c:float=diff.length_squared()

	var times:Array[float]=[]
	
	if (abs(a)<0.00001):
		if (abs(b)<0.00001):
			return -1.0
		times.append(-c/b)
	else:
		var delta:float=b*b-4.0*a*c
		if (delta<0.0):
			return -1.0
		var sd:float=sqrt(delta)
		times.append((-b-sd)/(2.0*a))
		times.append((-b+sd)/(2.0*a))

	var best_time:float=-1.0
	for t in times:
		if (t>=0.0 and t>=t_start and t<=t_end):
			if (best_time==-1.0):
				best_time=t
				continue
			best_time=min(best_time,t)
			
	if (best_time<0.0):
		return -1.0
	return best_time

# https://www.andyzou.com/blog/ai-projectile-intercept-formula-for-gaming-without-trigonometry
func predict_position(shooter_pos:Vector2,bullet:Bullet,target:Enemy):
	var bullet_speed:float=bullet.speed
	var target_pos:Vector2=target.global_position
	var target_speed:float=target.speed
	var target_progress:float=target.progress_ratio
	var length:float=0
	var total_length:float=lvl.enemy_path.curve.get_baked_length()
	for i in range(lvl.enemy_path.curve.point_count-1):
		var start:Vector2=lvl.enemy_path.curve.get_point_position(i)
		var end:Vector2=lvl.enemy_path.curve.get_point_position(i+1)
		var current_length:float=start.distance_to(end)
		var start_progress:float=length/total_length
		var end_progress:float=(length+current_length)/total_length
		length+=current_length
		if (end_progress<target_progress):
			continue
		var t_start:float=max(0.0,(start_progress-target_progress)*total_length/target_speed)
		var t_end:float=(end_progress-target_progress)*total_length/target_speed
		var segment_start:Vector2=target_pos if target_progress>=start_progress else start
		var target_velocity:Vector2=(end-start).normalized()*target_speed
		var intercept_time:float=find_intercept_time(shooter_pos,bullet_speed,segment_start,target_velocity,t_start,t_end)
		if (intercept_time>=0.0):
			var hit_pos:Vector2=segment_start+target_velocity*(intercept_time-t_start)
			return hit_pos
	return Vector2.ZERO

func add_node(node):
	lvl.call_deferred("add_child",node)

func update_money(amount:int):
	money+=amount
	changed_money.emit(money)
	if (can_afford_tower()):
		for node in get_tree().get_nodes_in_group("requires_redraw"):
			node.queue_redraw()

func update_health(amount:int):
	health+=amount
	changed_health.emit(health,max_health)
	if (health<=0):
		get_tree().quit()
	
func on_kill_enemy(e:Enemy):
	update_money(e.coins)
	if (enemies.is_empty() and lvl.has_killed_all_enemies(-1)):
		end_wave()

func on_enemy_reach_end(_e:Enemy):
	update_health(-1)

func can_afford_tower():
	return money>=tower_cost
	
func on_place_tower():
	update_money(-tower_cost)
	tower_cost=roundi(tower_cost*1.5)
	changed_tower_cost.emit(tower_cost)
	for node in get_tree().get_nodes_in_group("requires_redraw"):
		node.queue_redraw()

func sync_ui():
	changed_money.emit(money)
	changed_health.emit(health,max_health)
	changed_tower_cost.emit(tower_cost)

func get_next_enemy_type():
	var t=enemies.pop_back()
	if (enemies.is_empty() and lvl.has_killed_all_enemies()):
		end_wave()
		return null
	return t

func load_wave():
	is_wave_active=true
	spawn_interval=1.0
	WaveCreator.load("wave1")
	enemies=[Enemy.EnemyType.Normal,Enemy.EnemyType.Heavy,Enemy.EnemyType.Fast ]
	on_start_wave.emit()

func end_wave():
	is_wave_active=false
	on_end_wave.emit()
