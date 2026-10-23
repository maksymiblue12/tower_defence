extends Node

class WaveEmitter:
	func start():
		pass

class EnemyEmitter extends WaveEmitter:
	var lvl:Level
	var type:Enemy.EnemyType
	var amount:int
	var index:int=0
	var interval:int
	var on_end_string:String
	var on_end:WaveEmitter
	var timer:Timer
	
	func create(_lvl:Level,_type:Enemy.EnemyType,_amount:int,_interval:int,on_end_name:String):
		self.lvl=_lvl
		self.type=_type
		self.amount=_amount
		self.interval=_interval
		self.on_end_string=on_end_name
		
	func set_on_end(_on_end:WaveEmitter):
		self.on_end=_on_end

	func start():
		self.timer=lvl.create_timer(self.interval)
		self.timer.timeout.connect(self.add_enemy)

	func add_enemy():
		if (index==amount):
			self.timer.stop()
			self.on_end.start()
			return
		lvl.add_enemy(self.type)
		index+=1

func load(file_name:String):
	var file=FileAccess.open("./waves/"+file_name+".json",FileAccess.READ)
	var txt=file.get_as_text()
	
	var json=JSON.new()
	var err=json.parse(txt)
	if (err!=OK):
		print("JSON Parse Error: ", json.get_error_message(), " in ", txt, " at line ", json.get_error_line())
		return
	var data=json.data
