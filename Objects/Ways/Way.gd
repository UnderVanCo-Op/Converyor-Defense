extends Path2D

var spawnTime := 5 
var follower := preload("res://Objects/Enemies/Enemy.tscn") 
var anotherFollowwer:=preload("res://Objects/Enemies/AnotherEnemy.tscn")
var levelWave
var newFollower



func _ready() -> void:
	$Timer.wait_time = spawnTime
	levelWave = LevelWave.mobModel["0"]

func _on_Timer_timeout() -> void:
	print(levelWave[0])
	if (levelWave[0]=="bot"):
		newFollower=follower.instance()
		add_child(newFollower)
	elif (levelWave[0]=="tank") :
		newFollower=anotherFollowwer.instance()
		add_child(newFollower)
	levelWave.pop_front()
	print(levelWave)
	
	
	
	
