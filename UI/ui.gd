extends CanvasLayer

@onready var money_label:Label=$MarginContainer/VBoxContainer/TopBarLeft/Money
@onready var money_animation:AnimationPlayer=$MarginContainer/VBoxContainer/TopBarLeft/AnimationPlayer
@onready var tower_cost_label:Label=$MarginContainer/VBoxContainer/TopBarLeft2/TowerCost
@onready var tower_cost_animation:AnimationPlayer=$MarginContainer/VBoxContainer/TopBarLeft2/AnimationPlayer
@onready var heart_container=$MarginContainer/HeartContainer
@onready var start_wave_signal=$MarginContainer/BottomBarRight/StartWave.pressed

var FULL=preload("res://UI/full.tscn")
var EMPTY=preload("res://UI/empty.tscn")

func _ready() -> void:
	GameState.changed_money.connect(self.on_changed_money)
	GameState.changed_health.connect(self.on_changed_health)
	GameState.changed_tower_cost.connect(self.on_changed_tower_cost)
	GameState.sync_ui()

func on_changed_money(new_amount:int):
	money_label.text=str(new_amount)+"$"
	money_animation.play("change_money")

func on_changed_tower_cost(new_amount:int):
	tower_cost_label.text=str(new_amount)+"$"
	tower_cost_animation.play("change_tower_cost")

func on_changed_health(new_amount:int,max_health:int):
	for n in heart_container.get_children():
		n.queue_free()
	for i in range(new_amount):
		heart_container.add_child(FULL.instantiate())
	for i in range(max_health-new_amount):
		heart_container.add_child(EMPTY.instantiate())
