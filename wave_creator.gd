extends Node

var emitters:Dictionary={}
var waves:Dictionary={}

var max_wave:int=-1

func _init() -> void:
	var file=FileAccess.open("./waves/waves.json",FileAccess.READ)
	var txt=file.get_as_text()
	
	var json=JSON.new()
	var err=json.parse(txt)
	if (err!=OK):
		print("JSON Parse Error: ", json.get_error_message(), " in ", txt, " at line ", json.get_error_line())
		return
	waves=json.data
	max_wave=waves.keys().map(func (a):return int(a)).max()

class WaveEmitter:
	func start():
		pass

class EnemyEmitter extends WaveEmitter:
	var lvl:Level
	var type:Enemy.EnemyType
	var amount:int
	var index:int=0
	var interval:int
	var on_end_string:String=""
	var on_end:WaveEmitter
	var timer:Timer
	
	func create(_lvl:Level,_type:Enemy.EnemyType,_amount:int,_interval:int,on_end_name:String):
		self.lvl=_lvl
		self.type=_type
		self.amount=_amount
		self.interval=_interval
		self.on_end_string=on_end_name
		return self
		
	func set_on_end(_on_end:WaveEmitter):
		self.on_end=_on_end

	func start():
		self.timer=lvl.create_timer(1)
		self.timer.timeout.connect(self.add_enemy)
		self.timer.start()

	func add_enemy():
		if (index==amount):
			self.timer.stop()
			if (self.on_end==null):
				GameState.end_emitting()
			else:
				self.on_end.start()
			return
		lvl.add_enemy(self.type)
		index+=1
		
func create_emitter(lvl:Level,data:Dictionary):
	var t=data["type"]
	if (t=="enemy_emitter"):
		return EnemyEmitter.new().create(lvl,Enemy.type_from_string(data["enemy_type"]),data["amount"],data["interval"],data.get("on_end",""))

func load(lvl:Level,level_number:String):
	emitters={}
	
	var data:Dictionary=waves[level_number]
	var start:String=""
	for k in data.keys():
		var v=data[k]
		if (k=="start"):
			start=v
			continue
		var emitter=create_emitter(lvl,v)
		emitters[k]=emitter
	for k in emitters.keys():
		var e=emitters[k]
		if (e.on_end_string!=""):
			e.set_on_end(emitters[e.on_end_string])
	emitters[start].start()
