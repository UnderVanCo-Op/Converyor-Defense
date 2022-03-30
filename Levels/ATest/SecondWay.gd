extends Path2D


var timer=0
var spawnTime=8

var follower=preload("res://Objects/Enemies/Enemy.tscn") 


func _process(delta):
	timer=timer+delta
	
	if (timer>spawnTime):
		var newFollower=follower.instance()
		add_child(newFollower)
		timer=0
