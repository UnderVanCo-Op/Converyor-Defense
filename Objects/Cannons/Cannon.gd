extends Node2D


var enemies = []
var cur_enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if enemies != []:
		print("enemies not null")
		cur_enemy = enemies[0]
		look_at(cur_enemy.global_position)
	pass

func _on_Vision_area_entered(area: Area2D) -> void:
	print("body entered")
	if(area.is_in_group("Enemies")):
		enemies.append(area)
		print("appended")


func _on_Vision_area_exited(area: Area2D) -> void:
	print("exited")
	if(area.is_in_group("Enemies")):
		enemies.erase(area)
