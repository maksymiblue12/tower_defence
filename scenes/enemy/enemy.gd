class_name Enemy
extends PathFollow2D

@export var enemy_type:EnemyType=EnemyType.Normal

@onready var animations:AnimationPlayer=$AnimationPlayer
@onready var body:Sprite2D=$Body
@onready var health_bar:Panel=$HealthBar/Bg/Health

class EnemyData:
	var speed:float
	var health:int
	var coins:int
	var hue:float
	var brightness_modifier:float
	var size_modifier:float
	
	func create(n_speed:float,n_health:int,n_coins:int,n_hue:float,n_brightness_modifier:float,n_size_modifier:float):
		self.speed=n_speed
		self.health=n_health
		self.coins=n_coins
		self.hue=n_hue
		self.brightness_modifier=n_brightness_modifier
		self.size_modifier=n_size_modifier
		return self

enum EnemyType {
	Normal,Fast,Heavy
}

var EnemyTypeMap={
	EnemyType.Normal: EnemyData.new().create(150.0,3,1,2.0,1.0,1.0),
	EnemyType.Fast: EnemyData.new().create(350.0,2,2,200.0,1.0,0.8),
	EnemyType.Heavy: EnemyData.new().create(75.0,5,4,100.0,0.6,1.2)
}

static func type_from_string(type:String):
	var t=type.to_lower()
	if (t=="fast"):
		return EnemyType.Fast
	elif (t=="normal"):
		return EnemyType.Normal
	elif (t=="heavy"):
		return EnemyType.Heavy

var DEATH_PARTICLES=preload("res://FX/enemy_death/enemy_death.tscn")
var speed:float
var max_health_bar_x:float
var max_health:int
var health:int
var coins:int
var hue:float
var brightness_modifier:float
var size_modifier:float

var damage_tween:Tween


func _ready() -> void:
	max_health_bar_x=health_bar.size.x
	body.material=body.material.duplicate()
	var v=health_bar.get_theme_stylebox("panel").duplicate()
	health_bar.add_theme_stylebox_override("panel",v)
	var data:EnemyData=EnemyTypeMap[enemy_type]
	speed=data.speed
	health=data.health
	max_health=data.health
	coins=data.coins
	hue=data.hue
	brightness_modifier=data.brightness_modifier
	size_modifier=data.size_modifier
	self.scale=Vector2(size_modifier,size_modifier)
	(body.material as ShaderMaterial).set_shader_parameter("hue",hue)
	(body.material as ShaderMaterial).set_shader_parameter("brightness_modifier",brightness_modifier)

func _physics_process(delta: float):
	progress+=speed*delta
	if (progress_ratio>=1.0):
		reached_end()

func take_damage(amount:int):
	health-=amount
	if (health<=0):
		animate_death()
	else:
		animate_damage()
		
func animate_damage():
	if (damage_tween):
		damage_tween.kill()
	damage_tween=create_tween().set_trans(Tween.TRANS_LINEAR)
	(body.material as ShaderMaterial).set_shader_parameter("brightness_modifier",1.3)
	var a=(float(health)/float(max_health))
	var new_x=roundi(a*max_health_bar_x)
	var new_h=(a-1.0/float(max_health))*(100.0/360.0)
	damage_tween.tween_property(body,"material:shader_parameter/brightness_modifier",brightness_modifier,0.25)
	damage_tween.tween_property(health_bar,"size:x",new_x,0.05)
	damage_tween.tween_property((health_bar.get_theme_stylebox("panel") as StyleBoxFlat),"bg_color:h",new_h,0.05)
	#(health_bar.get_theme_stylebox("panel") as StyleBoxFlat).bg_color.h=new_h
	#health_bar.size.x=new_x
	
	damage_tween.play()
		
func animate_death():
	GameState.on_kill_enemy(self)
	var particles:GPUParticles2D=DEATH_PARTICLES.instantiate()
	GameState.add_node(particles)
	particles.global_position=global_position
	particles.emitting=true
	queue_free()

func reached_end():
	GameState.on_enemy_reach_end(self)
	queue_free()
