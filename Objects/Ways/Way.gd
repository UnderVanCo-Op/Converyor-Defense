extends Path2D

var spawnTime := 5 
var follower := preload("res://Objects/Enemies/Enemy.tscn") 
var anotherFollowwer:=preload("res://Objects/Enemies/AnotherEnemy.tscn")
var mobModel:Dictionary

func _ready() -> void:
	$Timer.wait_time = spawnTime
	var file=File.new()
	file.open("res://Game Files/Level1.json",File.READ)
	var mobData=file.get_as_text()
	mobModel=parse_json(mobData)
	

func _on_Timer_timeout() -> void:
	var newFollower 
#	if ():
	
	add_child(newFollower)
	
