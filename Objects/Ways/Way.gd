extends Path2D

var spawnTime := 5 
var follower := preload("res://Objects/Enemies/Enemy.tscn") 

func _ready() -> void:
	$Timer.wait_time = spawnTime

func _on_Timer_timeout() -> void:
#	var newFollower = follower.instance()
#	add_child(newFollower)
	pass
