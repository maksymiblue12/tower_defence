class_name Bullet
extends Node2D

@export var speed:float=500.0
@export var damage:int=1

var dir:Vector2
var used=false

func create(pos:Vector2,direction:Vector2):
	global_position=pos
	dir=direction

func _physics_process(delta: float) -> void:
	position+=dir*speed*delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if (used or !area.get_parent().is_in_group("enemy")):
		return
	area.get_parent().take_damage(damage)
	used=true
	queue_free()

func _on_visible_on_screen_screen_exited() -> void:
	queue_free()
